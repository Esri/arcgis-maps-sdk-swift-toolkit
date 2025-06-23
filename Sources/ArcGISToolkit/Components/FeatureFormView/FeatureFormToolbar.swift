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
    func featureFormToolbar(_ featureForm: FeatureForm, isAForm: Bool = false, isRootForm: Bool = false) -> some View {
        self.modifier(FeatureFormToolbar(featureForm: featureForm, isAForm: isAForm, isRootForm: isRootForm))
    }
}

struct FeatureFormToolbar: ViewModifier {
    @Environment(\.closeButtonVisibility) var closeButtonVisibility
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.editingButtonVisibility) var editingButtonsVisibility
    
    @Environment(\.finishEditingError) var finishEditingError
    
    @Environment(\.onFormEditingEventAction) var onFormEditingEventAction
    
    @Environment(\.presentedForm) var presentedForm
    
    @Environment(\.setAlertContinuation) var setAlertContinuation
    
    @Environment(\._validationErrorVisibility) var _validationErrorVisibility
    
    /// A Boolean value indicating whether the presented feature form has edits.
    @State private var hasEdits = false
    
    /// The currently presented feature form.
    let featureForm: FeatureForm
    
    /// A Boolean value indicating whether the modified view is a feature form view or another type of
    /// associated view such as a `UtilityAssociationsFilterResultView` or
    /// `UtilityAssociationGroupResultView`.
    let isAForm: Bool
    
    /// A Boolean value indicating whether the modified view is apart of the root feature form or an
    /// associated feature.
    ///
    /// The root feature form is the form used to initialize the FeatureFormView. Associated forms are
    /// opened via `UtilityAssociationResultView`s by the user.
    let isRootForm: Bool
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(navigationBarBackButtonIsHidden)
            .task(id: featureForm.feature.globalID) {
                for await hasEdits in featureForm.$hasEdits {
                    withAnimation { self.hasEdits = hasEdits }
                }
            }
            .toolbar {
                if navigationBarBackButtonIsHidden {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            setAlertContinuation?(true) {
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
                    }
                }
                if closeButtonVisibility != .hidden {
                    ToolbarItem(placement: .topBarTrailing) {
                        XButton(.dismiss) {
                            if hasEdits {
                                setAlertContinuation?(false) {
                                    presentedForm?.wrappedValue = nil
                                }
                            } else {
                                presentedForm?.wrappedValue = nil
                            }
                        }
                    }
                }
                if hasEdits, editingButtonsVisibility != .hidden {
                    ToolbarItem(placement: .bottomBar) {
                        FormFooter(
                            featureForm: featureForm,
                            formHandlingEventAction: onFormEditingEventAction,
                            validationErrorVisibility: _validationErrorVisibility,
                            finishEditingError: finishEditingError
                        )
                    }
                }
            }
    }
}

extension FeatureFormToolbar {
    /// A Boolean value indicating whether the navigation bar's back button is hidden.
    ///
    /// In certain cases the platform default button is hidden to support blocking back navigation with an
    /// alert for unsaved edits.
    var navigationBarBackButtonIsHidden: Bool {
        isAForm && !isRootForm && hasEdits
    }
}
