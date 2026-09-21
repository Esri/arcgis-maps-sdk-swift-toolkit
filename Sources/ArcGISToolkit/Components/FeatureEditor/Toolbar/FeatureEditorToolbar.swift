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
    private let stackSpacing = 30.0
    /// The padding to apply to the long edges of the stacks containing the controls.
    /// This is hardcoded to match the system styling for toolbar groups on iOS.
    private let stackEdgePadding = 5.0
    
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
                            .toolbarStyle()
                        }
                        
                        VStack(spacing: stackSpacing) {
                            controls
                        }
                        .padding(.vertical, stackEdgePadding)
                        .toolbarStyle()
                    }
                case .horizontal:
                    VStack(spacing: stackSpacing) {
                        HStack(spacing: stackSpacing) {
                            controls
                        }
                        if model.state == .adding {
                            addingControls
                        }
                    }
                    .padding(stackEdgePadding)
                    .toolbarStyle()
                case .none:
                    VStack(spacing: stackSpacing) {
                        HStack(spacing: stackSpacing) {
                            controls
                        }
                        if model.state == .adding {
                            addingControls
                        }
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
                        .toolbarStyle()
                } else {
                    addButton
                }
            default:
                // No controls.
                EmptyView()
            }
        }
        .animation(.default, value: model.geometryEditorModel.isStarted)
        .alert(
            Text(
                "Discard Edits?",
                bundle: .toolkitModule,
                comment: "A question asking if the user would like to discard their unsaved edits."
            ),
            isPresented: $discardEditsAlertIsPresented
        ) {
            Button(role: .destructive, action: model.featureAddingModel.showTemplatePicker) {
                Text.discardEdits
            }
            Button(role: .cancel) {
                discardEditsAlertIsPresented = false
            } label: {
                Text.cancel
            }
        } message: {
            Text(
                "Geometry edits will be lost.",
                bundle: .toolkitModule,
                comment: "A message explaining that unsaved geometry edits will be lost if the user dismisses geometry construction."
            )
        }
    }
    
    /// The control views for the toolbar.
    @ViewBuilder private var controls: some View {
        if model.geometryEditorModel.selectableTools.count > 1 {
            ToolPicker()
        }
        DeleteButton()
        UndoButton()
        RedoButton()
        SnapSettingsButton()
    }
    
    /// The controls for completing or cancelling feature addition.
    @ViewBuilder private var addingControls: some View {
        AddingCancelButton {
            if model.featureAddingModel.hasGeometryEdits {
                discardEditsAlertIsPresented = true
            } else {
                model.featureAddingModel.showTemplatePicker()
            }
        }
        AddingSaveButton()
    }
}

// MARK: - Controls

/// A button for cancelling feature addition and returning to the template picker.
private struct AddingCancelButton: View {
    /// The action to perform when geometry construction is cancelled.
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text(
                    "Cancel",
                    bundle: .toolkitModule,
                    comment: "A button for cancelling geometry construction and returning to the feature template picker."
                )
            } icon: {
                Image(systemName: "xmark")
            }
        }
    }
}

/// A button for saving a newly constructed feature geometry.
private struct AddingSaveButton: View {
    /// The model for the parent feature editor containing the geometry editor.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    var body: some View {
        Button(action: featureEditorModel.featureAddingModel.saveGeometryConstruction) {
            Label {
                Text(
                    "Save",
                    bundle: .toolkitModule,
                    comment: "A button to save the new feature created from the selected template."
                )
            } icon: {
                Image(systemName: "checkmark")
            }
        }
        .disabled(featureEditorModel.geometryEditorModel.geometry?.sketchIsValid != true)
    }
}

/// A button for deleting the geometry editor's currently selected element.
private struct DeleteButton: View {
    /// The model for the parent feature editor containing the geometry editor.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    /// A Boolean value indicating whether the selected element can be deleted.
    @State private var canDeleteSelectedElement = false
    
    var body: some View {
        Button(action: featureEditorModel.geometryEditorModel.geometryEditor.deleteSelectedElement) {
            Label {
                Text(
                    "Delete Selected Element",
                    bundle: .toolkitModule,
                    comment: "A label for a button to delete the selected geometry editor element."
                )
            } icon: {
                Image(systemName: "circle.badge.minus")
            }
        }
        .disabled(!canDeleteSelectedElement)
        .task(id: ObjectIdentifier(featureEditorModel.geometryEditorModel.geometryEditor)) {
            for await selectedElement in featureEditorModel.geometryEditorModel.geometryEditor.$selectedElement {
                canDeleteSelectedElement = selectedElement?.canBeDeleted ?? false
            }
        }
    }
}

/// A button for redoing the geometry editor's last undone action.
private struct RedoButton: View {
    /// The model for the parent feature editor containing the geometry editor.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    /// A Boolean value indicating whether the geometry editor can redo an action.
    @State private var canRedo = false
    
    var body: some View {
        Button(action: featureEditorModel.geometryEditorModel.geometryEditor.redo) {
            Label {
                Text(
                    "Redo",
                    bundle: .toolkitModule,
                    comment: "A label for a button to redo the last undone geometry editor action."
                )
            } icon: {
                Image(systemName: "arrow.uturn.forward")
            }
        }
        .disabled(!canRedo)
        .task(id: ObjectIdentifier(featureEditorModel.geometryEditorModel.geometryEditor)) {
            for await canRedo in featureEditorModel.geometryEditorModel.geometryEditor.$canRedo {
                self.canRedo = canRedo
            }
        }
    }
}

/// A button for undoing the geometry editor's last action.
private struct UndoButton: View {
    /// The model for the parent feature editor containing the geometry editor.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    var body: some View {
        Button(action: featureEditorModel.geometryEditorModel.geometryEditor.undo) {
            Label {
                Text(
                    "Undo",
                    bundle: .toolkitModule,
                    comment: "A label for a button to undo the last geometry editor action."
                )
            } icon: {
                Image(systemName: "arrow.uturn.backward")
            }
        }
        .disabled(!featureEditorModel.geometryEditorModel.canUndo)
    }
}

/// A button for presenting a settings view for configuring snapping.
private struct SnapSettingsButton: View {
    /// The model for the parent feature editor containing the snap settings.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    var body: some View {
        Button {
            featureEditorModel.syncSnapSourceSettings()
            featureEditorModel.snapSettingsSheetIsPresented.toggle()
        } label: {
            Label {
                Text(
                    "Snap Settings",
                    bundle: .toolkitModule,
                    comment: "A label for a button to show settings for configuring snapping."
                )
            } icon: {
                Image(systemName: "gear")
            }
        }
    }
}

// MARK: - Helper

private extension View {
    /// Applies the shared styling used by the feature editor toolbar and its
    /// controls.
    @ViewBuilder
    func toolbarStyle() -> some View {
        // glassEffect is not used because it bases its background color on the content behind it,
        // but the ToolPicker does not, causing the color to jump when the picker menu closes.
        self.fixedSize()
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
