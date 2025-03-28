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
    
    /// Creates offline map info from a portal item.
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
    
    /// Creates offline map info.
    private init(info: OfflineMapInfo.CodableInfo, thumbnail: UIImage?) {
        self.info = info
        self.thumbnail = thumbnail
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

extension OfflineMapInfo: Identifiable {
    public var id: Item.ID { portalItemID }
}

private extension OfflineMapInfo {
    /// The codable info is stored in json.
    struct CodableInfo: Codable {
        let portalItemID: String
        let title: String
        let description: String
        let portalItemURL: URL
    }
}

private extension OfflineMapInfo {
    /// The URLs for serialized offline map info.
    struct URLs {
        let info: URL
        let thumbnail: URL
    }
    
    /// The URLs that offline map info is serialized to for a given directory.
    static func urls(for directory: URL) -> URLs {
        .init(
            info: directory.appending(path: "info.json"),
            thumbnail: directory.appending(path: "thumbnail.png")
        )
    }
}

extension OfflineMapInfo {
    /// Creates offline map info from a directory.
    static func make(from directory: URL) -> Self? {
        let urls = Self.urls(for: directory)
        guard FileManager.default.fileExists(atPath: urls.info.path()) else { return nil }
        Logger.offlineManager.debug("Found offline map info at \(urls.info.path())")
        guard let data = try? Data(contentsOf: urls.info),
              let info = try? JSONDecoder().decode(CodableInfo.self, from: data)
        else { return nil }
        let thumbnail = UIImage(contentsOfFile: urls.thumbnail.path())
        return .init(info: info, thumbnail: thumbnail)
    }
    
    /// Saves offline map info to a directory.
    func save(to directory: URL) {
        Logger.offlineManager.debug("Saving pending offline map info to \(directory.path())")
        
        let urls = Self.urls(for: directory)
        
        // Save info json to file.
        if let data = try? JSONEncoder().encode(info) {
            try? data.write(to: urls.info, options: .atomic)
        }
        
        // Save thumbnail to file.
        if let pngData = thumbnail?.pngData() {
            try? pngData.write(to: urls.thumbnail, options: .atomic)
        }
    }
    
    /// Removes saved offline map info from a directory.
    static func remove(from directory: URL) {
        Logger.offlineManager.debug("Removing offline map info from \(directory.path())")
        let urls = Self.urls(for: directory)
        try? FileManager.default.removeItem(at: urls.info)
        try? FileManager.default.removeItem(at: urls.thumbnail)
    }
    
    /// Whether or not saved offline map info exists in a directory.
    static func doesInfoExists(at directory: URL) -> Bool {
        let urls = Self.urls(for: directory)
        return FileManager.default.fileExists(atPath: urls.info.path())
    }
}
