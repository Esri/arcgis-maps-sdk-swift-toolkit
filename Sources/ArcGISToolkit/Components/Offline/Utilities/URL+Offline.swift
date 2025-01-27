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
    /// The path to the offline manager directory.
    /// `Documents/com.esri.ArcGISToolkit.offlineManager/`
    /// - Returns: A URL to the offline manager directory.
    static func offlineManagerDirectory() -> URL {
        return .documentsDirectory.appending(path: "com.esri.ArcGISToolkit.offlineManager")
    }
    
    /// The path to the web map directory for a specific portal item.
    /// `Documents/OfflineMapAreas/<Portal Item ID>/`
    /// - Parameter portalItemID: The ID of the web map portal item.
    static func portalItemDirectory(forPortalItemID portalItemID: Item.ID) -> URL {
        return offlineManagerDirectory().appending(path: portalItemID.rawValue)
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
            url = url.appending(component: preplannedMapAreaID.rawValue)
        }
        return url
    }
    
    static func onDemandDirectory(
        forPortalItemID portalItemID: PortalItem.ID,
        onDemandMapAreaID: UUID? = nil
    ) -> URL {
        var url = portalItemDirectory(forPortalItemID: portalItemID)
            .appending(component: "OnDemand/")
        if let onDemandMapAreaID {
            url = url.appending(component: onDemandMapAreaID.uuidString)
        }
        return url
    }
    
    /// The path to the pending map info directory for a specific portal item.
    /// `Caches/PendingDownloads/<Portal Item ID>/`
    /// - Parameter portalItemID: The ID of the web map portal item.
    /// - Returns: A URL to the pending map info directory.
    static func pendingMapInfoDirectory(
        forPortalItem portalItemID: Item.ID
    ) -> URL {
        return .cachesDirectory.appending(components: "PendingDownloads", portalItemID.rawValue)
    }
}
