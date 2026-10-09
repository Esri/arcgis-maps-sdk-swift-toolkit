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
    func featureFormToolbar(_ featureForm: FeatureForm, isAForm: Bool = false, onBackNavigation: (() -> Void)? = nil) -> some View {
        self.modifier(FeatureFormToolbar(featureForm: featureForm, isAForm: isAForm, onBackNavigation: onBackNavigation))
    }
}

struct FeatureFormToolbar: ViewModifier {
    @Environment(\.dismiss) var dismiss
    
    /// <#Description#>
    @Environment(FeatureFormView.Model.self) var featureFormViewModel
    
    /// The model for the stack view containing the form.
    @Environment(FeatureFormView.StackView.Model.self) var stackViewModel
    
    /// A Boolean value indicating whether the presented feature form has edits.
    @State private var hasEdits = false
    
    /// <#Description#>
    @State private var formManagerMenuIsPresented = false
    
    /// The currently presented feature form.
    let featureForm: FeatureForm
    
    /// A Boolean value indicating whether the modified view is a feature form view or another type of
    /// associated view such as a `UtilityAssociationsFilterResultView` or
    /// `UtilityAssociationGroupResultView`.
    let isAForm: Bool
    
    /// A closure to perform when back navigation completes.
    let onBackNavigation: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden()
            .task(id: featureForm.feature.globalID) {
                for await hasEdits in featureForm.$hasEdits {
                    withAnimation { self.hasEdits = hasEdits }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    if isRootView, featureFormViewModel.group != nil, featureFormViewModel.canGoBack {
                        Button {
                            featureFormViewModel.navigateBack()
                        } label: {
                            Label {
                                Text(
                                    "Back",
                                    bundle: .toolkitModule,
                                    comment: "A generic label for navigating to the previous screen or returning to the previous context."
                                )
                            } icon: {
                                Image(systemName: "chevron.backward")
                            }
                        }
                    } else if !isRootView {
                        Button {
                            if alertBeforeDismissing {
                                stackViewModel.navigationAlertInfo = (true, {
                                    dismiss()
                                    onBackNavigation?()
                                })
                            } else {
                                dismiss()
                                onBackNavigation?()
                            }
                        } label: {
                            Label {
                                Text(
                                    "Back",
                                    bundle: .toolkitModule,
                                    comment: "A generic label for navigating to the previous screen or returning to the previous context."
                                )
                            } icon: {
                                Image(systemName: "chevron.backward")
                            }
                        }
                        .disabled(featureFormViewModel.navigationIsDisabled)
                    }
                    if featureFormViewModel.isPresented != nil {
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
                    if featureFormViewModel.group?.forms.count ?? 0 > 1 {
                        Button {
                            featureFormViewModel.clearSelection()
                        } label: {
                            Image(systemName: "house")
                        }
                    } else if (featureFormViewModel.editingButtonsVisibility == .automatic)
                                || (featureFormViewModel.editingButtonsVisibility == .visible) {
                        Button {
                            if featureForm.elementValidationErrors.isEmpty {
                                Task {
                                    do {
                                        try await featureForm.finishEditing()
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

extension FeatureFormToolbar {
    /// A Boolean value indicating whether to alert for unsaved edits before dismissing the current view.
    var alertBeforeDismissing: Bool {
        isAForm && hasEdits
    }
    
    /// A Boolean value indicating if this toolbar is applied to the NavigationStack's root view.
    var isRootView: Bool {
        stackViewModel.navigationPath.isEmpty
    }
}
