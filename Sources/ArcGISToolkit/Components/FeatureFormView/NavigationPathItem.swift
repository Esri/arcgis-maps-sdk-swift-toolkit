// Copyright 2025 Esri
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

extension FeatureFormView {
    enum NavigationPathItem: Hashable {
        case form(FeatureForm)
        case utilityAssociationDetailsView(EmbeddedFeatureFormViewModel, UtilityAssociationsFormElement, UtilityAssociation, AssociationsFilterResultsModel)
        case utilityAssociationFilterResultView(EmbeddedFeatureFormViewModel, UtilityAssociationsFormElement, String, AssociationsFilterResultsModel)
        case utilityAssociationGroupResultView(EmbeddedFeatureFormViewModel, UtilityAssociationsFormElement, String, String, AssociationsFilterResultsModel)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.form(a), .form(b)):
                a === b
            case let (.utilityAssociationDetailsView(_, a, _, _), .utilityAssociationDetailsView(_, b, _, _)):
                a === b
            case let (.utilityAssociationFilterResultView(_, _, a, _), .utilityAssociationFilterResultView(_, _, b, _)):
                a == b
            case let (.utilityAssociationGroupResultView(_, _, a1, a2, _), .utilityAssociationGroupResultView(_, _, b1, b2, _)):
                a1 == b1
                && a2 == b2
            default:
                false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .form(let form):
                hasher.combine(ObjectIdentifier(form))
            case .utilityAssociationDetailsView(_, let element, _, _):
                hasher.combine(element)
            case .utilityAssociationFilterResultView(_, _, let filterTitle, _):
                hasher.combine(filterTitle)
            case .utilityAssociationGroupResultView(_, _, let filterTitle, let groupTitle, _):
                hasher.combine(filterTitle)
                hasher.combine(groupTitle)
            }
        }
    }
}
