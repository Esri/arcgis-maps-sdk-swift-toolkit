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
import OSLog
import UIKit.UIImage

/// Information for an online map that has been taken offline.
public struct OfflineMapInfo: Sendable {
    private let info: CodableInfo
    
    /// The thumbnail of the portal item associated with the map.
    public let thumbnail: UIImage?
    
    init?(portalItem: PortalItem) async {
        guard let id = portalItem.id?.rawValue,
              let url = portalItem.url
        else { return nil }
        
        // Get the thumbnail.
        try? await portalItem.load()
        if let loadableImage = portalItem.thumbnail {
            try? await loadableImage.load()
            thumbnail = loadableImage.image
        } else {
            thumbnail = nil
        }
        
        /// Save the codable info.
        info = .init(
            portalItemID: id,
            title: portalItem.title,
            description: portalItem.description,
            portalItemURL: url
        )
    }
    
    private init(info: OfflineMapInfo.CodableInfo, thumbnail: UIImage?) {
        self.info = info
        self.thumbnail = thumbnail
    }
    
    static func make(from url: URL) -> Self? {
        let infoURL = url.appending(components: "info.json")
        guard FileManager.default.fileExists(atPath: infoURL.path()) else { return nil }
        Logger.offlineManager.debug("Found offline map info at \(infoURL.path())")
        guard let data = try? Data(contentsOf: infoURL),
              let info = try? JSONDecoder().decode(OfflineMapInfo.CodableInfo.self, from: data)
        else { return nil }
        return .init(info: info, thumbnail: nil)
    }
    
    func save(to url: URL) {
        Logger.offlineManager.debug("Saving pending offline map info to \(url.path())")
        let infoURL = url.appending(path: "info.json")
        
        // Save info json to file.
        if let data = try? JSONEncoder().encode(info) {
            try? data.write(to: infoURL, options: .atomic)
        }
        
        // Save thumbnail to file.
        if let thumbnail, let pngData = thumbnail.pngData() {
            let thumbnailURL = url.appending(path: "thumbnail.png")
            try? pngData.write(to: thumbnailURL, options: .atomic)
        }
    }
    
    static func remove(from url: URL) {
        try? FileManager.default.removeItem(at: url.appending(path: "info.json"))
        try? FileManager.default.removeItem(at: url.appending(path: "thumbnail.png"))
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
