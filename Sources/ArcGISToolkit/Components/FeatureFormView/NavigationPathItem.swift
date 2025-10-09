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
    public enum NavigationPathItem: Hashable {
        case form(FeatureForm)
        case utilityAssociationAssetTypesView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationsFilter, UtilityAssociationFeatureSource)
        case utilityAssociationCreationView(FeatureForm, UtilityAssociationFeatureCandidate, UtilityAssociationsFormElement, UtilityAssociationsFilter)
        case utilityAssociationDetailsView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationResult)
        case utilityAssociationFeatureCandidatesView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationsFilter, UtilityAssociationFeatureSource, UtilityAssetType)
        case utilityAssociationFeatureSourcesView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationsFilter)
        case utilityAssociationFilterResultView(FeatureForm, UtilityAssociationsFormElement, String)
        case utilityAssociationGroupResultView(FeatureForm, UtilityAssociationsFormElement, String, String)
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.form(a), .form(b)):
                a === b
            case let (.utilityAssociationAssetTypesView(_, elementA, filterA, sourceA),
                      .utilityAssociationAssetTypesView(_, elementB, filterB, sourceB)):
                elementA === elementB
                && filterA === filterB
                && sourceA === sourceB
            case let (.utilityAssociationCreationView(_, candidateA, elementA, filterA),
                      .utilityAssociationCreationView(_, candidateB, elementB, filterB)):
                candidateA === candidateB
                && elementA === elementB
                && filterA === filterB
            case let (.utilityAssociationDetailsView(_, elementA, resultA),
                      .utilityAssociationDetailsView(_, elementB, resultB)):
                elementA === elementB
                && resultA === resultB
            case let (.utilityAssociationFeatureCandidatesView(_, elementA, filterA, sourceA, _),
                      .utilityAssociationFeatureCandidatesView(_, elementB, filterB, sourceB, _)):
                elementA === elementB
                && filterA === filterB
                && sourceA === sourceB
            case let (.utilityAssociationFeatureSourcesView(_, elementA, filterA),
                      .utilityAssociationFeatureSourcesView(_, elementB, filterB)):
                elementA === elementB
                && filterA === filterB
            case let (.utilityAssociationFilterResultView(_, elementA, titleA),
                      .utilityAssociationFilterResultView(_, elementB, titleB)):
                elementA === elementB
                && titleA == titleB
            case let (.utilityAssociationGroupResultView(_, elementA, filterTitleA, groupTitleA),
                      .utilityAssociationGroupResultView(_, elementB, filterTitleB, groupTitleB)):
                // TODO: Improve group identification (Apollo 1391).
                elementA === elementB
                && filterTitleA == filterTitleB
                && groupTitleA == groupTitleB
            default:
                false
            }
        }
        
        public func hash(into hasher: inout Hasher) {
            switch self {
            case let .form(form):
                hasher.combine(ObjectIdentifier(form))
            case let .utilityAssociationAssetTypesView(_, element, filter, source):
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
                hasher.combine(ObjectIdentifier(source))
            case let .utilityAssociationCreationView(_, candidate, element, filter):
                hasher.combine(ObjectIdentifier(candidate))
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
            case let .utilityAssociationDetailsView(_, element, result):
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(result))
            case let .utilityAssociationFeatureCandidatesView(_, element, filter, source, _):
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
                hasher.combine(ObjectIdentifier(source))
            case let .utilityAssociationFeatureSourcesView(_, element, filter):
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
            case let .utilityAssociationFilterResultView(_, element, filterTitle):
                hasher.combine(element)
                hasher.combine(filterTitle)
            case let .utilityAssociationGroupResultView(_, element, filterTitle, groupTitle):
                // TODO: Improve group identification (Apollo 1391).
                hasher.combine(element)
                hasher.combine(filterTitle)
                hasher.combine(groupTitle)
            }
        }
    }
}
