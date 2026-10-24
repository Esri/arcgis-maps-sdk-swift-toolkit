// Copyright 2026 Esri
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

extension FeatureFormView {
    /// <#Description#>
    struct GroupMenu: View {
        /// The model for the feature form view.
        @Environment(FeatureFormView.Model.self) var featureFormViewModel
        
        public var body: some View {
            NavigationStack {
                List {
                    if featureFormViewModel.formCount == 0 {
                        noFormsView
                    } else {
                        formButtons
                    }
                }
                .navigationTitle(
                    "Editing ^[\(featureFormViewModel.activeFormCount) features](inflect: true)"
                )
                .featureFormToolbar()
            }
        }
        
        var noFormsView: some View {
            ContentUnavailableView {
                Text(
                    "No forms",
                    bundle: .toolkitModule,
                    comment: """
                        A label communicating that no feature forms \
                        have been added to a feature form view.
                        """
                )
            }
        }
        
        var formButtons: some View {
            ForEach(featureFormViewModel.activeForms, id: \.feature.globalID) { form in
                formButton(form)
            }
            .id(featureFormViewModel.selectedID)
        }
        
        func formButton(_ form: FeatureForm) -> some View {
            LabeledContent {
                Button {
                    withAnimation {
                        featureFormViewModel.select(form: form, clearHistory: true)
                    }
                } label: {
                    formButtonLabel(form)
                }
                .badge(
                    featureFormViewModel.allValidationErrorsAreVisible
                    ? featureFormViewModel.totalErrorCountForForm(featureID: form.feature.globalID!)
                    : 0
                )
                .badgeProminence(.increased)
                .foregroundStyle(.primary)
            } label: {
                FeatureSymbolView(feature: form.feature)
            }
        }
        
        func formButtonLabel(_ form: FeatureForm) -> some View {
            HStack {
                Text(form.title)
                Spacer()
                if unsavedEditsLabelIsVisible(form) {
                    Label {
                        Text(
                            "Unsaved Edits",
                            bundle: .toolkitModule,
                            comment: """
                                A label indicating a \ 
                                feature form has unsaved \
                                edits.
                                """
                        )
                    } icon: {
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                    }
                    .labelStyle(.iconOnly)
                }
            }
        }
        
        func unsavedEditsLabelIsVisible(_ form: FeatureForm) -> Bool {
            let hasEdits = featureFormViewModel.editStatusForForm(featureID: form.feature.globalID!)
            let hasNoErrors = featureFormViewModel.totalErrorCountForForm(featureID: form.feature.globalID!) == 0
            let validationErrorsAreVisible = featureFormViewModel.allValidationErrorsAreVisible
            return hasEdits
            && (!validationErrorsAreVisible
            || (validationErrorsAreVisible && hasNoErrors))
        }
    }
}
