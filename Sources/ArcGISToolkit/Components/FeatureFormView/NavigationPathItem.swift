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
        case utilityAssociationCreationView(UtilityAssociationFeatureCandidate, UtilityAssociationsFormElement, UtilityAssociationsFilter)
        case utilityAssociationDetailsView(EmbeddedFeatureFormViewModel, AssociationsFilterResultsModel, UtilityAssociationsFormElement, UtilityAssociationResult)
        case utilityAssociationFeatureCandidatesView(UtilityAssociationsFormElement, UtilityAssociationsFilter, UtilityAssociationFeatureSource)
        case utilityAssociationFilterResultView(EmbeddedFeatureFormViewModel, AssociationsFilterResultsModel, UtilityAssociationsFormElement, String)
        case utilityAssociationGroupResultView(EmbeddedFeatureFormViewModel, AssociationsFilterResultsModel, UtilityAssociationsFormElement, String, String)
        case utilityAssociationNetworkSourcesView(EmbeddedFeatureFormViewModel, UtilityAssociationsFormElement, UtilityAssociationsFilter)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.form(a), .form(b)):
                a === b
            case let (.utilityAssociationCreationView(_, _, filterA),
                      .utilityAssociationCreationView(_, _, filterB)):
                filterA === filterB
            case let (.utilityAssociationDetailsView(_, _, _, resultA),
                      .utilityAssociationDetailsView(_, _, _, resultB)):
                resultA === resultB
            case let (.utilityAssociationFeatureCandidatesView(_, filterA, sourceA),
                      .utilityAssociationFeatureCandidatesView(_, filterB, sourceB)):
                filterA === filterB
                && sourceA === sourceB
            case let (.utilityAssociationFilterResultView(_, _, elementA, titleA),
                      .utilityAssociationFilterResultView(_, _, elementB, titleB)):
                elementA === elementB
                && titleA == titleB
            case let (.utilityAssociationGroupResultView(_, _, elementA, filterTitleA, groupTitleA),
                      .utilityAssociationGroupResultView(_, _, elementB, filterTitleB, groupTitleB)):
                // TODO: Improve group identification (Apollo 1391).
                elementA === elementB
                && filterTitleA == filterTitleB
                && groupTitleA == groupTitleB
            case let (.utilityAssociationNetworkSourcesView(_, elementA, filterA),
                      .utilityAssociationNetworkSourcesView(_, elementB, filterB)):
                elementA === elementB
                && filterA === filterB
            default:
                false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .form(let form):
                hasher.combine(ObjectIdentifier(form))
            case .utilityAssociationCreationView(let candidate, _, _):
                hasher.combine(ObjectIdentifier(candidate))
            case .utilityAssociationDetailsView(_, _, let element, _):
                hasher.combine(element)
            case .utilityAssociationFeatureCandidatesView(_, _, let source):
                hasher.combine(ObjectIdentifier(source))
            case .utilityAssociationFilterResultView(_, _, let element, let filterTitle):
                hasher.combine(element)
                hasher.combine(filterTitle)
            case .utilityAssociationGroupResultView(_, _, let element, let filterTitle, let groupTitle):
                // TODO: Improve group identification (Apollo 1391).
                hasher.combine(element)
                hasher.combine(filterTitle)
                hasher.combine(groupTitle)
            case .utilityAssociationNetworkSourcesView(_, _, let filter):
                hasher.combine(ObjectIdentifier(filter))
            }
        }
    }
}
