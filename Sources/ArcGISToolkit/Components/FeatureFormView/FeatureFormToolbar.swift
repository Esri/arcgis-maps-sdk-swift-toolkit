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
    func featureFormToolbar(_ featureForm: FeatureForm, isAForm: Bool = false) -> some View {
        self.modifier(FeatureFormToolbar(featureForm: featureForm, isAForm: isAForm))
    }
}

struct FeatureFormToolbar: ViewModifier {
    @Environment(\.dismiss) var dismiss
    
    /// The visibility of the "save" and "discard" buttons.
    @Environment(\.editingButtonVisibility) var editingButtonsVisibility
    
    /// An error thrown from a call to `FeatureForm.finishEditing()`.
    @Environment(\.finishEditingError) var finishEditingError
    
    /// A Boolean value indicating whether the deprecated FeatureFormView initializer was used.
    @Environment(\.formDeprecatedInitializerWasUsed) var deprecatedInitializerWasUsed
    
    /// A binding to a Boolean value controlling whether the FeatureFormView is presented.
    @Environment(\.isPresented) var isPresented
    
    /// The environment value which declares whether navigation to forms for features associated via utility association form elements is disabled.
    @Environment(\.navigationIsDisabled) var navigationIsDisabled
    
    /// The navigation path for the navigation stack presenting this view.
    @Environment(\.navigationPath) var navigationPath
    
    /// The closure to perform when a ``EditingEvent`` occurs.
    @Environment(\.onFormEditingEventAction) var onFormEditingEventAction
    
    /// The environment value to set the continuation to use when the user responds to the alert.
    @Environment(\.setAlertContinuation) var setAlertContinuation
    
    /// A Boolean value indicating whether the presented feature form has edits.
    @State private var hasEdits = false
    
    /// The currently presented feature form.
    let featureForm: FeatureForm
    
    /// A Boolean value indicating whether the modified view is a feature form view or another type of
    /// associated view such as a `UtilityAssociationsFilterResultView` or
    /// `UtilityAssociationGroupResultView`.
    let isAForm: Bool
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden()
            .task(id: featureForm.feature.globalID) {
                for await hasEdits in featureForm.$hasEdits {
                    withAnimation { self.hasEdits = hasEdits }
                }
            }
            .toolbar {
                if !isRootView {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            if alertBeforeDismissing {
                                setAlertContinuation?(true) {
                                    dismiss()
                                }
                            } else {
                                dismiss()
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
                if let isPresented {
                    ToolbarItem(placement: .topBarTrailing) {
                        XButton(.dismiss) {
                            if hasEdits {
                                setAlertContinuation?(false) {
                                    isPresented.wrappedValue = false
                                }
                            } else {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                }
                if !deprecatedInitializerWasUsed, hasEdits, editingButtonsVisibility != .hidden {
                    ToolbarItem(placement: .bottomBar) {
                        FormFooter(
                            featureForm: featureForm,
                            formHandlingEventAction: onFormEditingEventAction,
                            finishEditingError: finishEditingError
                        )
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
        navigationPath?.wrappedValue.isEmpty ?? true
    }
}
