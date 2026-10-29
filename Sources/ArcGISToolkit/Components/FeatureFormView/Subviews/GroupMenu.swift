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
        @Environment(FeatureFormView.Model.self) var groupModel
        
        public var body: some View {
            NavigationStack {
                List {
                    if groupModel.forms.isEmpty {
                        noFormsView
                    } else {
                        formButtons
                    }
                }
                .navigationTitle(
                    Text(
                        "Editing ^[\(groupModel.forms.count) features](inflect: true)",
                        bundle: .toolkitModule,
                        comment: """
                            A navigation title indicating the number of \ 
                            features being edited in the feature form toolkit \
                            component.
                            """
                    )
                )
                .featureFormToolbar()
            }
        }
        
        /// <#Description#>
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
        
        /// <#Description#>
        var formButtons: some View {
            ForEach(groupModel.forms, id: \.feature.globalID) { form in
                formButton(form)
            }
            .id(groupModel.selectedForm?.feature.globalID)
        }
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        /// - Returns: <#description#>
        func formButton(_ form: FeatureForm) -> some View {
            LabeledContent {
                Button {
                    withAnimation {
                        groupModel.select(form: form, clearHistory: true)
                    }
                } label: {
                    formButtonLabel(form)
                }
                .badge(
                    groupModel.allValidationErrorsAreVisible
                    ? groupModel.totalErrorCountForForm(featureID: form.feature.globalID!)
                    : 0
                )
                .badgeProminence(.increased)
                .foregroundStyle(.primary)
            } label: {
                FeatureSymbolView(feature: form.feature)
            }
        }
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        /// - Returns: <#description#>
        func formButtonLabel(_ form: FeatureForm) -> some View {
            HStack {
                Text(
                    groupModel.formModel(
                        for: form.feature.globalID!
                    )?.title ?? ""
                )
                Spacer()
                if groupModel.unsavedEditsLabelIsVisible(form) {
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
    }
}

private extension FeatureFormView.Model {
    /// A Boolean value indicating whether the provided form should be represented as having
    /// unsaved edits.
    /// - Parameter form: The form to evaluate the edit status for.
    func unsavedEditsLabelIsVisible(_ form: FeatureForm) -> Bool {
        guard let id = form.feature.globalID else { return false }
        let hasEdits = formModel(for: id)?.hasAttributeOrGeometryEdits ?? false
        let hasNoErrors = totalErrorCountForForm(featureID: form.feature.globalID!) == 0
        let validationErrorsAreVisible = allValidationErrorsAreVisible
        return hasEdits
        && (!validationErrorsAreVisible
        || (validationErrorsAreVisible && hasNoErrors))
    }
}
