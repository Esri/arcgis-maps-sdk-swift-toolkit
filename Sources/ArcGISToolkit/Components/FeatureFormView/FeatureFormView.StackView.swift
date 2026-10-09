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
    /// A stack view consists of views for one or more forms and the views that a user will navigate
    /// through when browsing and editing utility network associations.
    ///
    /// When the legacy `FeatureFormView.init(root:isPresented:)` initializer is used,
    /// forms for features associated via utility network associations are added onto this stack.
    /// When the `FeatureFormView.init(model:isPresented:)` initializer is used, these
    /// forms are instead added to the `FeatureFormGroup` on the provided model.
    struct StackView: View {
        @Environment(FeatureFormView.Model.self) var featureFormViewModel
        
        /// The model for the stack view for the root form.
        @State private var stackViewModel: FeatureFormView.StackView.Model
        
        init(root: FeatureForm) {
            self.stackViewModel = Model(root: root)
        }
        
        public var body: some View {
            NavigationStack(path: $stackViewModel.navigationPath) {
                FormView(form: stackViewModel.root)
                    // Refresh the navigation stack's root view when the root
                    // feature form changes.
                    .id(ObjectIdentifier(stackViewModel.root))
                    .navigationDestination(for: NavigationPathItem.self) { itemType in
                        switch itemType {
                        case let .form(form):
                            FormView(form: form)
                        case let .utilityAssociationAssetTypesView(form, element, filter, source):
                            UtilityAssociationAssetTypesView(
                                element: element,
                                filter: filter,
                                form: form,
                                source: source
                            )
                            .featureFormToolbar(form)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle(source.name)
                        case let .utilityAssociationCreationView(form, element, filter, candidate):
                            UtilityAssociationCreationView(
                                candidate: candidate,
                                element: element,
                                filter: filter,
                                form: form
                            )
                            .featureFormToolbar(form)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle(newAssociation)
                        case let .utilityAssociationDetailsView(form, element, associationResult):
                            UtilityAssociationDetailsView(
                                associationResult: associationResult,
                                element: element,
                                form: form
                            )
                            .featureFormToolbar(form)
                            .navigationBarTitleDisplayMode(.inline)
                        case let .utilityAssociationFeatureCandidatesView(form, element, filter, source, assetType):
                            UtilityAssociationFeatureCandidatesView(
                                assetType: assetType,
                                element: element,
                                filter: filter,
                                form: form,
                                source: source
                            )
                            .featureFormToolbar(form)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle(assetType.name)
                        case let .utilityAssociationFeatureSourcesView(form, element, filter):
                            UtilityAssociationFeatureSourcesView(
                                element: element,
                                filter: filter,
                                form: form
                            )
                            .featureFormToolbar(form)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle(networkDataSource)
                        case let .utilityAssociationFilterResultView(form, element, filter):
                            UtilityAssociationsFilterResultView(
                                element: element,
                                filter: filter,
                                form: form
                            )
                            .featureFormToolbar(form)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle(filter.title, subtitle: stackViewModel.getModel(form)?.title ?? "")
                        case let .utilityAssociationGroupResultView(form, element, filter, formSource):
                            UtilityAssociationGroupResultView(
                                element: element,
                                featureFormSource: formSource,
                                filter: filter,
                                form: form
                            )
                            .featureFormToolbar(form)
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
            }
            // Alert for abandoning unsaved edits
            .alert(
                !stackViewModel.presentedFormHasValidationErrors ? discardEditsQuestion : validationErrors,
                isPresented: alertForUnsavedEditsIsPresented,
                actions: {
                    if let (willNavigate, continuation) = stackViewModel.navigationAlertInfo {
                        Button(role: .destructive) {
                            stackViewModel.presentedForm?.discardEdits()
                            stackViewModel.validationErrorVisibilityInternal = .automatic
                            featureFormViewModel.onFormEditingEventAction?(.discardedEdits(willNavigate: willNavigate))
                            continuation()
                        } label: {
                            Text.discardEdits
                        }
                        .onAppear {
                            if stackViewModel.presentedFormHasValidationErrors {
                                stackViewModel.validationErrorVisibilityInternal = .visible
                            }
                        }
                        if !stackViewModel.presentedFormHasValidationErrors {
                            Button {
                                Task {
                                    do {
                                        try await stackViewModel.presentedForm?.finishEditing()
                                        featureFormViewModel.onFormEditingEventAction?(.savedEdits(willNavigate: willNavigate))
                                        continuation()
                                    } catch {
                                        stackViewModel.finishEditingError = error
                                    }
                                }
                            } label: {
                                saveEdits
                            }
                        }
                        Button(role: .cancel) {
                            alertForUnsavedEditsIsPresented.wrappedValue = false
                        } label: {
                            continueEditing
                        }
                    }
                },
                message: {
                    if stackViewModel.presentedFormHasValidationErrors {
                        Text(
                            "You have ^[\(stackViewModel.presentedForm?.elementValidationErrors.count ?? 0) error](inflect: true) that must be fixed before saving.",
                            bundle: .toolkitModule,
                            comment:
                                    """
                                    A message explaining that the indicated number
                                    of validation errors must be resolved before
                                    saving the feature form.
                                    """
                        )
                    } else {
                        Text(
                            "Updates to the form will be lost.",
                            bundle: .toolkitModule,
                            comment:
                                    """
                                    A message explaining that unsaved edits will be
                                    lost if the user continues to dismiss the form
                                    without saving.
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
                    if let error = stackViewModel.finishEditingError {
                        Text(
                                """
                                Finish editing failed.
                                \(String(describing: error))
                                """,
                                bundle: .toolkitModule,
                                comment:
                                    """
                                    The message shown when a form could not be 
                                    submitted with additional details.
                                    """
                        )
                    } else {
                        Text(
                            "Finish editing failed.",
                            bundle: .toolkitModule,
                            comment: "The message shown when a form could not be submitted."
                        )
                    }
                }
            )
            .animation(.default, value: ObjectIdentifier(stackViewModel.root))
            .environment(stackViewModel)
            .onChange(of: stackViewModel.navigationPath) {
                if let presentedItem = stackViewModel.navigationPath.last {
                    featureFormViewModel.onFormEditingEventAction?(.navigationChanged(presentedItem))
                }
            }
            .onChange(of: ObjectIdentifier(stackViewModel.root), initial: true) {
                stackViewModel.setRootForm(stackViewModel.root)
            }
            .onPreferenceChange(PresentedFeatureFormPreferenceKey.self) {
                guard let formViewModel = $0?.object else { return }
                formChangedAction(formViewModel.featureForm)
            }
        }
    }
}

extension FeatureFormView.StackView {
    /// A Boolean value indicating whether the finish editing error alert is presented.
    var alertForFinishEditingErrorsIsPresented: Binding<Bool> {
        Binding {
            stackViewModel.finishEditingError != nil
        } set: { newIsPresented in
            if !newIsPresented {
                stackViewModel.finishEditingError = nil
            }
        }
    }
    
    /// A Boolean value indicating whether the unsaved edits alert is presented.
    var alertForUnsavedEditsIsPresented: Binding<Bool> {
        Binding {
            stackViewModel.navigationAlertInfo != nil
        } set: { newIsPresented in
            if !newIsPresented {
                stackViewModel.navigationAlertInfo = nil
            }
        }
    }
    
    /// The closure to perform when the presented feature form changes.
    ///
    /// - Note: This action has the potential to be called under four scenarios. Whenever an
    /// ``EmbeddedFeatureFormView`` appears (which can happen during forward
    /// or reverse navigation) and whenever a ``UtilityAssociationGroupResultView`` appears
    /// (which can also happen during forward or reverse navigation). Because those two views (and the
    /// intermediate ``UtilityAssociationsFilterResultView`` are all considered to be apart of
    /// the same ``FeatureForm`` make sure not to over-emit form handling events.
    var formChangedAction: (FeatureForm) -> Void {
        { featureForm in
            if featureForm.feature.globalID != stackViewModel.presentedForm?.feature.globalID {
                stackViewModel.setPresentedForm(featureForm)
                featureFormViewModel.onFeatureFormChanged?(featureForm)
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
    
    var networkDataSource: Text {
        .init(
            "Network Data Source",
            bundle: .toolkitModule,
            comment: """
                A navigation title for a page listing
                data sources in a utility network.
                """
        )
    }
    
    var newAssociation: Text {
        .init(
            "New Association",
            bundle: .toolkitModule,
            comment: "A navigation title for a view to create a new association in."
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
