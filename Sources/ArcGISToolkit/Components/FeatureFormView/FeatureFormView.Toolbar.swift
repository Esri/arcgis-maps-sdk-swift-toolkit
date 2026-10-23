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
        @Environment(FeatureFormView.Model.self) var featureFormViewModel
        
        /// The model for the feature form.
        ///
        /// Optional as this toolbar is used in the group menu when no feature form is selected.
        @Environment(FeatureFormView.FormView.Model.self) var formViewModel: FeatureFormView.FormView.Model?
        
        /// A Boolean value indicating whether multi-form mode is active.
        ///
        /// Useful for animations to communicate that the component has transitioned to
        /// multi-form mode.
        @State private var delayedMultiFormModeActive = false
        
        func body(content: Content) -> some View {
            content
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: featureFormViewModel.activeFormCount, initial: false) {
                    Task {
                        // A small delay allows the group icon to come into view
                        // before we animate it.
                        try? await Task.sleep(for: .seconds(0.1))
                        delayedMultiFormModeActive = featureFormViewModel.multiFormModeIsActive
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if featureFormViewModel.showBackButton {
                            backButton
                        }
                    }
                    if #available(iOS 26.0, *) {
                        ToolbarSpacer(.flexible, placement: .topBarLeading)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        if featureFormViewModel.showDismissButton {
                            DismissButton(kind: .cancel) {
                                featureFormViewModel.discard()
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if featureFormViewModel.showGroupMenuButton {
                            groupMenuButton
                        } else if featureFormViewModel.showSaveButton {
                            saveButton
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        if featureFormViewModel.allValidationErrorsAreVisible,
                           let formViewModel, featureFormViewModel.geometryStatus[formViewModel.featureForm.feature.globalID!, default: .none] == .invalid {
                            Label {
                                Text("Invalid Geometry")
                            } icon: {
                                Image(systemName: "move.3d")
                                    .foregroundStyle(.red)
                                    .symbolEffect(.breathe.pulse.wholeSymbol, options: .repeat(.continuous))
                            }
                            .labelStyle(.titleAndIcon)
                        }
                    }
                }
        }
    }
}

private extension FeatureFormView.Toolbar /* Buttons */ {
    var backButton: some View {
        Button {
            featureFormViewModel.goBack()
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
    
    /// - Note: A plain image is used for the label so that symbol rendering mode
    /// `.multicolor` is applied correctly.
    var groupMenuButton: some View {
        Button {
            featureFormViewModel.clearSelection(clearBackStack: false)
        } label: {
            Image(systemName: featureFormViewModel.groupHasEdits ? "tray.badge" : "tray")
                .symbolEffect(.bounce, value: delayedMultiFormModeActive)
                .symbolRenderingMode(
                    featureFormViewModel.allValidationErrorsAreVisible
                    ? .multicolor
                    : .monochrome
                )
            
        }
    }
    
    var saveButton: some View {
        Button {
            featureFormViewModel.save()
        } label: {
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
        .disabled(!featureFormViewModel.groupHasEdits)
    }
}
