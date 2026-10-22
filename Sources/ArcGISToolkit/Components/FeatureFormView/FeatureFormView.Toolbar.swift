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

extension FeatureFormView {
    fileprivate struct Toolbar: ViewModifier {
        /// <#Description#>
        @Environment(FeatureFormView.Model.self) var featureFormViewModel
        
        /// The model for the stack view containing the form.
        @Environment(FeatureFormView.StackView.Model.self) var stackViewModel
        
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
                        if isRootView, featureFormViewModel.canGoBack {
                            Button {
                                featureFormViewModel.navigateBack()
                            } label: {
                                Label {
                                    Text(
                                        "Back",
                                        bundle: .toolkitModule,
                                        comment: """
                                        A generic label for navigating \
                                        to the previous screen or returning to the \
                                        previous context.
                                        """
                                    )
                                } icon: {
                                    Image(systemName: "chevron.backward")
                                }
                            }
                        } else if !isRootView {
                            Button {
                                stackViewModel.navigationPath.removeLast()
                            } label: {
                                Label {
                                    Text(
                                        "Back",
                                        bundle: .toolkitModule,
                                        comment: """
                                        A generic label for navigating to the \
                                        previous screen or returning to the \
                                        previous context.
                                        """
                                    )
                                } icon: {
                                    Image(systemName: "chevron.backward")
                                }
                            }
                            .disabled(featureFormViewModel.navigationIsDisabled)
                        }
                    }
                    if #available(iOS 26.0, *) {
                        ToolbarSpacer(.flexible, placement: .topBarLeading)
                    }
                    if featureFormViewModel.isPresented != nil,
                        !featureFormViewModel.multiFormModeIsActive {
                        ToolbarItem(placement: .topBarLeading) {
                            DismissButton(kind: .cancel) {
                                if hasEdits {
                                    stackViewModel.navigationAlertInfo = (false, {
                                        featureFormViewModel.isPresented = false
                                    })
                                } else {
                                    featureFormViewModel.isPresented = false
                                }
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if featureFormViewModel.multiFormModeIsActive {
                            Button {
                                featureFormViewModel.clearSelection(clearBackStack: false)
                            } label: {
                                Image(systemName: hasEdits ? "tray.badge" : "tray")
                                    .symbolEffect(.bounce, value: delayedMultiFormModeActive)
                                    .symbolRenderingMode(hasErrors ? .multicolor : .monochrome)
                            }
                        } else if (featureFormViewModel.editingButtonsVisibility == .automatic)
                                    || (featureFormViewModel.editingButtonsVisibility == .visible) {
                            Button {
                                if hasErrors {
                                    Task {
                                        do {
                                            try await featureFormViewModel.finishEditing()
                                            featureFormViewModel.onFormEditingEventAction?(.savedEdits(willNavigate: false))
                                        } catch {
                                            stackViewModel.finishEditingError = error
                                        }
                                    }
                                } else {
                                    stackViewModel.validationErrorVisibilityInternal = .visible
                                    stackViewModel.navigationAlertInfo = (false, {})
                                }
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
                            .disabled(!hasEdits)
                        }
                    }
                }
        }
    }
}

extension FeatureFormView.Toolbar {
    /// <#Description#>
    var hasEdits: Bool {
        featureFormViewModel.formsWithEdits.contains(where: { $0.value })
    }
    
    /// <#Description#>
    var hasErrors: Bool {
        featureFormViewModel.formsWithErrors.contains(where: { $0.value > 0 })
    }
    
    /// A Boolean value indicating if this toolbar is applied to the NavigationStack's root view.
    var isRootView: Bool {
        stackViewModel.navigationPath.isEmpty
    }
}
