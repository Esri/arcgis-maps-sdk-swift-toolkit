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

struct FormFooter: View {
    /// The backing feature form.
    let featureForm: FeatureForm
    
    /// The closure to perform when a choice is made.
    ///
    /// - Note: This property is optional as the modifier providing the closure may not be applied
    /// to the ``FeatureFormView``.
    let formHandlingEventAction: ((FeatureFormView.EditingEvent) -> Void)?
    
    /// The model for the FeatureFormView containing the view.
    @Environment(FeatureFormViewModel.self) var featureFormViewModel
    
    /// An action to run before saving.
    @Environment(\.beforeSaveAction) var beforeSaveAction
    
    /// Text describing an external validation error.
    @Environment(\.validationErrorMessage) var validationErrorMessage
    
    var body: some View {
//        HStack {
//            discardButton
//                .inspectorTint(.red)
            Spacer()
            saveButton
                .inspectorTint(.blue)
//        }
    }
    
    var discardButton: some View {
        Button(role: .destructive) {
            featureForm.discardEdits()
            formHandlingEventAction?(.discardedEdits(willNavigate: false))
            featureFormViewModel.validationErrorVisibilityInternal = .automatic
        } label: {
            Text(
                "Discard",
                bundle: .toolkitModule,
                comment: "Discard edits on the feature form."
            )
        }
    }
    
    var saveButton: some View {
        Button {
            if featureForm.validationErrors.isEmpty && validationErrorMessage == nil {
                Task {
                    if let beforeSaveAction {
                        beforeSaveAction()
                    }
                    
                    do {
                        try await featureForm.finishEditing()
                        formHandlingEventAction?(.savedEdits(willNavigate: false))
                    } catch {
                        featureFormViewModel.finishEditingError = error
                    }
                }
            } else {
                featureFormViewModel.validationErrorVisibilityInternal = .visible
                featureFormViewModel.navigationAlertInfo = (false, {})
            }
        } label: {
            Text(
                "Save",
                bundle: .toolkitModule,
                comment: "Finish editing the feature form."
            )
        }
    }
}
