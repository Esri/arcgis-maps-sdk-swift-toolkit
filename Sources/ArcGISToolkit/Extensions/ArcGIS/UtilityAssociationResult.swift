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

extension UtilityAssociationResult {
    /// The utility element which is the associated feature.
    var associatedElement: UtilityElement {
        associatedFeatureIsToElement ? association.toElement : association.fromElement
    }
    
    /// A Boolean value indicating whether the `associatedFeature` global ID
    /// matches the `toElement` global ID.
    var associatedFeatureIsToElement: Bool {
        associatedFeature.globalID == association.toElement.globalID
    }
}
