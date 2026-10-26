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
    struct FormStack: View {
        /// The model for the feature form view.
        @Environment(FeatureFormView.Model.self) var featureFormViewModel
        
        /// The effective navigation path.
        ///
        /// This path acts as read-only mirror of the path stored in the form model which stops
        /// the navigation stack from mutating the stored path when the selected form changes
        /// and allows the user to reopen this form from the group menu and resume at the same
        /// they left from.
        @State private var effectiveNavigationPath = [FeatureFormView.NavigationPathItem]()
        
        /// The model for the underlying form.
        let formModel: FeatureFormView.FormModel
        
        public var body: some View {
            NavigationStack(path: $effectiveNavigationPath) {
                FormView(form: formModel.featureForm)
                    .featureFormToolbar()
                    .navigationTitle(formModel.title)
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
                            .navigationTitle(filter.title, subtitle: formModel.title)
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
            .environment(formModel)
            // Re-evaluate the stack when the selected form changes and the
            // toolbars when the form count changes.
            .id(formModel.featureForm.id.hashValue + featureFormViewModel.formCount)
            .onChange(of: formModel.navigationPath) {
                if let presentedItem = formModel.navigationPath.last {
                    featureFormViewModel.reportEditingEvent(.navigationChanged(presentedItem))
                }
            }
            .onChange(of: formModel.featureForm.id, initial: true) {
                effectiveNavigationPath = formModel.navigationPath
            }
            .onChange(of: formModel.navigationPath) {
                effectiveNavigationPath = formModel.navigationPath
            }
        }
    }
}

extension FeatureFormView.FormStack {
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
