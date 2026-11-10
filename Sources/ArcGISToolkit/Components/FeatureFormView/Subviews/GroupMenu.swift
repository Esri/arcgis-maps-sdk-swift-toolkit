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
    /// A central view for a `FeatureFormGroup` with buttons for each member and a toolbar
    /// that allows saving or discarding the entire group.
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
                        "Features",
                        bundle: .toolkitModule,
                        comment: "A navigation title for a list of features."
                    )
                )
                .featureFormToolbar()
            }
        }
        
        /// A view shown when no forms are in the underlying `FeatureFormGroup`.
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
        
        /// The buttons in the group menu for each form.
        var formButtons: some View {
            ForEach(groupModel.forms, id: \.feature.globalID) { form in
                formButton(form)
            }
            .id(groupModel.selectedForm?.feature.globalID)
        }
        
        /// Returns a button for a form in the group.
        /// - Parameter form: The underlying form.
        func formButton(_ form: FeatureForm) -> some View {
            LabeledContent {
                Button {
                    withAnimation {
                        groupModel.select(form: form, clearHistory: true)
                    }
                } label: {
                    Text(
                        groupModel.formModel(
                            id: form.feature.globalID!
                        )?.title ?? form.title
                    )
                }
                .badge(
                    groupModel.allValidationErrorsAreVisible
                    ? groupModel.totalErrorCountForForm(id: form.feature.globalID!)
                    : 0
                )
                .badgeProminence(.increased)
                .foregroundStyle(.primary)
            } label: {
                FeatureSymbolView(feature: form.feature)
            }
        }
    }
}
