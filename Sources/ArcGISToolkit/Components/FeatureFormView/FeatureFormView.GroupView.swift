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
    public struct GroupView: View {
        /// The model for the feature form view.
        @Environment(FeatureFormView.Model.self) var featureFormViewModel
        
        public var body: some View {
            Group {
                if let selectedID = featureFormViewModel.selectedID {
                    form(id: selectedID)
                } else {
                    menu
                }
            }
            .saveErrorAlert(featureFormViewModel)
            .unsavedEditsAlert(featureFormViewModel)
            .validationErrorsAlert(featureFormViewModel)
        }
    }
}

extension FeatureFormView.GroupView /* Group views */ {
    /// <#Description#>
    /// - Parameter id: <#id description#>
    @ViewBuilder
    func form(id: UUID) -> some View {
        if let stackModel = featureFormViewModel.formModel(for: id) {
            FeatureFormView.StackView(model: stackModel)
        }
    }
    
    /// <#Description#>
    var menu: some View {
        NavigationStack {
            List {
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
            .navigationTitle(
                "Editing ^[\(featureFormViewModel.activeFormCount) features](inflect: true)"
            )
            .featureFormToolbar()
        }
    }
}

private extension View /* Alerts */ {
    /// An alert for save errors.
    func saveErrorAlert(_ model: FeatureFormView.Model) -> some View {
        @Bindable var model = model
        return alert(
            LocalizedStringResource(
                "The form wasn't submitted",
                bundle: .toolkit,
                comment: "The title shown when the feature form failed to save."
            ),
            item: $model.finishEditingError,
            actions: { _ in },
            message: { error in
                Text(
                    """
                    Finish editing failed.
                    \(String(describing: error))
                    """,
                    bundle: .toolkitModule,
                    comment: """
                        The message shown when a form could not be \
                        submitted with additional details.
                        """
                )
            }
        )
    }
    
    /// An alert for abandoning unsaved edits.
    func unsavedEditsAlert(_ model: FeatureFormView.Model) -> some View {
        @Bindable var model = model
        return alert(
            Text(
                "Discard Edits?",
                bundle: .toolkitModule,
                comment: """
                    A question asking if the user would like to discard their \
                    unsaved edits.
                    """
            ),
            isPresented: $model.alertForUnsavedEditsIsPresented,
            actions: {
                Button(role: .destructive) {
                    model.discard(ignoreEdits: true)
                } label: {
                    Text.discardEdits
                }
                Button(role: .cancel) {
                    model.alertForUnsavedEditsIsPresented = false
                } label: {
                    Text.continueEditing
                }
            },
            message: {
                Text(
                    "Edits will be lost.",
                    bundle: .toolkitModule,
                    comment: """
                        A message explaining that unsaved edits will be lost \
                        if the user continues to dismiss the component without \
                        saving.
                        """
                )
            }
        )
    }
    
    /// An alert for validation errors.
    func validationErrorsAlert(_ model: FeatureFormView.Model) -> some View {
        @Bindable var model = model
        return alert(
            Text(
                "Validation Errors",
                bundle: .toolkitModule,
                comment: """
                    A label indicating the feature form has validation errors.
                    """
            ),
            isPresented: $model.alertForValidationErrorsIsPresented,
            actions: {
                Button(role: .cancel) {
                    model.alertForUnsavedEditsIsPresented = false
                } label: {
                    Text.continueEditing
                }
            },
            message: {
                Text(
                    """
                    You have ^[\(model.totalErrorCount) errors](inflect: true) \
                    that must be fixed before saving.
                    """,
                    bundle: .toolkitModule,
                    comment: """
                        A message explaining that the indicated number \
                        of validation errors must be resolved before \
                        saving the feature form.
                        """
                )
            }
        )
    }
}

private extension Text {
    static var continueEditing: Self {
        .init(
            "Continue Editing",
            bundle: .toolkitModule,
            comment: "A label for a button to continue editing the feature form."
        )
    }
}
