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
    
    var body: some View {
        Group {
            if model.geometryEditorIsStarted {
                switch style {
                case .vertical:
                    VStack(spacing: stackSpacing) {
                        controls
                    }
                    .padding(.vertical, stackEdgePadding)
                    .toolbarStackStyle()
                case .horizontal:
                    HStack(spacing: stackSpacing) {
                        controls
                    }
                    .padding(.horizontal, stackEdgePadding)
                    .toolbarStackStyle()
                case nil:
                    controls
                }
            }
        }
        .animation(.default, value: model.geometryEditorIsStarted)
    }
    
    /// The control views for the toolbar.
    @ViewBuilder private var controls: some View {
        ToolPicker()
        DeleteButton()
        UndoButton()
        RedoButton()
        SnapSettingsButton()
    }
}

// MARK: - Controls

/// A button for deleting the geometry editor's currently selected element.
private struct DeleteButton: View {
    /// The model for the parent feature editor containing the geometry editor.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    /// A Boolean value indicating whether the selected element can be deleted.
    @State private var canDeleteSelectedElement = false
    
    var body: some View {
        Button(action: featureEditorModel.geometryEditor.deleteSelectedElement) {
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
        .task(id: ObjectIdentifier(featureEditorModel.geometryEditor)) {
            for await selectedElement in featureEditorModel.geometryEditor.$selectedElement {
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
        Button(action: featureEditorModel.geometryEditor.redo) {
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
        .task(id: ObjectIdentifier(featureEditorModel.geometryEditor)) {
            for await canRedo in featureEditorModel.geometryEditor.$canRedo {
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
        Button(action: featureEditorModel.geometryEditor.undo) {
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
        .disabled(!featureEditorModel.geometryEditorCanUndo)
    }
}

/// A button for presenting a settings view for configuring snapping.
private struct SnapSettingsButton: View {
    /// The model for the parent feature editor containing the snap settings.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    /// A Boolean value indicating whether the settings view is presented.
    @State private var isShowingSettings = false
    
    var body: some View {
        Button {
            featureEditorModel.syncSnapSourceSettings()
            isShowingSettings.toggle()
        } label: {
            Label {
                Text(
                    "Settings",
                    bundle: .toolkitModule,
                    comment: "A label for a button to show settings for configuring snapping."
                )
            } icon: {
                Image(systemName: "gear")
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SnapSettingsView(settings: featureEditorModel.geometryEditor.snapSettings)
            // Needed to override the font set in toolbarStackStyle.
                .font(nil)
        }
    }
}

// MARK: - Helper

private extension View {
    /// Applies the shared styling used by the vertical and horizontal stacks
    /// in a `FeatureEditorToolbar`.
    @ViewBuilder
    func toolbarStackStyle() -> some View {
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
            .geometryEditor(model.geometryEditor)
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
                model.geometryEditor.start(withType: Polygon.self)
                await model.monitorGeometryEditorStreams()
            }
    }
}
