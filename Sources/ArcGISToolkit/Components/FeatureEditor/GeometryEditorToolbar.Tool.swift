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

public extension GeometryEditorToolbar {
    /// A tool that can be shown in the tools menu.
    enum Tool: Hashable {
        case freehand
        case programmaticReticle
        case shape(kind: ShapeTool.Kind)
        case vertex
        case vertexReticle
        
        var geometryEditorTool: GeometryEditorTool {
            switch self {
            case .freehand: FreehandTool()
            case .shape(let kind): ShapeTool(kind: kind)
            case .programmaticReticle: ProgrammaticReticleTool()
            case .vertex: VertexTool()
            case .vertexReticle: ReticleVertexTool()
            }
        }
        
        var label: LocalizedStringResource {
            switch self {
            case .freehand: "Freehand"
            case .programmaticReticle: "Programmatic Reticle"
            case .shape(let shape): shape.label
            case .vertex: "Vertex"
            case .vertexReticle: "Vertex Reticle"
            }
        }
        
        var systemImage: String {
            switch self {
            case .freehand: "scribble"
            case .programmaticReticle: "dot.viewfinder" // TODO: pick other symbol?
            case .shape(let shape): shape.systemImage
            case .vertex: "point.3.connected.trianglepath.dotted"
            case .vertexReticle: "dot.viewfinder"
            }
        }
    }
}

extension GeometryEditorToolbar.Tool: CaseIterable {
    public static var allCases: [GeometryEditorToolbar.Tool] {
        [
            .freehand,
            .programmaticReticle,
            vertex,
            .vertexReticle,
            .shape(kind: .arrow),
            .shape(kind: .ellipse),
            .shape(kind: .rectangle),
            .shape(kind: .triangle),
        ]
    }
}

struct ToolPicker: View {
    @Environment(\.geometryEditor) private var geometryEditor
    @Environment(\.labelPadding) private var labelPadding
    @Environment(\.tools) private var tools
    @Environment(\.selectedTool) private var externalSelectedTool
    
    @State private var geometry: Geometry?
    @State private var selectedTool: GeometryEditorToolbar.Tool = .vertex
    @State private var validTools: [GeometryEditorToolbar.Tool] = []
    
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
            .onChange(of: tools) {
                // Updates validTools when the external tools change.
                updateValidTools()
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
                
                // Needed to since the validTools contains the selectedTool.
                updateValidTools()
            }
            .task(id: ObjectIdentifier(geometryEditor)) {
                // Overwrites the geometry editor tool when the editor changes.
                geometryEditor.tool = selectedTool.geometryEditorTool
                
                for await geometry in geometryEditor.$geometry {
                    self.geometry = geometry
                    
                    // Updates the validTools when the geometry changes.
                    updateValidTools()
                    updateSelectedTool()
                }
            }
        }
    }
    
    /// Sets up the view's state when it appears.
    private func setUp() {
        updateValidTools()
        
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
        
        // Overwrites the geometry editor tool.
        geometryEditor.tool = selectedTool.geometryEditorTool
    }
    
    /// Updates the `validTools` based on the current geometry and `selectedTool`.
    private func updateValidTools() {
        validTools = if let geometry {
            tools.filter { tool in
                switch tool {
                case .freehand:
                    !(geometry is Point)
                case .shape:
                    tool == selectedTool || (geometry.isEmpty && !(geometry is Point))
                default:
                    true
                }
            }
        } else {
            tools
        }
    }
    
    /// Sets `selectedTool` to the first valid tools if it's current value is invalid.
    private func updateSelectedTool() {
        guard let firstValidTool = validTools.first, !validTools.contains(selectedTool) else {
            return
        }
        selectedTool = firstValidTool
    }
    
    /// Logs an error for an invalid `externalSelectedTool` value.
    private func logExternalSelectionError(tool: GeometryEditorToolbar.Tool) {
        let errorMessage = if tools.contains(tool){
            if let geometry {
                "Tool '\(tool)' is not valid for geometry type '\(type(of: geometry))'."
            } else {
                "Tool '\(tool)' is not valid for current geometry type."
            }
        } else {
            "Cannot set selected tool '\(tool)' if it is not included in supported tools."
        }
        Logger.geometryEditorToolbar.error("\(errorMessage)")
    }
}

// MARK: - Helper

private extension EnvironmentValues {
    @Entry var tools: [GeometryEditorToolbar.Tool] = [.vertex, .freehand, .vertexReticle]
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
        case .ellipse: "circle"
        case .rectangle: "rectangle"
        case .triangle: "triangle"
        @unknown default:
            fatalError("Unknown ShapeTool.Kind: '\(self)'")
        }
    }
}
