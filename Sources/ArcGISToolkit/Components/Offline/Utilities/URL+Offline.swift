// Copyright 2024 Esri
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

extension URL {
    /// The path to the web map directory for a specific portal item.
    /// `Documents/OfflineMapAreas/<Portal Item ID>/`
    /// - Parameter portalItemID: The ID of the web map portal item.
    static private func portalItemDirectory(forPortalItemID portalItemID: Item.ID) -> URL {
        return .documentsDirectory.appending(components: "OfflineMapAreas", "\(portalItemID)/")
    }
    
    /// The path to the directory for a specific map area from the preplanned map areas directory for a specific portal item.
    /// `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/<Preplanned Area ID>/`
    /// - Parameters:
    ///   - portalItemID: The ID of the web map portal item.
    ///   - preplannedMapAreaID: The ID of the preplanned map area portal item.
    /// - Returns: A URL to the preplanned map area directory.
    static func preplannedDirectory(
        forPortalItemID portalItemID: Item.ID,
        preplannedMapAreaID: Item.ID? = nil
    ) -> URL {
        var url = portalItemDirectory(forPortalItemID: portalItemID)
            .appending(component: "Preplanned/")
        if let preplannedMapAreaID {
            url = url.appending(component: "\(preplannedMapAreaID)/")
        }
        return url
    }
}
