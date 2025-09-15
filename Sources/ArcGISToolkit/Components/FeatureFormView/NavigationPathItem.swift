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
        case utilityAssociationDetailsView(EmbeddedFeatureFormViewModel, AssociationsFilterResultsModel, UtilityAssociationsFormElement, UtilityAssociationResult)
        case utilityAssociationFilterResultView(EmbeddedFeatureFormViewModel, AssociationsFilterResultsModel, UtilityAssociationsFormElement, UtilityAssociationsFilter.Kind)
        case utilityAssociationGroupResultView(EmbeddedFeatureFormViewModel, AssociationsFilterResultsModel, UtilityAssociationsFormElement, UtilityAssociationsFilter.Kind, String)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.form(a), .form(b)):
                a === b
            case let (.utilityAssociationDetailsView(_, _, _, a), .utilityAssociationDetailsView(_, _, _, b)):
                a === b
            case let (.utilityAssociationFilterResultView(_, _, a1, a2), .utilityAssociationFilterResultView(_, _, b1, b2)):
                a1 === b1
                && a2 == b2
            case let (.utilityAssociationGroupResultView(_, _, a1, a2, a3), .utilityAssociationGroupResultView(_, _, b1, b2, b3)):
                // TODO: Improve group identification (Apollo 1391).
                a1 === b1
                && a2 == b2
                && a3 == b3
            default:
                false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .form(let form):
                hasher.combine(ObjectIdentifier(form))
            case .utilityAssociationDetailsView(_, _, let element, _):
                hasher.combine(element)
            case .utilityAssociationFilterResultView(_, _, let element, let filterKind):
                hasher.combine(element)
                hasher.combine(filterKind)
            case .utilityAssociationGroupResultView(_, _, let element, let filterKind, let groupTitle):
                // TODO: Improve group identification (Apollo 1391).
                hasher.combine(element)
                hasher.combine(filterKind)
                hasher.combine(groupTitle)
            }
        }
    }
}
