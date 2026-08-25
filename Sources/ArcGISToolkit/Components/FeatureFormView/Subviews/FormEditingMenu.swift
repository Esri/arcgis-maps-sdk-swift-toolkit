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

struct FormEditingMenu: View {
    /// A binding to a Boolean value controlling whether the FeatureFormView is presented.
    @Environment(\.isPresented) var isPresented
    
    /// The backing feature form.
    let featureForm: FeatureForm
    
    /// The closure to perform when a choice is made.
    ///
    /// - Note: This property is optional as the modifier providing the closure may not be applied
    /// to the ``FeatureFormView``.
    let formHandlingEventAction: FormEditingEventAction?
    
    /// The model for the FeatureFormView containing the view.
    @Environment(FeatureFormViewModel.self) var featureFormViewModel
    
    var body: some View {
        Menu {
            discardButton
            discardAndCloseButton
        } label: {
            menuLabel
                .labelStyle(.iconOnly)
        } primaryAction: {
            onSave()
        }
    }
    
    var discardButton: some View {
        Button(role: .destructive) {
            featureFormViewModel.unsavedEditsAlertInfo = .init(includeSaveOption: false, willNavigate: false)
        } label: {
            Text(
                "Discard",
                bundle: .toolkitModule,
                comment: "Discard edits on the feature form."
            )
        }
    }
    
    @ViewBuilder var discardAndCloseButton: some View {
        if let isPresented {
            Button(role: .destructive) {
                featureFormViewModel.unsavedEditsAlertInfo = .init(includeSaveOption: false, willNavigate: false) {
                    isPresented.wrappedValue = false
                }
            } label: {
                Text(
                    "Discard And Close",
                    bundle: .toolkitModule,
                    comment: "Discard edits on the feature form and close it."
                )
            }
        }
    }
    
    var menuLabel: Label<Text, Image> {
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
    
    func onSave() {
        if featureForm.elementValidationErrors.isEmpty {
            Task {
                do {
                    try await featureForm.finishEditing()
                    formHandlingEventAction?(.savedEdits(willNavigate: false))
                } catch {
                    featureFormViewModel.finishEditingError = error
                }
            }
        } else {
            featureFormViewModel.validationErrorVisibilityInternal = .visible
            featureFormViewModel.unsavedEditsAlertInfo = .init(includeSaveOption: true, willNavigate: false)
        }
    }
}
