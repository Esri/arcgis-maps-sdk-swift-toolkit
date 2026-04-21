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
import SwiftUI

extension ArcGISFeature {
    /// The feature's feature layer.
    var featureLayer: FeatureLayer? {
        table?.layer as? FeatureLayer
    }
    
    /// The global ID of the feature.
    ///
    /// This property is `nil` if there is no global ID.
    var globalID: UUID? {
        attributes.valueIgnoringCase(for: "globalid") as? UUID
    }
    
    /// The symbol for the feature from its layer.
    var symbol: Image? {
        get async {
            guard let swatch = try? await featureLayer?
                .renderer?
                .symbol(for: self)?
                .makeSwatch(scale: 1.0) else {
                return nil
            }
            return Image(uiImage: swatch)
        }
    }
}
