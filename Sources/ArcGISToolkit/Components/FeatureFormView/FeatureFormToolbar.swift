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
    
    /// A binding to a Boolean value controlling whether the FeatureFormView is presented.
    @Environment(\.isPresented) var isPresented
    
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
                ToolbarItem(placement: .topBarLeading) {
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
                }
                if let group = featureFormViewModel.group {
                    let hasEdits = featureFormViewModel.formsWithEdits.contains(where: { $0.value })
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            if hasEdits {
                                Button("Discard Edits", role: .destructive) {
                                    featureFormViewModel.discardEdits()
                                }
                            }
                        } label: {
                            if hasEdits {
                                Image(systemName: "checkmark")
                            } else {
                                Image(systemName: "xmark")
                            }
                            Text(group.forms.count, format: .number)
                        } primaryAction: {
                            if hasEdits {
                                featureFormViewModel.finishEditing()
                            } else {
                                featureFormViewModel.discardEdits()
                            }
                        }
                    }
                } else if let isPresented {
                    ToolbarItem(placement: .topBarTrailing) {
                        DismissButton(kind: .cancel) {
                            if hasEdits {
                                stackViewModel.navigationAlertInfo = (false, {
                                    isPresented.wrappedValue = false
                                })
                            } else {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                }
                if (hasEdits && featureFormViewModel.editingButtonsVisibility == .automatic)
                    || (featureFormViewModel.editingButtonsVisibility == .visible) {
                    ToolbarItem(placement: .bottomBar) {
                        FormFooter(featureForm: featureForm)
                    }
                }
                if featureFormViewModel.group != nil {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            featureFormViewModel.selectPrevious()
                        } label: {
                            Label {} icon: {
                                Image(systemName: "chevron.left")
                            }
                        }
                        Button {
                            formManagerMenuIsPresented = true
                        } label: {
                            Text("Feature \(featureFormViewModel.selectedIndex + 1) of \(featureFormViewModel.count ?? -1)")
                        }
                        .popover(isPresented: $formManagerMenuIsPresented ) {
                            List {
                                ForEach(featureFormViewModel.ids, id: \.self) { id in
                                    if let form = featureFormViewModel.form(for: id),
                                       let objectID = form.feature.objectID {
                                        Button {
                                            featureFormViewModel.select(form: form, clearHistory: true)
                                            formManagerMenuIsPresented = false
                                        } label: {
                                            Label {
                                                Text("\(form.title) \(objectID.formatted(.number.grouping(.never)))")
                                            } icon: {
                                                if featureFormViewModel.selectedID == id {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                        .badge(form.elementValidationErrors.count)
                                        .badgeProminence(.increased)
                                    }
                                }
                            }
                            .frame(idealWidth: 400, idealHeight: 500)
                        }
                        Button {
                            featureFormViewModel.selectNext()
                        } label: {
                            Label {} icon: {
                                Image(systemName: "chevron.right")
                            }
                        }
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
