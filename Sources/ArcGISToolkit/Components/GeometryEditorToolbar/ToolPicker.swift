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
import SwiftUI

/// A control for picking a geometry editing tool.
struct ToolPicker: View {
    /// The model for the parent geometry editor toolbar.
    @Environment(GeometryEditorToolbarModel.self) private var model
    
    /// The tools that are currently able to be selected.
    @State private var selectableTools: [Tool] = []
    /// The tool selected by the picker.
    @State private var selectedTool: Tool = .vertex
    
    var body: some View {
        Menu {
            Picker(selection: $selectedTool) {
                ForEach(selectableTools, id: \.self) { tool in
                    Label {
                        tool.label
                    } icon: {
                        Image(systemName: tool.systemImage)
                    }
                }
            } label: {
                Text.tool
            }
        } label: {
            Label {
                Text.tool
            } icon: {
                Image(systemName: selectedTool.systemImage)
            }
        }
        .animation(.default, value: selectedTool)
        .onChange(of: selectableTools, initial: true) {
            // Sets the selection to the first valid tool if the current value is invalid.
            guard !selectableTools.contains(selectedTool),
                  let firstValidTool = selectableTools.first else {
                return
            }
            selectedTool = firstValidTool
        }
        .onChange(of: selectedTool) {
            // Sets the geometry editor tool when the selectedTool changes.
            model.geometryEditor.tool = selectedTool.geometryEditorTool
        }
        .task(id: ObjectIdentifier(model)) {
            // Overwrites the initial geometry editor tool when the editor changes.
            model.geometryEditor.tool = selectedTool.geometryEditorTool
            
            for await geometry in model.geometryEditor.$geometry {
                selectableTools = selectableTools(for: geometry)
            }
        }
    }
    
    /// Returns the tools that should be enabled for a given geometry.
    /// - Parameter geometry: The geometry to return tools for.
    private func selectableTools(for geometry: Geometry?) -> [Tool] {
        if let geometry {
            let geometryType = type(of: geometry)
            return Tool.allCases.filter { tool in
                tool.supportedGeometryTypes.contains { $0 == geometryType }
            }
        } else {
            return Tool.allCases
        }
    }
}

// MARK: - Tool

/// A tool that can be shown in the tools menu.
private enum Tool: Hashable {
    case freehand
    case shape(kind: ShapeTool.Kind)
    case vertex
    case vertexReticle
    
    /// The geometry editor tool associated with the tool.
    var geometryEditorTool: GeometryEditorTool {
        switch self {
        case .freehand:
            return FreehandTool()
        case .shape(let kind):
            let shapeTool = ShapeTool(kind: kind)
            // Allows the shape tool to be used when there is an existing geometry.
            shapeTool.configuration.allowsPartCreation = true
            return shapeTool
        case .vertex:
            return VertexTool()
        case .vertexReticle:
            return ReticleVertexTool()
        }
    }
    
    /// A localized, user-friendly label for the tool.
    var label: Text {
        switch self {
        case .freehand:
            Text(
                "Freehand",
                bundle: .toolkitModule,
                comment: "A label for a geometry editor tool that allows the user to edit using freehand gestures."
            )
        case .shape(let shape):
            shape.label
        case .vertex:
            Text(
                "Vertex",
                bundle: .toolkitModule,
                comment: "A label for a geometry editor tool that allows the user to edit by interacting with individual vertices."
            )
        case .vertexReticle:
            Text(
                "Reticle",
                bundle: .toolkitModule,
                comment: "A label for a geometry editor tool that allows the user to edit using a reticle."
            )
        }
    }
    
    /// The geometry types that the tool can be used with.
    var supportedGeometryTypes: [Geometry.Type] {
        switch self {
        case .freehand, .shape:
            [Polygon.self, Polyline.self]
        case .vertex, .vertexReticle:
            [Multipoint.self, Point.self, Polygon.self, Polyline.self]
        }
    }
    
    /// The name of a system image that represents the tool.
    var systemImage: String {
        switch self {
        case .freehand: "scribble"
        case .shape(let shape): shape.systemImage
        case .vertex: "point.3.connected.trianglepath.dotted"
        case .vertexReticle: "dot.viewfinder"
        }
    }
}

extension Tool: CaseIterable {
    static var allCases: [Self] {
        [
            .freehand,
            .vertex,
            .vertexReticle,
            .shape(kind: .arrow),
            .shape(kind: .ellipse),
            .shape(kind: .rectangle),
            .shape(kind: .triangle)
        ]
    }
}

// MARK: - Extensions

private extension ShapeTool.Kind {
    /// A localized, user-friendly label for the shape tool kind.
    var label: Text {
        switch self {
        case .arrow:
            Text(
                "Arrow",
                bundle: .toolkitModule,
                comment: "A label for a geometry editor shape tool that creates an arrow."
            )
        case .ellipse:
            Text(
                "Ellipse",
                bundle: .toolkitModule,
                comment: "A label for a geometry editor shape tool that creates an ellipse."
            )
        case .rectangle:
            Text(
                "Rectangle",
                bundle: .toolkitModule,
                comment: "A label for a geometry editor shape tool that creates a rectangle."
            )
        case .triangle:
            Text(
                "Triangle",
                bundle: .toolkitModule,
                comment: "A label for a geometry editor shape tool that creates a triangle."
            )
        @unknown default:
            fatalError("Unknown shape tool kind: \(self)")
        }
    }
    
    /// The name of a system image that represents the shape tool kind.
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

private extension Text {
    /// Localized text for the word "Tool".
    static var tool: Self {
        .init(
            "Tool",
            bundle: .toolkitModule,
            comment: "A label for a control to pick a geometry editor tool."
        )
    }
}

#Preview {
    let geometryEditor = GeometryEditor()
    
    ToolPicker()
        .environment(GeometryEditorToolbarModel(geometryEditor: geometryEditor))
        .onAppear {
            geometryEditor.start(withType: Point.self)
        }
}
