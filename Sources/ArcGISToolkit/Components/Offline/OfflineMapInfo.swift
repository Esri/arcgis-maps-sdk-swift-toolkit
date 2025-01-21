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
import Foundation
import UIKit.UIImage

/// Information for an online map that has been taken offline.
public struct OfflineMapInfo: Sendable {
    /// The thumbnail of the portal item associated with the map.
    public var thumbnail: UIImage?
    private var info: CodableInfo
    
    init?(portalItem: PortalItem) async {
        guard let id = portalItem.id?.rawValue,
              let url = portalItem.url
        else { return nil }
        
        // Get the thumbnail.
        try? await portalItem.load()
        if let loadableImage = portalItem.thumbnail {
            try? await loadableImage.load()
            thumbnail = loadableImage.image
        }
        
        /// Save the codable info.
        info = .init(
            portalItemID: id,
            title: portalItem.title,
            description: portalItem.description.replacing(/<[^>]+>/, with: ""),
            portalItemURL: url
        )
    }
}

public extension OfflineMapInfo {
    /// The title of the portal item associated with the map.
    var title: String { info.title }
    /// The description of the portal item associated with the map.
    var description: String { info.description }
    /// The URL of the portal item associated with the map.
    var portalItemURL: URL { info.portalItemURL }
    /// The ID of the portal item associated with the map.
    var portalItemID: Item.ID { .init(info.portalItemID)! }
}

/// Information for an online map that has been taken offline.
private extension OfflineMapInfo {
    struct CodableInfo: Codable {
        let portalItemID: String
        let title: String
        let description: String
        let portalItemURL: URL
    }
}
