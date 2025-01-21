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

/// Information for an online map that has been taken offline.
public struct OfflineMapInfo: Codable {
    private var portalItemIDRawValue: String
    /// The title of the portal item associated with the map.
    public var title: String
    /// The description of the portal item associated with the map.
    public var description: String
    /// The URL of the portal item associated with the map.
    public var portalItemURL: URL
    
    internal init?(portalItem: PortalItem) {
        guard let idRawValue = portalItem.id?.rawValue,
              let url = portalItem.url
        else { return nil }
        
        self.portalItemIDRawValue = idRawValue
        self.title = portalItem.title
        self.description = portalItem.description.replacing(/<[^>]+>/, with: "")
        self.portalItemURL = url
    }
}

public extension OfflineMapInfo {
    /// The ID of the portal item associated with the map.
    var portalItemID: Item.ID {
        .init(portalItemIDRawValue)!
    }
}
