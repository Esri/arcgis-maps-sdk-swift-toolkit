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
            // Alert for abandoning unsaved edits
            .alert(
                !featureFormViewModel.groupHasErrors ? discardEditsQuestion : validationErrors,
                isPresented: alertForUnsavedEditsIsPresented,
                actions: {
                    if let (willNavigate, continuation) = featureFormViewModel.navigationAlertInfo {
                        Button(role: .destructive) {
                            continuation()
                        } label: {
                            Text.discardEdits
                        }
                        Button(role: .cancel) {
                            alertForUnsavedEditsIsPresented.wrappedValue = false
                        } label: {
                            continueEditing
                        }
                    }
                },
                message: {
                    if featureFormViewModel.groupHasErrors {
                        Text(
                            """
                            You have ^[\(featureFormViewModel.totalErrorCount) errors](inflect: true) \
                            that must be fixed before saving.
                            """,
                            bundle: .toolkitModule,
                            comment: """
                                A message explaining that the indicated number \
                                of validation errors must be resolved before \
                                saving the feature form.
                                """
                        )
                    } else {
                        Text(
                            "Updates to the form will be lost.",
                            bundle: .toolkitModule,
                            comment: """
                                A message explaining that unsaved edits will \
                                be lost if the user continues to dismiss the \
                                form without saving.
                                """
                        )
                    }
                }
            )
            // Alert for finish editing errors
            .alert(
                Text(
                    "The form wasn't submitted",
                    bundle: .toolkitModule,
                    comment: "The title shown when the feature form failed to save."
                ),
                isPresented: alertForFinishEditingErrorsIsPresented,
                actions: {},
                message: {
                    if let error = featureFormViewModel.finishEditingError {
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
                    } else {
                        Text(
                            "Finish editing failed.",
                            bundle: .toolkitModule,
                            comment: """
                                The message shown when a form could not be \
                                submitted.
                                """
                        )
                    }
                }
            )
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
    @ViewBuilder
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
                                    if form.hasEdits {
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
                                        }
                                        .labelStyle(.iconOnly)
                                    }
                                }
                            }
                            .badge(
                                featureFormViewModel.allValidationErrorsAreVisible
                                ? form.elementValidationErrors.count
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

extension FeatureFormView.GroupView /* Helpers */ {
    /// A Boolean value indicating whether the finish editing error alert is presented.
    var alertForFinishEditingErrorsIsPresented: Binding<Bool> {
        Binding {
            featureFormViewModel.finishEditingError != nil
        } set: { newIsPresented in
            if !newIsPresented {
                featureFormViewModel.finishEditingError = nil
            }
        }
    }
    
    /// A Boolean value indicating whether the unsaved edits alert is presented.
    var alertForUnsavedEditsIsPresented: Binding<Bool> {
        Binding {
            featureFormViewModel.navigationAlertInfo != nil
        } set: { newIsPresented in
            if !newIsPresented {
                featureFormViewModel.navigationAlertInfo = nil
            }
        }
    }
    
    // MARK: Localized text
    
    var continueEditing: Text {
        .init(
            "Continue Editing",
            bundle: .toolkitModule,
            comment: "A label for a button to continue editing the feature form."
        )
    }
    
    var discardEditsQuestion: Text {
        .init(
            "Discard Edits?",
            bundle: .toolkitModule,
            comment: "A question asking if the user would like to discard their unsaved edits."
        )
    }
    
    var saveEdits: Text {
        .init(
            "Save Edits",
            bundle: .toolkitModule,
            comment: "A label for a button to save edits."
        )
    }
    
    var validationErrors: Text {
        .init(
            "Validation Errors",
            bundle: .toolkitModule,
            comment: "A label indicating the feature form has validation errors."
        )
    }
}
