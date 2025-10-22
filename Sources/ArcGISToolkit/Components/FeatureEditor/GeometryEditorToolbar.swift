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
        isPresented: Binding<Bool>? = nil,
        placement: GeometryEditorToolbar.Placement = .overlay(alignment: .topTrailing, orientation: .vertical)
    ) -> some View {
        modifier(
            GeometryEditorToolbarModifier(
                geometryEditor: geometryEditor,
                isPresented: isPresented,
                placement: placement
            )
        )
    }
}

private struct GeometryEditorToolbarModifier: ViewModifier {
    let geometryEditor: GeometryEditor
    let isPresented: Binding<Bool>?
    let placement: GeometryEditorToolbar.Placement
    
    @State private var isStarted = false
    
    func body(content: Content) -> some View {
        Group {
            // TODO: will changing placement reload parent view?
            switch placement {
            case .overlay(let alignment, let orientation):
                content
                    .overlay(alignment: alignment) {
                        if isPresented?.wrappedValue ?? isStarted {
                            EmbeddedGeometryEditorToolbar(orientation: orientation)
                                .padding()
                        }
                    }
            case .toolbar(let placement):
                content
                    .toolbar {
                        if isPresented?.wrappedValue ?? isStarted {
                            ToolbarItemGroup(placement: placement) {
                                EmbeddedGeometryEditorToolbar(orientation: nil)
                            }
                        }
                    }
            }
        }
        .environment(\.geometryEditor, geometryEditor)
        .task(id: ObjectIdentifier(geometryEditor)) {
            guard isPresented == nil else { return }
            
            await geometryEditor.onIsStartedChanged { isStarted in
                withAnimation {
                    self.isStarted = isStarted
                }
            }
        }
    }
}


// MARK: - GeometryEditorToolbar

/// - Note: View will be displayed when the geometry editor starts...
public struct GeometryEditorToolbar: View {
    private let geometryEditor: GeometryEditor
    private let isPresented: Binding<Bool>?
    
    public init(geometryEditor: GeometryEditor, isPresented: Binding<Bool>? = nil) {
        self.geometryEditor = geometryEditor
        self.isPresented = isPresented
    }
    
    private var orientation: Orientation? = .vertical
    
    @State private var isStarted = false
    
    public var body: some View {
        Group {
            if isPresented?.wrappedValue ?? isStarted {
                EmbeddedGeometryEditorToolbar(orientation: orientation)
                    .environment(\.geometryEditor, geometryEditor)
            } else {
                Color.clear
                    .frame(width: 0, height: 0)
            }
        }
        .task(id: ObjectIdentifier(geometryEditor)) {
            guard isPresented == nil else { return }
            
            await geometryEditor.onIsStartedChanged { isStarted in
                withAnimation {
                    self.isStarted = isStarted
                }
            }
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
    /// The geometry editor from the parent geometry editor toolbar.
    @Environment(\.geometryEditor) private var geometryEditor
    
    /// The padding to add to the buttons's label. This is need to increase the hit box size.
    @Environment(\.labelPadding) private var labelPadding
    
    @State private var canUndo = false
    
    var body: some View {
        Button(action: geometryEditor.undo) {
            Label("Undo", systemImage: "arrow.uturn.backward")
                .padding(labelPadding)
        }
        .disabled(!canUndo)
        .task(id: ObjectIdentifier(geometryEditor)) {
            for await canUndo in self.geometryEditor.$canUndo {
                self.canUndo = canUndo
            }
        }
    }
}

private struct RedoButton: View {
    /// The geometry editor from the parent geometry editor toolbar.
    @Environment(\.geometryEditor) private var geometryEditor
    
    /// The padding to add to the buttons's label. This is need to increase the hit box size.
    @Environment(\.labelPadding) private var labelPadding
    
    @State private var canRedo = false
    
    var body: some View {
        Button(action: geometryEditor.redo) {
            Label("Redo", systemImage: "arrow.uturn.forward")
                .padding(labelPadding)
        }
        .disabled(!canRedo)
        .task(id: ObjectIdentifier(geometryEditor)) {
            for await canRedo in geometryEditor.$canRedo {
                self.canRedo = canRedo
            }
        }
    }
}

private struct DeleteButton: View {
    /// The geometry editor from the parent geometry editor toolbar.
    @Environment(\.geometryEditor) private var geometryEditor
    
    /// The padding to add to the buttons's label. This is need to increase the hit box size.
    @Environment(\.labelPadding) private var labelPadding
    
    @State private var canDeleteSelectedElement = false
    
    var body: some View {
        Button(action: geometryEditor.deleteSelectedElement) {
            Label("Delete Selected Element", systemImage: "circle.badge.minus")
                .padding(labelPadding)
        }
        .disabled(!canDeleteSelectedElement)
        .task(id: ObjectIdentifier(geometryEditor)) {
            for await selectedElement in self.geometryEditor.$selectedElement {
                canDeleteSelectedElement = selectedElement?.canBeDeleted ?? false
            }
        }
    }
}


// MARK: - Helper

extension EnvironmentValues {
    /// The geometry editor for the geometry editor toolbar.
    @Entry var geometryEditor = GeometryEditor()
    
    /// The amount of padding to add to a control's label. This is need to increase the hit box size.
    @Entry var labelPadding = 0.0
}

private extension GeometryEditor {
    /// Monitors `$isStarted` and performs an action when a new value is produced.
    /// - Parameter action: The closure to run when `isStarted` changes.
    @MainActor
    func onIsStartedChanged(perform action: @MainActor @escaping @Sendable (Bool) -> Void) async {
        var debounceTask: Task<Void, Never>?
        
        for await isStarted in $isStarted {
            debounceTask?.cancel()
            debounceTask = Task {
                do {
                    // Debounces when isStarted is going from true -> false. This is needed because
                    // isStarted will quickly go from true -> false -> true when the editor is
                    // restarted, which causes flickering and other issues when used to update UI.
                    if !isStarted {
                        try await Task.sleep(for: .seconds(0.1))
                    }
                    action(isStarted)
                } catch {
                    // Skips running the action if the task was cancelled during the debounce.
                }
            }
        }
    }
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
