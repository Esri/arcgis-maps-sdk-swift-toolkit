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
    /// A view for a destination in the component's navigation stack.
    struct NavigationDestination: View {
        /// The model for the feature form view.
        @Environment(FeatureFormView.Model.self) private var groupModel
        
        /// The item represented by the destination.
        let item: NavigationPathItem
        
        public var body: some View {
            destination
                .featureFormToolbar()
                .environment(formModel)
        }
        
        @ViewBuilder var destination: some View {
            switch item {
            case let .form(form):
                FormView(form: form)
            case let .utilityAssociationAssetTypesView(form, element, filter, source):
                UtilityAssociationAssetTypesView(
                    element: element,
                    filter: filter,
                    form: form,
                    source: source
                )
            case let .utilityAssociationCreationView(form, element, filter, candidate):
                UtilityAssociationCreationView(
                    candidate: candidate,
                    element: element,
                    filter: filter,
                    form: form
                )
            case let .utilityAssociationDetailsView(form, element, associationResult):
                UtilityAssociationDetailsView(
                    associationResult: associationResult,
                    element: element,
                    form: form
                )
            case let .utilityAssociationFeatureCandidatesView(form, element, filter, source, assetType):
                UtilityAssociationFeatureCandidatesView(
                    assetType: assetType,
                    element: element,
                    filter: filter,
                    form: form,
                    source: source
                )
            case let .utilityAssociationFeatureSourcesView(form, element, filter):
                UtilityAssociationFeatureSourcesView(
                    element: element,
                    filter: filter,
                    form: form
                )
            case let .utilityAssociationFilterResultView(form, element, filter):
                UtilityAssociationsFilterResultView(
                    element: element,
                    filter: filter,
                    form: form
                )
            case let .utilityAssociationGroupResultView(form, element, filter, formSource):
                UtilityAssociationGroupResultView(
                    element: element,
                    featureFormSource: formSource,
                    filter: filter,
                    form: form
                )
            }
        }
        
        /// The model for the underlying form.
        var formModel: FeatureFormView.FormModel {
            groupModel.formModel(id: item.form.feature.globalID!)!
        }
    }
}

private extension FeatureFormView.NavigationPathItem {
    /// The underlying form for this item.
    var form: FeatureForm {
        switch self {
        case .form(let form):
            return form
        case .utilityAssociationAssetTypesView(let form, _, _, _):
            return form
        case .utilityAssociationCreationView(let form, _, _, _):
            return form
        case .utilityAssociationDetailsView(let form, _, _):
            return form
        case .utilityAssociationFeatureCandidatesView(let form, _, _, _, _):
            return form
        case .utilityAssociationFeatureSourcesView(let form, _, _):
            return form
        case .utilityAssociationFilterResultView(let form, _, _):
            return form
        case .utilityAssociationGroupResultView(let form, _, _, _):
            return form
        }
    }
}
