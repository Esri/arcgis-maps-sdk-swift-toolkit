// Copyright 2025 Esri
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
import OSLog
import SwiftUI

public extension View {
    /// Sets the available tools for the `GeometryEditorToolbar` tools menu.
    /// - Parameters:
    ///   - tools: A list of tools to display in the menu. If only one tool is
    ///   provided, the menu will be hidden. If the list is empty, the menu
    ///   will not override the `GeometryEditorTool` set on the `GeometryEditor`
    ///   passed to the toolbar.
    ///   - selection: A binding to the currently selected tool. Ensure that
    ///   the value matches one of the detents that you provide for the
    ///   `tools` parameter.
    func tools(
        _ tools: [GeometryEditorToolbar.Tool],
        selection: Binding<GeometryEditorToolbar.Tool>? = nil
    ) -> some View {
        return self
            .environment(\.tools, tools.uniqued())
            .environment(\.selectedTool, selection)
    }
}

// MARK: - Tool

public extension GeometryEditorToolbar {
    /// A tool that can be shown in the tools menu.
    enum Tool: Hashable {
        case freehand
        case programmaticReticle
        case shape(kind: ShapeTool.Kind)
        case vertex
        case vertexReticle
        case custom(CustomTool)
        
        var geometryEditorTool: GeometryEditorTool {
            switch self {
            case .freehand:
                FreehandTool()
            case .shape(let kind):
                ShapeTool(kind: kind)
            case .programmaticReticle:
                ProgrammaticReticleTool()
            case .vertex:
                VertexTool()
            case .vertexReticle:
                ReticleVertexTool()
            case .custom(let tool):
                tool.tool
            }
        }
        
        public var label: LocalizedStringResource {
            switch self {
            case .freehand:
                "Freehand"
            case .programmaticReticle:
                "Programmatic Reticle"
            case .shape(let shape):
                shape.label
            case .vertex:
                "Vertex"
            case .vertexReticle:
                "Vertex Reticle"
            case .custom(let tool):
                tool.label
            }
        }
        
        var systemImage: String {
            switch self {
            case .freehand:
                "scribble"
            case .programmaticReticle:
                "dot.viewfinder" // TODO: pick other symbol?
            case .shape(let shape):
                shape.systemImage
            case .vertex:
                "point.3.connected.trianglepath.dotted"
            case .vertexReticle:
                "dot.viewfinder"
            case .custom(let tool):
                tool.systemImage
            }
        }
        
        var supportedGeometryTypes: [Geometry.Type] {
            switch self {
            case .freehand:
                [Polygon.self, Polyline.self]
            case .programmaticReticle, .vertex, .vertexReticle:
                [Multipoint.self, Point.self, Polygon.self, Polyline.self]
            case .shape(let kind):
                if kind == .rectangle {
                    [Envelope.self, Polygon.self, Polyline.self]
                } else {
                    [Polygon.self, Polyline.self]
                }
            case .custom(let customTool):
                customTool.supportedGeometryTypes
            }
        }
    }
}

extension GeometryEditorToolbar.Tool: CaseIterable {
    // TODO: Change to defaultCases since can't include custom?
    public static var allCases: [GeometryEditorToolbar.Tool] {
        [
            .freehand,
            .programmaticReticle,
            .vertex,
            .vertexReticle,
            .shape(kind: .arrow),
            .shape(kind: .ellipse),
            .shape(kind: .rectangle),
            .shape(kind: .triangle),
        ]
    }
}

// MARK: - CustomTool

public extension GeometryEditorToolbar {
    struct CustomTool: Hashable {
        let tool: GeometryEditorTool
        let label: LocalizedStringResource
        // TODO: Convert to image
        let systemImage: String
        let supportedGeometryTypes: [Geometry.Type]
        let geometryConstructionToolID: UUID?
        
        public init(
            _ tool: GeometryEditorTool,
            label: LocalizedStringResource,
            systemImage: String,
            supportedGeometryTypes: [Geometry.Type] = [],
            geometryConstructionToolID: UUID? = nil
        ) {
            self.tool = tool
            self.label = label
            self.systemImage = systemImage
            self.supportedGeometryTypes = supportedGeometryTypes
            self.geometryConstructionToolID = geometryConstructionToolID
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.tool === rhs.tool
            && lhs.label == rhs.label
            && lhs.systemImage == rhs.systemImage
            && lhs.supportedGeometryTypeIDs == rhs.supportedGeometryTypeIDs
            && lhs.geometryConstructionToolID == rhs.geometryConstructionToolID
        }
        
        public func hash(into hasher: inout Hasher) {
            // TODO: Add label hash?
            hasher.combine(ObjectIdentifier(tool))
            hasher.combine(systemImage)
            hasher.combine(supportedGeometryTypeIDs)
            hasher.combine(geometryConstructionToolID)
        }
        
        private var supportedGeometryTypeIDs: [ObjectIdentifier] {
            supportedGeometryTypes.map(ObjectIdentifier.init)
        }
    }
}

// MARK: - ToolPicker

struct ToolPicker: View {
    private typealias Tool = GeometryEditorToolbar.Tool
    
    /// The geometry editor from the parent geometry editor toolbar.
    @Environment(\.geometryEditor) private var geometryEditor
    
    /// The padding to add to the pickers's label. This is need to increase the hit box size.
    @Environment(\.labelPadding) private var labelPadding
    
    /// The tool options to show in the picker.
    @Environment(\.tools) private var tools
    
    /// A user provided binding to the tool selected by the picker.
    @Environment(\.selectedTool) private var externalSelectedTool
    
    @Environment(\.templateAllowedTools) private var templateAllowedTools
    
    @State private var geometry: Geometry?
    @State private var selectedTool: Tool = .vertex
    
    private var validTools: [Tool] {
        if let geometry, let templateAllowedTools = templateAllowedTools?.wrappedValue {
            tools.filter { tool in
                isTool(tool, validFor: geometry, selection: selectedTool)
                && isTool(tool, validFor: templateAllowedTools)
            }
        } else if let geometry {
            tools.filter { tool in
                isTool(tool, validFor: geometry, selection: selectedTool)
            }
        } else if let templateAllowedTools = templateAllowedTools?.wrappedValue {
            tools.filter { tool in
                isTool(tool, validFor: templateAllowedTools)
            }
        } else {
            tools
        }
    }
    
    var body: some View {
        // Prevents the geometry editor tool from being overwritten when tools is empty.
        if !tools.isEmpty {
            Group {
                // Don't show the menu if there is only one tool.
                if tools.count > 1 {
                    Menu {
                        Picker("Tool", selection: $selectedTool) { [validTools] in
                            ForEach(tools, id: \.self) { tool in
                                Label(tool.label, systemImage: tool.systemImage)
                                    .selectionDisabled(!validTools.contains(tool))
                            }
                        }
                    } label: {
                        Label("Tool", systemImage: selectedTool.systemImage)
                            .padding(labelPadding)
                    }
                }
            }
            .onAppear(perform: setUp)
            .onChange(of: validTools) {
                updateSelectedTool()
            }
            .onChange(of: externalSelectedTool?.wrappedValue) {
                // Sets selectedTool when externalSelectedTool is set externally.
                guard let externalSelectedTool = externalSelectedTool?.wrappedValue,
                      externalSelectedTool != selectedTool else {
                    return
                }
                
                if validTools.contains(externalSelectedTool) {
                    selectedTool = externalSelectedTool
                } else {
                    // If new external is invalid, it is set to last valid tool (selectedTool).
                    logExternalSelectionError(tool: externalSelectedTool)
                    self.externalSelectedTool?.wrappedValue = selectedTool
                }
            }
            .onChange(of: selectedTool) {
                // Sets the external and geometry editor tools when the selectedTool changes.
                externalSelectedTool?.wrappedValue = selectedTool
                geometryEditor.tool = selectedTool.geometryEditorTool
            }
            .task(id: ObjectIdentifier(geometryEditor)) {
                // Overwrites the geometry editor tool when the editor changes.
                geometryEditor.tool = selectedTool.geometryEditorTool
                
                for await geometry in geometryEditor.$geometry {
                    self.geometry = geometry
                }
            }
        }
    }
    
    /// Sets up the view's state when it appears.
    private func setUp() {
        if let externalSelectedTool = externalSelectedTool?.wrappedValue {
            if validTools.contains(externalSelectedTool) {
                selectedTool = externalSelectedTool
            } else {
                logExternalSelectionError(tool: externalSelectedTool)
                
                // If initial external is invalid, first valid is used instead.
                if let firstValidTool = validTools.first {
                    selectedTool = firstValidTool
                    self.externalSelectedTool?.wrappedValue = firstValidTool
                }
            }
        } else {
            updateSelectedTool()
        }
        
        // Overwrites the geometry editor tool, so that it is valid.
        geometryEditor.tool = selectedTool.geometryEditorTool
    }
    
    private func isTool(_ tool: Tool, validFor templateAllowedTools: Set<Tool>) -> Bool {
        return templateAllowedTools.isEmpty || templateAllowedTools.contains(tool)
    }
    
    private func isTool(_ tool: Tool, validFor geometry: Geometry, selection: Tool) -> Bool {
        let geometryType = type(of: geometry)
        guard tool.supportedGeometryTypes.contains(where: { $0 == geometryType }) else {
            return false
        }
        
        if case .shape = tool {
            return tool == selection || geometry.isEmpty
        } else {
            return true
        }
    }
    
    /// Sets `selectedTool` to the first valid tools if it's current value is invalid.
    private func updateSelectedTool() {
        guard !validTools.contains(selectedTool), let firstValidTool = validTools.first else {
            return
        }
        selectedTool = firstValidTool
    }
    
    /// Logs an error for an invalid `externalSelectedTool` value.
    private func logExternalSelectionError(tool: Tool) {
        let errorMessage = if tools.contains(tool){
            if let geometry {
                "Tool '\(tool)' is not valid for geometry type '\(type(of: geometry))'."
            } else {
                "Tool '\(tool)' is not valid."
            }
        } else {
            "Cannot set selected tool '\(tool)' if it is not included in supported tools."
        }
        Logger.geometryEditorToolbar.error("\(errorMessage)")
    }
}

// MARK: - Helper

private extension EnvironmentValues {
    /// The tool options to show in the `ToolPicker`.
    @Entry var tools: [GeometryEditorToolbar.Tool] = [.vertex, .freehand, .vertexReticle]
    
    /// A binding to the tool selected by the `ToolPicker`.
    @Entry var selectedTool: Binding<GeometryEditorToolbar.Tool>?
}

private extension Logger {
    static var geometryEditorToolbar: Logger {
        Logger(subsystem: "com.esri.ArcGISToolkit", category: "GeometryEditorToolbar")
    }
}

private extension ShapeTool.Kind {
    var label: LocalizedStringResource {
        switch self {
        case .arrow: "Arrow"
        case .ellipse: "Ellipse"
        case .rectangle: "Rectangle"
        case .triangle: "Triangle"
        @unknown default:
            fatalError("Unknown ShapeTool.Kind: '\(self)'")
        }
    }
    
    var systemImage: String {
        switch self {
        case .arrow: "arrowshape.right"
            // TODO: Use ellipse image
        case .ellipse: "circle"
        case .rectangle: "rectangle"
        case .triangle: "triangle"
        @unknown default:
            fatalError("Unknown ShapeTool.Kind: '\(self)'")
        }
    }
}
