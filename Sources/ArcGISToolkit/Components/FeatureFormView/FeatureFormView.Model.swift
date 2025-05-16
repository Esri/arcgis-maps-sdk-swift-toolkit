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
import Observation

@Observable
class FeatureFormViewModel {
#warning("The UtilityNetwork property is temporary only.")
    /// A utility network the root feature form view feature may belong to.
    let utilityNetwork: UtilityNetwork?
    
    /// A Boolean value indicating whether the add utility association screen is presented.
    var addUtilityAssociationScreenIsPresented = false
    
    /// The point at which to run feature identification when adding utility associations.
    var mapPoint: Point?
    
    /// The proxy to provide access to map view operations.
    var mapViewProxy: MapViewProxy?
    
    /// The selected utility association.
    var selectedAssociation: UtilityAssociation?
    
    /// A Boolean value indicating whether the utility association details screen is presented.
    var utilityAssociationDetailsScreenIsPresented = false
    
#warning("The UtilityNetwork parameter is temporary only.")
    /// Creates a view model for a feature form view.
    /// - Parameters:
    ///   - mapViewProxy: The proxy to provide access to map view operations.
    init(
        mapViewProxy: MapViewProxy? = nil,
        utilityNetwork: UtilityNetwork? = nil /* Temporary parameter only */
    ) {
        self.mapViewProxy = mapViewProxy
        self.utilityNetwork = utilityNetwork
    }
}
