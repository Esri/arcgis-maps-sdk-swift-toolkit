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
    
    /// The visibility of the "save" and "discard" buttons.
    @Environment(\.editingButtonVisibility) var editingButtonsVisibility
    
    /// <#Description#>
    @Environment(FeatureFormGroupView.Model.self) var groupViewModel: FeatureFormGroupView.Model?
    /// The model for the stack view containing the form.
    @Environment(FeatureFormView.StackView.Model.self) var stackViewModel
    
    /// A binding to a Boolean value controlling whether the FeatureFormView is presented.
    @Environment(\.isPresented) var isPresented
    
    /// The environment value which declares whether navigation to forms for features associated via utility association form elements is disabled.
    @Environment(\.navigationIsDisabled) var navigationIsDisabled
    
    /// The closure to perform when a ``EditingEvent`` occurs.
    @Environment(\.onFormEditingEventAction) var onFormEditingEventAction
    
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
                    if isRootView, let groupViewModel, groupViewModel.canGoBack {
                        Button {
                            groupViewModel.navigateBack()
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
                        .disabled(navigationIsDisabled)
                    }
                }
                if let groupViewModel {
                    let hasEdits = groupViewModel.formsWithEdits.contains(where: { $0.value })
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            if hasEdits {
                                Button("Discard Edits", role: .destructive) {
                                    groupViewModel.discardEdits()
                                }
                            }
                        } label: {
                            if hasEdits {
                                Image(systemName: "checkmark")
                            } else {
                                Image(systemName: "xmark")
                            }
                            Text(groupViewModel.group.forms.count, format: .number)
                        } primaryAction: {
                            if hasEdits {
                                groupViewModel.finishEditing()
                            } else {
                                groupViewModel.discardEdits()
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
                if (hasEdits && editingButtonsVisibility == .automatic)
                    || (editingButtonsVisibility == .visible) {
                    ToolbarItem(placement: .bottomBar) {
                        FormFooter(
                            featureForm: featureForm,
                            formHandlingEventAction: onFormEditingEventAction
                        )
                    }
                }
                if let groupViewModel {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            groupViewModel.selectPrevious()
                        } label: {
                            Label {} icon: {
                                Image(systemName: "chevron.left")
                            }
                        }
                        Button {
                            formManagerMenuIsPresented = true
                        } label: {
                            Text("Feature \(groupViewModel.selectedIndex + 1) of \(groupViewModel.count)")
                        }
                        .popover(isPresented: $formManagerMenuIsPresented ) {
                            List {
                                ForEach(groupViewModel.ids, id: \.self) { id in
                                    if let form = groupViewModel.form(for: id),
                                       let objectID = form.feature.objectID {
                                        Button {
                                            groupViewModel.select(form: form, clearHistory: true)
                                            formManagerMenuIsPresented = false
                                        } label: {
                                            Label {
                                                Text("\(form.title) \(objectID.formatted(.number.grouping(.never)))")
                                            } icon: {
                                                if groupViewModel.selectedID == id {
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
                            groupViewModel.selectNext()
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
