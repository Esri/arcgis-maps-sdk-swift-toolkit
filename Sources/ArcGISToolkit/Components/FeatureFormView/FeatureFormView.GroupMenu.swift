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
    public struct GroupMenu: View {
        /// The model for the feature form view.
        @Environment(FeatureFormView.Model.self) var featureFormViewModel
        
        public var body: some View {
            NavigationStack {
                List {
                    menu
                }
                .navigationTitle(
                    "Editing ^[\(featureFormViewModel.activeFormCount) features](inflect: true)"
                )
                .featureFormToolbar()
            }
        }
    }
}

extension FeatureFormView.GroupMenu /* Group views */ {
    /// <#Description#>
    @ViewBuilder
    var menu: some View {
        if featureFormViewModel.formCount == 0 {
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
        } else {
            ForEach(featureFormViewModel.activeForms, id: \.feature.globalID) { form in
                LabeledContent {
                    Button {
                        featureFormViewModel.select(form: form, clearHistory: true)
                    } label: {
                        HStack {
                            Text(form.title)
                            Spacer()
                            if featureFormViewModel.editStatusForForm(featureID: form.feature.globalID!)
                                &&
                                (
                                    !featureFormViewModel.allValidationErrorsAreVisible
                                    || (
                                        featureFormViewModel.allValidationErrorsAreVisible
                                        && featureFormViewModel.totalErrorCountForForm(featureID: form.feature.globalID!) == 0
                                    )
                                )
                            {
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
            .id(featureFormViewModel.selectedID)
        }
    }
}
