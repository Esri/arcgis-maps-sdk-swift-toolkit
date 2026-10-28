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

extension View {
    func featureFormToolbar() -> some View {
        self.modifier(FeatureFormView.Toolbar())
    }
}

private extension FeatureFormView {
    struct Toolbar: ViewModifier {
        /// The model for the feature form view.
        @Environment(FeatureFormView.Model.self) var groupModel
        
        /// A Boolean value indicating whether multi-form mode is active.
        ///
        /// Useful for animations to communicate that the component has transitioned to
        /// multi-form mode.
        @State private var delayedMultiFormModeActive = false
        
        func body(content: Content) -> some View {
            content
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: groupModel.activeForms.count, initial: false) {
                    Task {
                        // A small delay allows the group icon to come into view
                        // before we animate it.
                        try? await Task.sleep(for: .seconds(0.1))
                        delayedMultiFormModeActive = groupModel.multiFormModeIsActive
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if groupModel.showBackButton {
                            backButton
                        }
                    }
                    if #available(iOS 26.0, *) {
                        ToolbarSpacer(.flexible, placement: .topBarLeading)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        if groupModel.showDismissButton {
                            DismissButton(kind: .cancel) {
                                groupModel.discard()
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if groupModel.showGroupMenuButton {
                            groupMenuButton
                        } else if groupModel.showSaveButton {
                            saveButton
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        if groupModel.showInvalidGeometryBadge {
                            invalidGeometryLabel
                        }
                    }
                }
        }
    }
}

private extension FeatureFormView.Toolbar /* Items */ {
    /// Navigates backward.
    ///
    /// This can either return a user to the previous view in the current form's
    /// navigation path or return them to the previous form they were on in the group.
    var backButton: some View {
        Button {
            groupModel.goBack()
        } label: {
            Label {
                Text(
                    "Back",
                    bundle: .toolkitModule,
                    comment: """
                        A generic label for a back button to returning to the \
                        previous screen.
                        """
                )
            } icon: {
                Image(systemName: "chevron.backward")
            }
        }
    }
    
    /// Opens the group menu.
    ///
    /// - Important: A solo image is used for the label so that symbol rendering mode
    /// `.multicolor` is applied consistently in a NavigationStack toolbar.
    var groupMenuButton: some View {
        Button {
            withAnimation {
                groupModel.clearSelection(clearBackStack: false)
            }
        } label: {
            Image(systemName: groupModel.groupHasEdits ? "tray.badge" : "tray")
                .symbolEffect(.bounce, value: delayedMultiFormModeActive)
                .symbolRenderingMode(
                    groupModel.allValidationErrorsAreVisible
                    ? .multicolor
                    : .monochrome
                )
        }
        .accessibilityLabel(
            Text(
                "Group Menu",
                bundle: .toolkitModule,
                comment: "A label for a button to open a menu with a list of items."
            )
        )
    }
    
    /// Indicates to the user that the current's feature geometry has been reported invalid.
    var invalidGeometryLabel: some View {
        Label {
            Text(
                "Invalid Geometry",
                bundle: .toolkitModule,
                comment: """
                    A label indicating that the geometry for the current \
                    feature has been reported invalid.
                    """
            )
        } icon: {
            Image(systemName: "move.3d")
                .foregroundStyle(.red)
                .symbolEffect(.breathe.pulse.wholeSymbol, options: .repeat(.continuous))
        }
        .labelStyle(.titleAndIcon)
    }
    
    /// Starts the sequence of events for saving the form(s).
    var saveButton: some View {
        Button {
            withAnimation {
                groupModel.save()
            }
        } label: {
            if groupModel.isSaving {
                ProgressView()
            } else {
                Label {
                    Text(
                        "Save",
                        bundle: .toolkitModule,
                        comment: "Finish editing the feature form."
                    )
                } icon: {
                    Image(systemName: "checkmark")
                }
            }
        }
        .disabled(!groupModel.groupHasEdits)
    }
}
