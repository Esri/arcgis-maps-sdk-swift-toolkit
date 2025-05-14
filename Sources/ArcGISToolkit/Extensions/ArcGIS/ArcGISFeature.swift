// Copyright 2022 Esri
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
import Foundation

extension ArcGISFeature {
    /// The feature's feature layer.
    var featureLayer: FeatureLayer? {
        table?.layer as? FeatureLayer
    }
    
    /// The global ID of the feature.
    ///
    /// This property is `nil` if there is no global ID.
    var globalID: UUID? {
        if let id = attributes["globalid"] as? UUID {
            return id
        } else if let id = attributes["GLOBALID"] as? UUID {
            return id
        } else {
            return nil
        }
    }
    
    /// The object ID of the feature.
    ///
    /// This property is `nil` if there is no object ID.
    var objectID: Int64? {
        if let id = attributes["objectid"] as? Int64 {
            return id
        } else if let id = attributes["OBJECTID"] as? Int64 {
            return id
        } else {
            return nil
        }
    }
}
