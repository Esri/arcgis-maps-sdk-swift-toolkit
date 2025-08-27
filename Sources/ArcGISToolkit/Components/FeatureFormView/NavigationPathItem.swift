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
        case utilityAssociationFilterResultView(EmbeddedFeatureFormViewModel, UtilityAssociationsFormElement, UtilityAssociationsFilterResult)
        case utilityAssociationGroupResultView(EmbeddedFeatureFormViewModel, UtilityAssociationsFormElement, UtilityAssociationGroupResult)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.form(a), .form(b)):
                a === b
            case let (.utilityAssociationFilterResultView(_, _, a), .utilityAssociationFilterResultView(_, _, b)):
                a === b
            case let (.utilityAssociationGroupResultView(_, _, a), .utilityAssociationGroupResultView(_, _, b)):
                a === b
            default:
                false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .form(let form):
                hasher.combine(ObjectIdentifier(form))
            case .utilityAssociationFilterResultView(_, _, let result):
                hasher.combine(ObjectIdentifier(result))
            case .utilityAssociationGroupResultView(_, _, let result):
                hasher.combine(ObjectIdentifier(result))
            }
        }
    }
}
