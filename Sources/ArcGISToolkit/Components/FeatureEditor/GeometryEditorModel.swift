// Copyright 2026 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Foundation

/// A data model that contains the state needed to use a geometry editor.
@MainActor
@Observable
final class GeometryEditorModel {
    /// The geometry editor used to edit geometries on the `MapView`.
    var geometryEditor = GeometryEditor() {
        didSet {
            geometryEditor.tool = selectedTool.geometryEditorTool
        }
    }
    /// A Boolean value indicating whether the geometry editor has edits to undo.
    private(set) var canUndo = false
    /// The geometry editor's current geometry.
    private(set) var geometry: Geometry? {
        didSet {
            updateSelectableTools()
        }
    }
    /// A Boolean value indicating whether the geometry editor has started.
    private(set) var isStarted = false
    /// The geometry that was used to start the current editing session.
    private(set) var initialGeometry: Geometry?
    /// The geometry type that was used to start the current editing session.
    private var geometryType: Geometry.Type?
    /// The tools that are currently able to be selected.
    private(set) var selectableTools: [Tool] = Tool.all
    /// The template-specific tools currently used to construct geometry.
    private var constructionTools: [Tool]?
    /// The tool selected by the picker.
    var selectedTool: Tool = .vertex {
        didSet {
            geometryEditor.tool = selectedTool.geometryEditorTool
        }
    }

    /// Monitors geometry editor streams and updates the corresponding properties.
    func monitorStreams() async {
        await withTaskGroup { group in
            group.addTask { @MainActor @Sendable in
                for await canUndo in self.geometryEditor.$canUndo {
                    self.canUndo = canUndo
                }
            }
            group.addTask { @MainActor @Sendable in
                for await geometry in self.geometryEditor.$geometry {
                    self.geometry = geometry
                }
            }
            group.addTask { @MainActor @Sendable in
                for await isStarted in self.geometryEditor.$isStarted {
                    self.isStarted = isStarted
                }
            }
        }
    }

    /// Starts the geometry editor with an initial geometry.
    func start(withInitial geometry: Geometry) {
        initialGeometry = geometry
        geometryType = nil
        geometryEditor.start(withInitial: geometry)
    }

    /// Starts the geometry editor with a geometry type.
    func start(withType geometryType: Geometry.Type) {
        initialGeometry = nil
        self.geometryType = geometryType
        geometryEditor.start(withType: geometryType)
    }

    /// Sets the tools available for the current geometry editing session.
    /// - Parameters:
    ///   - tools: The tools that can be selected.
    ///   - selectedTool: The initial selected tool.
    func setSelectableTools(_ tools: [Tool], selectedTool: Tool?) {
        constructionTools = tools
        selectableTools = tools
        self.selectedTool = selectedTool ?? tools.first ?? .vertex
    }

    /// Restarts the geometry editor if it is started.
    func restart() {
        guard isStarted else { return }

        if let initialGeometry {
            start(withInitial: initialGeometry)
        } else if let geometryType {
            start(withType: geometryType)
        }
    }

    /// Stops the geometry editor and resets the session state.
    /// - Parameter resetTools: Whether to reset the tools configured for the session.
    func stop(resetTools: Bool = true) {
        geometryEditor.stop()
        canUndo = false
        geometry = nil
        isStarted = false
        initialGeometry = nil
        geometryType = nil
        if resetTools {
            constructionTools = nil
            selectableTools = Tool.all
        }
    }

    /// Updates the tools available for the current geometry.
    private func updateSelectableTools() {
        if let constructionTools {
            selectableTools = constructionTools
        } else if let geometry {
            let geometryType = type(of: geometry)
            selectableTools = Tool.all.filter { tool in
                tool.supportedGeometryTypes.contains { $0 == geometryType }
            }
        } else {
            selectableTools = Tool.all
        }

        guard !selectableTools.contains(selectedTool),
              let firstValidTool = selectableTools.first else {
            return
        }
        selectedTool = firstValidTool
    }
}

// MARK: - Tool

extension GeometryEditorModel {
    struct Tool: Hashable {
        private let id: String
        let label: String
        let systemImage: String
        let supportedGeometryTypes: [Geometry.Type]
        private let makeGeometryEditorTool: @MainActor () -> GeometryEditorTool

        init(
            label: String,
            systemImage: String,
            supportedGeometryTypes: [Geometry.Type],
            makeGeometryEditorTool: @escaping @MainActor () -> GeometryEditorTool
        ) {
            self.id = label
            self.label = label
            self.systemImage = systemImage
            self.supportedGeometryTypes = supportedGeometryTypes
            self.makeGeometryEditorTool = makeGeometryEditorTool
        }

        static let freehand = Self(
            label: "Freehand",
            systemImage: "scribble",
            supportedGeometryTypes: [Polygon.self, Polyline.self]
        ) {
            FreehandTool()
        }

        static func shape(kind: ShapeTool.Kind) -> Self {
            Self(
                label: kind.label,
                systemImage: kind.systemImage,
                supportedGeometryTypes: [Polygon.self, Polyline.self]
            ) {
                let tool = ShapeTool(kind: kind)
                tool.configuration.allowsPartCreation = true
                return tool
            }
        }

        static let vertex = Self(
            label: "Vertex",
            systemImage: "point.3.connected.trianglepath.dotted",
            supportedGeometryTypes: [Multipoint.self, Point.self, Polygon.self, Polyline.self]
        ) {
            VertexTool()
        }

        static let vertexReticle = Self(
            label: "Reticle",
            systemImage: "dot.viewfinder",
            supportedGeometryTypes: [Multipoint.self, Point.self, Polygon.self, Polyline.self]
        ) {
            ReticleVertexTool()
        }

        static let all: [Self] = [
            .freehand,
            .vertex,
            .vertexReticle,
            .shape(kind: .arrow),
            .shape(kind: .ellipse),
            .shape(kind: .rectangle),
            .shape(kind: .triangle)
        ]

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

private extension GeometryEditorModel.Tool {
    /// The geometry editor tool associated with the tool.
    @MainActor
    var geometryEditorTool: GeometryEditorTool {
        let tool = makeGeometryEditorTool()

        // Makes the fill symbol semi-transparent to avoid obscuring the map beneath polygons.
        if let fillSymbol = tool.style.fillSymbol as? FillSymbol {
            fillSymbol.color = fillSymbol.color.withAlphaComponent(0.5)
        }
        
        return tool
    }
    
}

private extension ShapeTool.Kind {
    var label: String {
        switch self {
        case .arrow: "Arrow"
        case .ellipse: "Ellipse"
        case .rectangle: "Rectangle"
        case .triangle: "Triangle"
        @unknown default:
            fatalError("Unknown shape tool kind: \(self)")
        }
    }

    var systemImage: String {
        switch self {
        case .arrow: "arrowshape.right"
        case .ellipse: "circle"
        case .rectangle: "rectangle"
        case .triangle: "triangle"
        @unknown default:
            fatalError("Unknown shape tool kind: \(self)")
        }
    }
}
