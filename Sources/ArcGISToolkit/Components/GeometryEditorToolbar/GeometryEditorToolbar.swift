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

/// A group of controls for interacting with a geometry editor.
/// - Note: The view will be displayed when the geometry editor is started.
public struct GeometryEditorToolbar: View {
    /// The geometry editor that this toolbar controls.
    private let geometryEditor: GeometryEditor
    /// The layout to apply to the controls.
    private let layout: Layout?
    
    /// The view model for the view.
    @State private var model: GeometryEditorToolbarModel
    
    /// Creates a geometry editor toolbar view.
    /// - Parameters:
    ///   - geometryEditor: The geometry editor that this toolbar controls.
    ///   - layout: The layout to apply to the controls. A `nil` value renders
    ///   the controls without built-in layout or styling.
    public init(geometryEditor: GeometryEditor, layout: Layout? = .vertical) {
        self.geometryEditor = geometryEditor
        self.layout = layout
        
        let model = GeometryEditorToolbarModel(geometryEditor: geometryEditor)
        self._model = .init(wrappedValue: model)
    }
    
    public var body: some View {
        Group {
            if model.isStarted {
                switch layout {
                case .vertical:
                    VStack { controls }
                        .stackStyle()
                case .horizontal:
                    HStack { controls }
                        .stackStyle()
                case nil:
                    controls
                }
            }
        }
        .environment(model)
        .animation(.default, value: model.isStarted)
        .onChange(of: ObjectIdentifier(geometryEditor)) {
            model = GeometryEditorToolbarModel(geometryEditor: geometryEditor)
        }
    }
    
    /// The control views for the toolbar.
    @ViewBuilder
    private var controls: some View {
        ToolPicker()
        DeleteButton()
        UndoButton()
        RedoButton()
    }
}

/// The view model for the geometry editor toolbar.
@MainActor
@Observable
final class GeometryEditorToolbarModel {
    /// The geometry editor that the toolbar controls.
    let geometryEditor: GeometryEditor
    
    /// A Boolean value indicating whether the geometry editor has started.
    private(set) var isStarted = false
    
    /// A task that observes the geometry editor's `isStarted` stream.
    @ObservationIgnored private var isStartedTask: Task<Void, Never>?
    
    init(geometryEditor: GeometryEditor) {
        self.geometryEditor = geometryEditor
        
        isStartedTask = Task { @MainActor [weak self] in
            for await isStarted in geometryEditor.$isStarted {
                self?.isStarted = isStarted
            }
        }
    }
    
    deinit {
        isStartedTask?.cancel()
    }
}

public extension GeometryEditorToolbar {
    /// The layout of the geometry editor toolbar's controls.
    enum Layout {
        /// The controls arranged in a vertical stack.
        case vertical
        /// The controls arranged in a horizontal stack.
        case horizontal
    }
}

// MARK: - Controls

/// A button for deleting the geometry editor's currently selected element.
private struct DeleteButton: View {
    /// The model for the parent geometry editor toolbar.
    @Environment(GeometryEditorToolbarModel.self) private var model
    
    /// A Boolean value indicating whether the selected element can be deleted.
    @State private var canDeleteSelectedElement = false
    
    var body: some View {
        Button(action: model.geometryEditor.deleteSelectedElement) {
            Label("Delete Selected Element", systemImage: "circle.badge.minus")
                .geometryEditorToolbarControlPadding()
        }
        .disabled(!canDeleteSelectedElement)
        .task(id: ObjectIdentifier(model)) {
            for await selectedElement in model.geometryEditor.$selectedElement {
                canDeleteSelectedElement = selectedElement?.canBeDeleted ?? false
            }
        }
    }
}

/// A button for redoing the geometry editor's last undone action.
private struct RedoButton: View {
    /// The model for the parent geometry editor toolbar.
    @Environment(GeometryEditorToolbarModel.self) private var model
    
    /// A Boolean value indicating whether the geometry editor can redo an action.
    @State private var canRedo = false
    
    var body: some View {
        Button(action: model.geometryEditor.redo) {
            Label("Redo", systemImage: "arrow.uturn.forward")
                .geometryEditorToolbarControlPadding()
        }
        .disabled(!canRedo)
        .task(id: ObjectIdentifier(model)) {
            for await canRedo in model.geometryEditor.$canRedo {
                self.canRedo = canRedo
            }
        }
    }
}

/// A button for undoing the geometry editor's last action.
private struct UndoButton: View {
    /// The model for the parent geometry editor toolbar.
    @Environment(GeometryEditorToolbarModel.self) private var model
    
    /// A Boolean value indicating whether the geometry editor can undo an action.
    @State private var canUndo = false
    
    var body: some View {
        Button(action: model.geometryEditor.undo) {
            Label("Undo", systemImage: "arrow.uturn.backward")
                .geometryEditorToolbarControlPadding()
        }
        .disabled(!canUndo)
        .task(id: ObjectIdentifier(model)) {
            for await canUndo in model.geometryEditor.$canUndo {
                self.canUndo = canUndo
            }
        }
    }
}

// MARK: - Extensions

extension View {
    /// Adds padding used to increase a `GeometryEditorToolbar` control's hit box size.
    func geometryEditorToolbarControlPadding() -> some View {
        padding(8.5)
    }
}

private extension View {
    /// A view modifier that applies styles to the vertical and horizontal stacks in `GeometryEditorToolbar`.
    @ViewBuilder
    func stackStyle() -> some View {
        // glassEffect is not used because it bases its background color on the content behind it,
        // but the ToolPicker does not, causing the color to jump when the picker menu closes.
        self.fixedSize()
            .labelStyle(.iconOnly)
            .font(.title2)
            .background(.regularMaterial)
            .clipShape(.capsule)
            .shadow(radius: 1)
    }
}
