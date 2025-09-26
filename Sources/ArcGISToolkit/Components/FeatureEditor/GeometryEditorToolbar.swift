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
import SwiftUI


// MARK: - GeometryEditorToolbarModifier

public extension View {
    @ViewBuilder
    func geometryEditorToolbar(
        geometryEditor: GeometryEditor,
        placement: GeometryEditorToolbarPlacement = .overlay(alignment: .topTrailing, orientation: .vertical)
    ) -> some View {
        modifier(
            GeometryEditorToolbarModifier(geometryEditor: geometryEditor, placement: placement)
        )
    }
}

public enum GeometryEditorToolbarPlacement {
    case overlay(alignment: Alignment, orientation: Orientation)
    case toolbar(placement: ToolbarItemPlacement = .automatic)
}

public enum Orientation {
    case vertical, horizontal
}

private struct GeometryEditorToolbarModifier: ViewModifier {
    let geometryEditor: GeometryEditor
    let placement: GeometryEditorToolbarPlacement
    
    @State private var model = GeometryEditorModel()
    
    func body(content: Content) -> some View {
        Group {
            switch placement {
            case .overlay(let alignment, let orientation):
                content
                    .overlay(alignment: alignment) {
                        if model.isStarted {
                            EmbeddedGeometryEditorToolbar(orientation: orientation)
                                .environment(model)
                                .padding()
                        }
                    }
            case .toolbar(let placement):
                content
                    .toolbar {
                        if model.isStarted {
                            ToolbarItemGroup(placement: placement) {
                                EmbeddedGeometryEditorToolbar(orientation: nil)
                                    .environment(model)
                            }
                        }
                    }
            }
        }
        .animation(.default, value: model.isStarted)
        .task(id: ObjectIdentifier(geometryEditor)) {
            model.geometryEditor = geometryEditor
            await model.monitorStreams()
        }
    }
}


// MARK: - GeometryEditorToolbar

/// - Note: View will be displayed when the geometry editor starts...
public struct GeometryEditorToolbar: View {
    let geometryEditor: GeometryEditor
    
    private var orientation: Orientation? = .vertical
    
    @State private var model = GeometryEditorModel()
    
    public init(geometryEditor: GeometryEditor) {
        self.geometryEditor = geometryEditor
    }
    
    public var body: some View {
        Group {
            if model.isStarted {
                EmbeddedGeometryEditorToolbar(orientation: orientation)
                    .environment(model)
            } else {
                Color.clear
                    .frame(width: 0, height: 0)
            }
        }
        .animation(.default, value: model.isStarted)
        .task(id: ObjectIdentifier(geometryEditor)) {
            model.geometryEditor = geometryEditor
            await model.monitorStreams()
        }
    }
}

public extension GeometryEditorToolbar {
    func orientation(_ orientation: Orientation?) -> Self {
        var copy = self
        copy.orientation = orientation
        return copy
    }
}

// MARK: - EmbeddedGeometryEditorToolbar

private struct EmbeddedGeometryEditorToolbar: View {
    let orientation: Orientation?
    
    private let controlPadding = 12.0
    
    public var body: some View {
        switch orientation {
        case .vertical:
            VStack(spacing: controlPadding) {
                ToolPicker()
                    .padding(.horizontal, controlPadding)
                DeleteButton()
                    .padding(.horizontal, controlPadding)
                Divider()
                UndoButton()
                    .padding(.horizontal, controlPadding)
                RedoButton()
                    .padding(.horizontal, controlPadding)
            }
            .padding(.vertical, controlPadding)
            .stackStyle()
            
        case .horizontal:
            HStack(spacing: controlPadding) {
                ToolPicker()
                    .padding(.vertical, controlPadding)
                DeleteButton()
                    .padding(.vertical, controlPadding)
                Divider()
                UndoButton()
                    .padding(.vertical, controlPadding)
                RedoButton()
                    .padding(.vertical, controlPadding)
            }
            .padding(.horizontal, controlPadding)
            .stackStyle()
            
        case nil:
            ToolPicker()
            DeleteButton()
            UndoButton()
            RedoButton()
        }
    }
}

// MARK: - Components

private struct UndoButton: View {
    @Environment(GeometryEditorModel.self) private var model
    
    var body: some View {
        Button("Undo", systemImage: "arrow.uturn.backward") {
            model.geometryEditor.undo()
        }
        .disabled(!model.canUndo)
    }
}
private struct RedoButton: View {
    @Environment(GeometryEditorModel.self) private var model
    
    var body: some View {
        Button("Redo", systemImage: "arrow.uturn.forward") {
            model.geometryEditor.redo()
        }
        .disabled(!model.canRedo)
    }
}
private struct DeleteButton: View {
    @Environment(GeometryEditorModel.self) private var model
    
    var body: some View {
        Button("Delete Selected Element", systemImage: "circle.badge.minus") {
            model.geometryEditor.deleteSelectedElement()
        }
        .disabled(!model.canDeleteSelectedElement)
    }
}

private struct ToolPicker: View {
    @Environment(GeometryEditorModel.self) private var model
    
    @State private var selectedTool = Tool.vertex
    
    private var toolOptions: [Tool] {
        model.geometryType == Point.self ? [.vertex, .reticle] : Tool.allCases
    }
    
    var body: some View {
        Menu("Tool", systemImage: selectedTool.systemImage) {
            Picker("Tool", systemImage: "wrench.and.screwdriver", selection: $selectedTool) {
                ForEach(toolOptions, id: \.self) { tool in
                    Label(tool.label, systemImage: tool.systemImage)
                }
            }
        }
        .onChange(of: selectedTool) {
            model.geometryEditor.tool = selectedTool.geometryEditorTool
        }
        .onChange(of: ObjectIdentifier(model.geometryEditor), initial: true) {
            // Sets the selected tool based on the current geometry editor tool.
            let tool = Tool(geometryEditorTool:  model.geometryEditor.tool) ?? .vertex
            selectedTool = toolOptions.contains(tool) ? tool : toolOptions.first!
            
            // Overwrites developer set tool with a default.
            model.geometryEditor.tool = selectedTool.geometryEditorTool
        }
    }
    
    private enum Tool: CaseIterable {
        case vertex, freehand, reticle
        
        init?(geometryEditorTool: GeometryEditorTool) {
            switch geometryEditorTool {
            case is VertexTool:
                self = .vertex
            case is FreehandTool:
                self = .freehand
            case is ReticleVertexTool:
                self = .reticle
            default:
                return nil
            }
        }
        
        var geometryEditorTool: GeometryEditorTool {
            switch self {
            case .vertex: VertexTool()
            case .freehand: FreehandTool()
            case .reticle: ReticleVertexTool()
            }
        }
        
        var label: String {
            switch self {
            case .vertex: "Vertex"
            case .freehand: "Freehand"
            case .reticle: "Reticle"
            }
        }
        
        var systemImage: String {
            switch self {
            case .vertex: "point.3.connected.trianglepath.dotted"
            case .freehand: "scribble"
            case .reticle: "dot.viewfinder"
            }
        }
    }
}

// MARK: - Helper

private extension View {
    func stackStyle() -> some View {
        self.fixedSize()
            .labelStyle(.iconOnly)
            .tint(.secondary)
            .background()
            .clipShape(.rect(cornerRadius: 8))
            .shadow(radius: 1)
    }
}
