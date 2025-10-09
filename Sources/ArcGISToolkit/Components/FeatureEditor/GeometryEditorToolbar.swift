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
        placement: GeometryEditorToolbar.Placement = .overlay(alignment: .topTrailing, orientation: .vertical)
    ) -> some View {
        modifier(
            GeometryEditorToolbarModifier(geometryEditor: geometryEditor, placement: placement)
        )
    }
}

private struct GeometryEditorToolbarModifier: ViewModifier {
    let geometryEditor: GeometryEditor
    let placement: GeometryEditorToolbar.Placement
    
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
    enum Orientation {
        case vertical, horizontal
    }
    
    enum Placement {
        case overlay(alignment: Alignment, orientation: Orientation)
        case toolbar(placement: ToolbarItemPlacement = .automatic)
    }
    
    func orientation(_ orientation: Orientation?) -> Self {
        var copy = self
        copy.orientation = orientation
        return copy
    }
}


// MARK: - EmbeddedGeometryEditorToolbar

private struct EmbeddedGeometryEditorToolbar: View {
    let orientation: GeometryEditorToolbar.Orientation?
    
    private let padding = 6.0
    
    public var body: some View {
        switch orientation {
        case .vertical:
            VStack(spacing: 0) {
                Group {
                    ToolPicker()
                    DeleteButton()
                }
                .padding(.horizontal, padding)
                
                Divider()
                    .padding(.vertical, padding)
                
                Group {
                    UndoButton()
                    RedoButton()
                }
                .padding(.horizontal, padding)
            }
            .environment(\.labelPadding, padding)
            .padding(.vertical, padding)
            .stackStyle()
            
        case .horizontal:
            HStack(spacing: 0) {
                Group {
                    ToolPicker()
                    DeleteButton()
                }
                .padding(.vertical, padding)
                
                Divider()
                    .padding(.horizontal, padding)
                
                Group {
                    UndoButton()
                    RedoButton()
                }
                .padding(.vertical, padding)
            }
            .environment(\.labelPadding, padding)
            .padding(.horizontal, padding)
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
    @Environment(\.labelPadding) private var labelPadding
    
    var body: some View {
        Button {
            model.geometryEditor.undo()
        } label: {
            Label("Undo", systemImage: "arrow.uturn.backward")
                .padding(labelPadding)
        }
        .disabled(!model.canUndo)
    }
}
private struct RedoButton: View {
    @Environment(GeometryEditorModel.self) private var model
    @Environment(\.labelPadding) private var labelPadding
    
    var body: some View {
        Button {
            model.geometryEditor.redo()
        }  label: {
            Label("Redo", systemImage: "arrow.uturn.forward")
                .padding(labelPadding)
        }
        .disabled(!model.canRedo)
    }
}
private struct DeleteButton: View {
    @Environment(GeometryEditorModel.self) private var model
    @Environment(\.labelPadding) private var labelPadding
    
    var body: some View {
        Button {
            model.geometryEditor.deleteSelectedElement()
        } label: {
            Label("Delete Selected Element", systemImage: "circle.badge.minus")
                .padding(labelPadding)
        }
        .disabled(!model.canDeleteSelectedElement)
    }
}


// MARK: - Helper

extension EnvironmentValues {
    @Entry var labelPadding = 0.0
}

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
