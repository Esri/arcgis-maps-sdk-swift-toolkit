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

/// A toolbar for the feature editor containing controls for performing common
/// geometry editor actions.
@available(visionOS, unavailable)
struct FeatureEditorToolbar: View {
    /// The style to apply to the toolbar's controls.
    let style: FeatureEditor.ToolbarStyle?
    
    /// The spacing to apply between the controls in the stacks.
    /// This is hardcoded to match the system styling for toolbar groups on iOS.
    private var stackSpacing: Double { 30 }
    /// The padding to apply to the long edges of the stacks containing the controls.
    /// This is hardcoded to match the system styling for toolbar groups on iOS.
    private var stackEdgePadding: Double { 5 }
    
    /// The model for the feature editor.
    @Environment(FeatureEditorModel.self) private var model
    
    /// A Boolean value indicating whether the discard edits alert is presented.
    @State private var discardEditsAlertIsPresented = false
    
    var body: some View {
        Group {
            switch model.state {
            case .adding where model.geometryEditorModel.isStarted,
                    .editing where model.geometryEditorModel.isStarted:
                switch style {
                case .vertical:
                    VStack {
                        if model.state == .adding {
                            VStack(spacing: stackSpacing) {
                                addingControls
                            }
                            .padding(.vertical, stackEdgePadding)
                            .toolbarStyle(style)
                        }
                        
                        VStack(spacing: stackSpacing) {
                            controls
                        }
                        .padding(.vertical, stackEdgePadding)
                        .toolbarStyle(style)
                    }
                case .horizontal:
                    HStack {
                        HStack(spacing: stackSpacing) {
                            controls
                        }
                        .padding(.horizontal, stackEdgePadding)
                        .toolbarStyle(style)
                        
                        if model.state == .adding {
                            HStack(spacing: stackSpacing) {
                                addingControls
                            }
                            .padding(.horizontal, stackEdgePadding)
                            .toolbarStyle(style)
                        }
                    }
                case .none:
                    controls
                    if model.state == .adding {
                        addingControls
                    }
                }
            case .stopped where model.supportsAddingFeatures:
                let addButton = Button(
                    LocalizedStringResource(
                        "Add Features",
                        bundle: .toolkitModule,
                        comment: "A label for a button to show a feature template picker."
                    ),
                    systemImage: "plus",
                    action: model.startAddingFeatures
                )
                if style != nil {
                    addButton
                        .toolbarStyle(style)
                } else {
                    addButton
                }
            default:
                // No controls.
                EmptyView()
            }
        }
        .animation(.default, value: model.state)
        .animation(.default, value: model.featureAddingModel.geometryConstructionState)
        .animation(.default, value: model.geometryEditorModel.isStarted)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("Feature Editor Toolbar")
    }
    
    /// The control views for the toolbar.
    @ViewBuilder private var controls: some View {
        let geometryEditorModel = model.geometryEditorModel
        let geometryEditor = model.geometryEditorModel.geometryEditor
        ToolPicker(model: geometryEditorModel)
        DeleteButton(geometryEditor: geometryEditor)
        UndoButton(model: geometryEditorModel)
        RedoButton(geometryEditor: geometryEditor)
        SnapSettingsButton(model: geometryEditorModel)
    }
    
    /// The controls for completing or cancelling feature addition.
    @ViewBuilder private var addingControls: some View {
        Button(
            LocalizedStringResource(
                "Save",
                bundle: .toolkitModule,
                comment: "A button to save the new features created from the selected template."
            ),
            systemImage: "checkmark",
            action: model.featureAddingModel.saveConstructedGeometry
        )
        .disabled(model.geometryEditorModel.geometry?.sketchIsValid == false)
        
        Group {
            if #available(iOS 26, *) {
                Button(role: .cancel, action: cancelConstruction)
            } else {
                Button(
                    LocalizedStringResource.cancel,
                    systemImage: "trash",
                    action: cancelConstruction
                )
            }
        }
        .confirmationDialog(
            Text(
                "Discard Edits?",
                bundle: .toolkitModule,
                comment: "A question asking if the user would like to discard their unsaved edits."
            ),
            isPresented: $discardEditsAlertIsPresented
        ) {
            Button.discard(action: model.featureAddingModel.cancelConstruction)
        } message: {
            Text(
                "Geometry edits will be lost.",
                bundle: .toolkitModule,
                comment: """
                    A message explaining that unsaved geometry edits will be \ 
                    lost if the user dismisses geometry construction.
                    """
            )
        }
    }
}

@available(visionOS, unavailable)
private extension FeatureEditorToolbar {
    /// Cancels geometry construction.
    ///
    /// If a geometry has already been constructed, a confirmation dialog is
    /// presented.
    func cancelConstruction() {
        if model.geometryEditorModel.hasGeometryEdits {
            discardEditsAlertIsPresented = true
        } else {
            model.featureAddingModel.cancelConstruction()
        }
    }
}

// MARK: - Controls

/// A button for deleting the geometry editor's currently selected element.
private struct DeleteButton: View {
    /// The geometry editor to be used by this button.
    let geometryEditor: GeometryEditor
    
    /// A Boolean value indicating whether the selected element can be deleted.
    @State private var canDeleteSelectedElement = false
    
    var body: some View {
        Button(
            LocalizedStringResource(
                "Delete Selected Element",
                bundle: .toolkit,
                comment: "A label for a button to delete the selected geometry editor element."
            ),
            systemImage: "circle.badge.minus",
            action: geometryEditor.deleteSelectedElement
        )
        .disabled(!canDeleteSelectedElement)
        .task(id: ObjectIdentifier(geometryEditor)) {
            for await selectedElement in geometryEditor.$selectedElement {
                canDeleteSelectedElement = selectedElement?.canBeDeleted ?? false
            }
        }
    }
}

/// A button for redoing the geometry editor's last undone action.
private struct RedoButton: View {
    /// The geometry editor to be used by this button.
    let geometryEditor: GeometryEditor
    
    /// A Boolean value indicating whether the geometry editor can redo an action.
    @State private var canRedo = false
    
    var body: some View {
        Button(
            LocalizedStringResource(
                "Redo",
                bundle: .toolkit,
                comment: "A label for a button to redo the last undone geometry editor action."
            ),
            systemImage: "arrow.uturn.forward",
            action: geometryEditor.redo
        )
        .disabled(!canRedo)
        .task(id: ObjectIdentifier(geometryEditor)) {
            for await canRedo in geometryEditor.$canRedo {
                self.canRedo = canRedo
            }
        }
    }
}

/// A button for undoing the geometry editor's last action.
private struct UndoButton: View {
    /// The geometry editor model used by this button.
    let model: GeometryEditorModel
    
    var body: some View {
        Button(
            LocalizedStringResource(
                "Undo",
                bundle: .toolkit,
                comment: "A label for a button to undo the last geometry editor action."
            ),
            systemImage: "arrow.uturn.backward",
            action: model.geometryEditor.undo
        )
        .disabled(!model.canUndo)
    }
}

/// A button for presenting a settings view for configuring snapping.
private struct SnapSettingsButton: View {
    /// The geometry editor model used by this button.
    let model: GeometryEditorModel
    
    var body: some View {
        Button(
            LocalizedStringResource(
                "Snap Settings",
                bundle: .toolkit,
                comment: "A label for a button to show settings for configuring snapping."
            ),
            systemImage: "gear"
        ) {
            model.syncSnapSourceSettings()
            model.snapSettingsAreBeingModified = true
        }
    }
}

// MARK: - Helper

private extension CGFloat {
    /// The minimum toolbar size in any dimension.
    static var minToolbarDiameter: Double {
#if targetEnvironment(macCatalyst)
        23
#else
        29
#endif
    }
}

@available(visionOS, unavailable)
private extension View {
    /// Applies the shared styling used by the feature editor toolbar and its
    /// controls.
    /// - Parameter style: The style of the toolbar.
    @ViewBuilder
    func toolbarStyle(_ style: FeatureEditor.ToolbarStyle?) -> some View {
        // glassEffect is not used because it bases its background color on the content behind it,
        // but the ToolPicker does not, causing the color to jump when the picker menu closes.
        self.fixedSize()
            .frame(
                width: style == .vertical ? .minToolbarDiameter : nil,
                height: style == .horizontal ? .minToolbarDiameter : nil
            )
            .frame(
                minWidth: style == .horizontal ? .minToolbarDiameter : nil,
                minHeight: style == .vertical ? .minToolbarDiameter : nil
            )
            .labelStyle(.iconOnly)
            .font(.title2)
            .buttonStyle(.borderless)
            .menuIndicator(.hidden)
            .padding(10)
            .background(.regularMaterial)
            .clipShape(.capsule)
            .shadow(radius: 1)
            .allowsHitTesting(true)
    }
}

@available(visionOS, unavailable)
#Preview {
    @Previewable @State var model = FeatureEditorModel()
    
    NavigationStack {
        MapView(map: Map(spatialReference: .wgs84))
            .geometryEditor(model.geometryEditorModel.geometryEditor)
            .overlay(alignment: .topTrailing) {
                FeatureEditorToolbar(style: .vertical)
                    .padding()
            }
            .overlay(alignment: .topLeading) {
                FeatureEditorToolbar(style: .horizontal)
                    .environment(\.colorScheme, .dark)
                    .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    FeatureEditorToolbar(style: nil)
                }
            }
            .environment(model)
            .task {
                model.geometryEditorModel.start(withType: Polygon.self)
                await model.geometryEditorModel.monitorStreams()
            }
    }
}
