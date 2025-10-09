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
        case utilityAssociationCreationView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationsFilter, UtilityAssociationFeatureCandidate)
        case utilityAssociationDetailsView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationResult)
        case utilityAssociationFeatureCandidatesView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationsFilter, UtilityAssociationFeatureSource, UtilityAssetType)
        case utilityAssociationFeatureSourcesView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationsFilter)
        case utilityAssociationFilterResultView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationsFilter)
        case utilityAssociationGroupResultView(FeatureForm, UtilityAssociationsFormElement, UtilityAssociationsFilter, FeatureFormSource, String)
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.form(a), .form(b)):
                a === b
            case let (.utilityAssociationAssetTypesView(formA, elementA, filterA, sourceA),
                      .utilityAssociationAssetTypesView(formB, elementB, filterB, sourceB)):
                formA === formB
                && elementA === elementB
                && filterA === filterB
                && sourceA === sourceB
            case let (.utilityAssociationCreationView(formA, elementA, filterA, candidateA),
                      .utilityAssociationCreationView(formB, elementB, filterB, candidateB)):
                formA === formB
                && elementA === elementB
                && filterA === filterB
                && candidateA === candidateB
            case let (.utilityAssociationDetailsView(formA, elementA, resultA),
                      .utilityAssociationDetailsView(formB, elementB, resultB)):
                formA === formB
                && elementA === elementB
                && resultA === resultB
            case let (.utilityAssociationFeatureCandidatesView(formA, elementA, filterA, sourceA, _),
                      .utilityAssociationFeatureCandidatesView(formB, elementB, filterB, sourceB, _)):
                formA === formB
                && elementA === elementB
                && filterA === filterB
                && sourceA === sourceB
            case let (.utilityAssociationFeatureSourcesView(formA, elementA, filterA),
                      .utilityAssociationFeatureSourcesView(formB, elementB, filterB)):
                formA === formB
                && elementA === elementB
                && filterA === filterB
            case let (.utilityAssociationFilterResultView(formA, elementA, filterA),
                      .utilityAssociationFilterResultView(formB, elementB, filterB)):
                formA === formB
                && elementA === elementB
                && filterA === filterB
            case let (.utilityAssociationGroupResultView(formA, elementA, filterA, sourceA, _),
                      .utilityAssociationGroupResultView(formB, elementB, filterB, sourceB, _)):
                formA === formB
                && elementA === elementB
                && filterA === filterB
                && sourceA === sourceB
            default:
                false
            }
        }
        
        public func hash(into hasher: inout Hasher) {
            switch self {
            case let .form(form):
                hasher.combine(ObjectIdentifier(form))
            case let .utilityAssociationAssetTypesView(form, element, filter, source):
                hasher.combine(ObjectIdentifier(form))
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
                hasher.combine(ObjectIdentifier(source))
            case let .utilityAssociationCreationView(form, element, filter, candidate):
                hasher.combine(ObjectIdentifier(form))
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
                hasher.combine(ObjectIdentifier(candidate))
            case let .utilityAssociationDetailsView(form, element, result):
                hasher.combine(ObjectIdentifier(form))
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(result))
            case let .utilityAssociationFeatureCandidatesView(form, element, filter, source, _):
                hasher.combine(ObjectIdentifier(form))
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
                hasher.combine(ObjectIdentifier(source))
            case let .utilityAssociationFeatureSourcesView(form, element, filter):
                hasher.combine(ObjectIdentifier(form))
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
            case let .utilityAssociationFilterResultView(form, element, filter):
                hasher.combine(ObjectIdentifier(form))
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
            case let .utilityAssociationGroupResultView(form, element, filter, formSource, _):
                hasher.combine(ObjectIdentifier(form))
                hasher.combine(element)
                hasher.combine(ObjectIdentifier(filter))
                hasher.combine(ObjectIdentifier(formSource))
            }
        }
    }
}
