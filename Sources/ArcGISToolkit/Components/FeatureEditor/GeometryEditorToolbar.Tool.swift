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
        case custom(ToolItem)
        case group(ToolGroup)
        
        var geometryEditorTool: GeometryEditorTool {
            switch self {
            case .freehand:
                FreehandTool()
            case .group(let group):
                group.tools.first?.geometryEditorTool ?? VertexTool()
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
        
        public var label: String {
            switch self {
            case .freehand:
                "Freehand"
            case .group(let group):
                group.label
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
        
        var icon: Image {
            switch self {
            case .freehand:
                Image(systemName: "scribble")
            case .group(let group):
                group.icon
            case .programmaticReticle:
                // TODO: pick other symbol?
                Image(systemName: "dot.viewfinder")
            case .shape(let shape):
                shape.icon
            case .vertex:
                Image(systemName: "point.3.connected.trianglepath.dotted")
            case .vertexReticle:
                Image(systemName: "dot.viewfinder")
            case .custom(let tool):
                tool.icon
            }
        }
        
        var supportedGeometryTypes: [Geometry.Type] {
            switch self {
            case .freehand:
                [Polygon.self, Polyline.self]
            case .group(let group):
                group.tools.flatMap(\.supportedGeometryTypes)
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
        
        var leafTools: [Self] {
            if case .group(let group) = self {
                group.tools.flatMap(\.leafTools)
            } else {
                [self]
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
    struct ToolItem: Hashable {
        let tool: GeometryEditorTool
        let label: String
        let icon: Image
        let supportedGeometryTypes: [Geometry.Type]
        
        public init(
            _ tool: GeometryEditorTool,
            label: String,
            icon: Image,
            supportedGeometryTypes: [Geometry.Type] = []
        ) {
            self.tool = tool
            self.label = label
            self.icon = icon
            self.supportedGeometryTypes = supportedGeometryTypes
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.tool === rhs.tool
            && lhs.label == rhs.label
            && lhs.icon == rhs.icon
            && lhs.supportedGeometryTypeIDs == rhs.supportedGeometryTypeIDs
        }
        
        public func hash(into hasher: inout Hasher) {
            // TODO: Add icon hash?
            hasher.combine(ObjectIdentifier(tool))
            hasher.combine(label)
            hasher.combine(supportedGeometryTypeIDs)
        }
        
        private var supportedGeometryTypeIDs: [ObjectIdentifier] {
            supportedGeometryTypes.map(ObjectIdentifier.init)
        }
    }
    
    struct ToolGroup: Hashable {
        let tools: [Tool]
        let label: String
        let icon: Image
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(tools)
            hasher.combine(label)
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
    @Environment(\.tools) private var externalTools
    
    /// A user provided binding to the tool selected by the picker.
    @Environment(\.selectedTool) private var userSelectedTool
    
    @Environment(\.templateAllowedTools) private var templateAllowedTools
    @Environment(\.templateSelectedTool) private var templateSelectedTool
    
    @State private var geometry: Geometry?
    @State private var selectedTool: Tool = .vertex
    
    // TODO: Should we give developer access to internal template selection?
    private var externalSelectedTool: Binding<Tool>? {
        templateSelectedTool ?? userSelectedTool
    }
    
    private var selectableTools: [Tool] {
        tools.flatMap(\.leafTools).uniqued()
    }
    
    // TODO: Should external tools override internal template tools?
    private var tools: [Tool] {
        templateAllowedTools?.wrappedValue ?? externalTools
    }
    
    private var validTools: [Tool] {
        if let geometry, let templateAllowedTools = templateAllowedTools?.wrappedValue {
            selectableTools.filter { tool in
                isTool(tool, validFor: geometry, selection: selectedTool)
                && isTool(tool, validFor: templateAllowedTools)
            }
        } else if let geometry {
            selectableTools.filter { tool in
                isTool(tool, validFor: geometry, selection: selectedTool)
            }
        } else if let templateAllowedTools = templateAllowedTools?.wrappedValue {
            selectableTools.filter { tool in
                isTool(tool, validFor: templateAllowedTools)
            }
        } else {
            selectableTools
        }
    }
    
    var body: some View {
        // Prevents the geometry editor tool from being overwritten when tools is empty.
        if !selectableTools.isEmpty {
            Group {
                // Don't show the menu if there is only one tool.
                if selectableTools.count > 1 {
                    Menu {
                        ForEach(tools, id: \.self) { tool in
                            toolMenu(for: tool)
                        }
                    } label: {
                        Label("Tool", image: selectedTool.icon)
                            .padding(labelPadding)
                    }
                }
            }
            .onAppear(perform: setUp)
            .onChange(of: validTools, updateSelectedTool)
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
    
    @ViewBuilder
    private func toolMenu(for tool: Tool, label: String? = nil, icon: Image? = nil) -> some View {
        if case .group(let group) = tool {
            let label = label ?? group.label
            let icon = icon ?? group.icon
            
            switch group.tools.count {
            case 0:
                // TODO: Hide unsupported tools, per Ting and Ryan.
                // TODO: Should we allow developer to support unsupported tools?
                Button(action: {}) {
                    Label(label, image: icon)
                }
                .disabled(true)
            case 1:
                AnyView(
                    toolMenu(for: group.tools[0], label: label, icon: icon)
                )
            default:
                Menu {
                    ForEach(group.tools, id: \.self) { tool in
                        AnyView(toolMenu(for: tool))
                    }
                } label: {
                    Label(label, image: icon)
                }
            }
        } else {
            let binding = Binding(
                get: { selectedTool == tool },
                set: { isSelected in
                    guard isSelected else { return }
                    selectedTool = tool
                }
            )
            
            Toggle(isOn: binding) {
                Label(label ?? tool.label, image: icon ?? tool.icon)
            }
            .toggleStyle(.button)
            .disabled(!validTools.contains(tool))
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
    
    private func isTool(_ tool: Tool, validFor templateAllowedTools: [Tool]) -> Bool {
        return templateAllowedTools.isEmpty
        || templateAllowedTools.flatMap(\.leafTools).contains(tool)
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
        let errorMessage = if selectableTools.contains(tool) {
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

private extension Label {
    init(_ title: String, image: Image) where Title == Text, Icon == Image {
        self.init(title: { Text(title) }, icon: { image })
    }
}

private extension Logger {
    static var geometryEditorToolbar: Logger {
        Logger(subsystem: "com.esri.ArcGISToolkit", category: "GeometryEditorToolbar")
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
            fatalError("Unknown ShapeTool.Kind: '\(self)'")
        }
    }
    
    var icon: Image {
        let systemName = switch self {
        case .arrow: "arrowshape.right"
        case .ellipse: "circle"    // TODO: Use ellipse image
        case .rectangle: "rectangle"
        case .triangle: "triangle"
        @unknown default:
            fatalError("Unknown ShapeTool.Kind: '\(self)'")
        }
        return Image(systemName: systemName)
    }
}
