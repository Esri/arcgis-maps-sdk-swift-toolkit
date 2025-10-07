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
        case utilityAssociationCreationView(EmbeddedFeatureFormViewModel, UtilityAssociationFeatureCandidate, UtilityAssociationsFormElement, UtilityAssociationsFilter)
        case utilityAssociationDetailsView(EmbeddedFeatureFormViewModel, AssociationsFilterResultsModel, UtilityAssociationsFormElement, UtilityAssociationResult)
        case utilityAssociationFeatureCandidatesView(EmbeddedFeatureFormViewModel, UtilityAssociationsFormElement, UtilityAssociationsFilter, UtilityAssociationFeatureSource)
        case utilityAssociationFeatureSourcesView(EmbeddedFeatureFormViewModel, UtilityAssociationsFormElement, UtilityAssociationsFilter)
        case utilityAssociationFilterResultView(EmbeddedFeatureFormViewModel, AssociationsFilterResultsModel, UtilityAssociationsFormElement, UtilityAssociationsFilter)
        case utilityAssociationGroupResultView(EmbeddedFeatureFormViewModel, AssociationsFilterResultsModel, UtilityAssociationsFormElement, UtilityAssociationsFilter, FeatureFormSource, String)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.form(a), .form(b)):
                a === b
            case let (.utilityAssociationCreationView(_, candidateA, elementA, filterA),
                      .utilityAssociationCreationView(_, candidateB, elementB, filterB)):
                candidateA === candidateB
                && elementA === elementB
                && filterA === filterB
            case let (.utilityAssociationDetailsView(_, _, elementA, resultA),
                      .utilityAssociationDetailsView(_, _, elementB, resultB)):
                elementA === elementB
                && resultA === resultB
            case let (.utilityAssociationFeatureCandidatesView(_, elementA, filterA, sourceA),
                      .utilityAssociationFeatureCandidatesView(_, elementB, filterB, sourceB)):
                elementA === elementB
                && filterA === filterB
                && sourceA === sourceB
            case let (.utilityAssociationFeatureSourcesView(_, elementA, filterA),
                      .utilityAssociationFeatureSourcesView(_, elementB, filterB)):
                elementA === elementB
                && filterA === filterB
            case let (.utilityAssociationFilterResultView(_, _, elementA, filterA),
                      .utilityAssociationFilterResultView(_, _, elementB, filterB)):
                elementA === elementB
                && filterA === filterB
            case let (.utilityAssociationGroupResultView(_, _, elementA, filterA, sourceA, _),
                      .utilityAssociationGroupResultView(_, _, elementB, filterB, sourceB, _)):
                elementA === elementB
                && filterA === filterB
                && sourceA === sourceB
            default:
                false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .form(form):
                hasher.combine(ObjectIdentifier(form))
            case let .utilityAssociationCreationView(_, candidate, element, filter):
                hasher.combine(ObjectIdentifier(candidate))
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
            case let .utilityAssociationDetailsView(_, _, element, result):
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(result))
            case let .utilityAssociationFeatureCandidatesView(_, element, filter, source):
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
                hasher.combine(ObjectIdentifier(source))
            case let .utilityAssociationFeatureSourcesView(_, element, filter):
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
            case .utilityAssociationFilterResultView(_, _, let element, let filter):
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
            case .utilityAssociationGroupResultView(_, _, let element, let filter, let formSource, _):
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
                hasher.combine(ObjectIdentifier(formSource))
            }
        }
    }
}
