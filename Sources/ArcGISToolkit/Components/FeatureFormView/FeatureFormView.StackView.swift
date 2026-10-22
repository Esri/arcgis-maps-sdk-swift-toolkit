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
    /// A stack view consists of sub-views for one form that a user will navigate through when
    /// browsing and editing utility network associations.
    struct StackView: View {
        @Environment(FeatureFormView.Model.self) var featureFormViewModel
        
        /// The effective navigation path.
        ///
        /// This path acts as read-only mirror of the path stored in the stack view model which
        /// means the navigation stack won't empty the stored path when the active form
        /// changes.
        @State private var effectiveNavigationPath = [FeatureFormView.NavigationPathItem]()
        
        /// The model for the stack view for the root form.
        let stackViewModel: FeatureFormView.StackView.Model
        
        init(model: StackView.Model) {
            self.stackViewModel = model
        }
        
        public var body: some View {
            NavigationStack(path: $effectiveNavigationPath) {
                FormView(form: stackViewModel.formModel.featureForm)
                    .featureFormToolbar()
                    .navigationTitle(stackViewModel.formModel.title)
                    .navigationDestination(for: NavigationPathItem.self) { itemType in
                        switch itemType {
                        case .form(_):
                            // With the introduction of FeatureFormGroup, opened
                            // associations are added to the group rather than
                            // the stack of the current form.
                            EmptyView()
                        case let .utilityAssociationAssetTypesView(form, element, filter, source):
                            UtilityAssociationAssetTypesView(
                                element: element,
                                filter: filter,
                                form: form,
                                source: source
                            )
                            .featureFormToolbar()
                            .navigationTitle(source.name)
                        case let .utilityAssociationCreationView(form, element, filter, candidate):
                            UtilityAssociationCreationView(
                                candidate: candidate,
                                element: element,
                                filter: filter,
                                form: form
                            )
                            .featureFormToolbar()
                            .navigationTitle(newAssociation)
                        case let .utilityAssociationDetailsView(form, element, associationResult):
                            UtilityAssociationDetailsView(
                                associationResult: associationResult,
                                element: element,
                                form: form
                            )
                            .featureFormToolbar()
                        case let .utilityAssociationFeatureCandidatesView(form, element, filter, source, assetType):
                            UtilityAssociationFeatureCandidatesView(
                                assetType: assetType,
                                element: element,
                                filter: filter,
                                form: form,
                                source: source
                            )
                            .featureFormToolbar()
                            .navigationTitle(assetType.name)
                        case let .utilityAssociationFeatureSourcesView(form, element, filter):
                            UtilityAssociationFeatureSourcesView(
                                element: element,
                                filter: filter,
                                form: form
                            )
                            .featureFormToolbar()
                            .navigationTitle(networkDataSource)
                        case let .utilityAssociationFilterResultView(form, element, filter):
                            UtilityAssociationsFilterResultView(
                                element: element,
                                filter: filter,
                                form: form
                            )
                            .featureFormToolbar()
                            .navigationTitle(filter.title, subtitle: stackViewModel.formModel.title)
                        case let .utilityAssociationGroupResultView(form, element, filter, formSource):
                            UtilityAssociationGroupResultView(
                                element: element,
                                featureFormSource: formSource,
                                filter: filter,
                                form: form
                            )
                            .featureFormToolbar()
                        }
                    }
            }
            .animation(.default, value: ObjectIdentifier(stackViewModel.formModel.featureForm))
            .environment(stackViewModel)
            .onChange(of: stackViewModel.navigationPath) {
                if let presentedItem = stackViewModel.navigationPath.last {
                    featureFormViewModel.onFormEditingEventAction?(.navigationChanged(presentedItem))
                }
            }
            .onPreferenceChange(PresentedFeatureFormPreferenceKey.self) {
                guard let formViewModel = $0?.object else { return }
                formChangedAction(formViewModel.featureForm)
            }
            .onChange(of: stackViewModel.formModel.featureForm.id, initial: true) {
                effectiveNavigationPath = stackViewModel.navigationPath
            }
            .onChange(of: stackViewModel.navigationPath) {
                effectiveNavigationPath = stackViewModel.navigationPath
            }
        }
    }
}

extension FeatureFormView.StackView {
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
            if featureForm.feature.globalID != stackViewModel.formModel.featureForm.feature.globalID {
                featureFormViewModel.onFeatureFormChanged?(featureForm)
            }
        }
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
}
