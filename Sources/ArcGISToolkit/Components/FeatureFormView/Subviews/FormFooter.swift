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
    
    /// The validation error visibility configuration of the form.
    @Binding var validationErrorVisibility: Visibility
    
    /// An error thrown from finish editing.
    @Binding var finishEditingError: (any Error)?
    
    /// The view model for the form.
    @Environment(FeatureFormViewModel.self) private var featureFormViewModel
    
    @Environment(\.setAlertContinuation) var setAlertContinuation
    
    var body: some View {
        HStack {
            Button {
                featureForm.discardEdits()
                formHandlingEventAction?(.discardedEdits(willNavigate: false))
                validationErrorVisibility = .hidden
            } label: {
                Text(
                    "Discard",
                    bundle: .toolkitModule,
                    comment: "Discard edits on the feature form."
                )
            }
            
            Spacer()
            
            Button {
                    if featureForm.validationErrors.isEmpty {
                        Task {
                            do {
                                try await featureForm.finishEditing()
                                featureFormViewModel.resetGeometryChangeMonitoring(for: featureForm.feature)
                                formHandlingEventAction?(.savedEdits(willNavigate: false))
                            } catch {
                                finishEditingError = error
                            }
                        }
                    } else {
                        validationErrorVisibility = .visible
                        setAlertContinuation?(false, {})
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
}
