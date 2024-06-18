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
import Combine
import Foundation
import SwiftUI
import UIKit

extension OfflineMapAreasView {
    /// The model class for the offline map areas view.
    @MainActor
    class MapViewModel: ObservableObject {
        /// The portal item ID of the web map.
        private let portalItemID: PortalItem.ID?
        
        /// The offline map task.
        private let offlineMapTask: OfflineMapTask
        
        /// The preplanned offline map information.
        @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
        
        /// The offline preplanned map information.
        @Published private(set) var offlinePreplannedModels = [PreplannedMapModel]()
        
        init(map: Map) {
            offlineMapTask = OfflineMapTask(onlineMap: map)
            portalItemID = map.item?.id
        }
        
        /// Gets the preplanned map areas from the offline map task and creates the
        /// preplanned map models.
        func makePreplannedMapModels() async {
            guard let portalItemID else { return }
            
            preplannedMapModels = await Result {
                try await offlineMapTask.preplannedMapAreas
                    .filter { $0.id != nil }
                    .sorted(using: KeyPathComparator(\.portalItem.title))
                    .map {
                        PreplannedMapModel(
                            offlineMapTask: offlineMapTask,
                            mapArea: $0,
                            portalItemID: portalItemID,
                            preplannedMapAreaID: $0.id!
                        )
                    }
            }
        }
        
        /// Requests authorization to show notifications.
        func requestUserNotificationAuthorization() async {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        }
        
        /// Gets the preplanned map areas from local metadata json files.
        func makeOfflinePreplannedMapModels() {
            guard let portalItemID else { return }
            
            do {
                let portalItemDirectory = FileManager.default.preplannedDirectory(forPortalItemID: portalItemID)
                let preplannedMapAreaDirectories = try FileManager.default.contentsOfDirectory(
                    at: portalItemDirectory,
                    includingPropertiesForKeys: nil
                )
                
                let preplannedMapAreaIDs = preplannedMapAreaDirectories.map { Item.ID($0.lastPathComponent)! }
                let mapAreas = preplannedMapAreaIDs.compactMap { mapAreaID in
                    readMetadata(
                        for: portalItemID,
                        preplannedMapAreaID: mapAreaID
                    )
                }
                
                offlinePreplannedModels = mapAreas.map { mapArea in
                    PreplannedMapModel(
                        portalItemID: portalItemID,
                        mapAreaID: mapArea.id!,
                        mapArea: mapArea
                    )
                }
            } catch {
                return
            }
        }
        
        /// Reads the metadata for a given preplanned map area from a portal item and returns a preplanned
        /// map area protocol constructed with the metadata.
        /// - Parameters:
        ///   - portalItemID: The ID for the portal item.
        ///   - preplannedMapAreaID: The ID for the preplanned map area.
        /// - Returns: A preplanned map area protocol.
        private func readMetadata(for portalItemID: Item.ID, preplannedMapAreaID: Item.ID) -> PreplannedMapAreaProtocol? {
            do {
                let metadataPath = FileManager.default.metadataPath(
                    forPortalItemID: portalItemID,
                    preplannedMapAreaID: preplannedMapAreaID
                )
                let contentString = try String(contentsOf: metadataPath)
                let jsonData = Data(contentString.utf8)
                
                let thumbnailURL = FileManager.default.thumbnailPath(
                    forPortalItemID: portalItemID,
                    preplannedMapAreaID: preplannedMapAreaID
                )
                let thumbnailImage = UIImage(contentsOfFile: thumbnailURL.relativePath)
                
                if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    guard let title = json["title"] as? String,
                          let description = json["description"] as? String,
                          let id = json["id"] as? String,
                          let itemID = Item.ID(id) else { return nil }
                    return OfflinePreplannedMapArea(
                        title: title,
                        description: description,
                        thumbnailImage: thumbnailImage,
                        id: itemID
                    )
                }
            } catch {
                return nil
            }
            return nil
        }
    }
}

private struct OfflinePreplannedMapArea: PreplannedMapAreaProtocol {
    var packagingStatus: PreplannedMapArea.PackagingStatus?
    
    var title: String
    
    var description: String
    
    var thumbnail: LoadableImage?
    
    var thumbnailImage: UIImage?
    
    var id: ArcGIS.Item.ID?
    
    func retryLoad() async throws {}
    
    func makeParameters(using offlineMapTask: ArcGIS.OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
        DownloadPreplannedOfflineMapParameters()
    }
    
    init(
        title: String,
        description: String,
        thumbnailImage: UIImage? = nil,
        id: ArcGIS.Item.ID? = nil
    ) {
        self.title = title
        self.description = description
        self.thumbnailImage = thumbnailImage
        self.id = id
    }
}
