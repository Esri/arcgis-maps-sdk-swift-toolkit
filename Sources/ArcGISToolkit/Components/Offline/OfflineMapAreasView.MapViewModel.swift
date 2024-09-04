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
import UserNotifications

extension OfflineMapAreasView {
    /// The model class for the offline map areas view.
    @MainActor
    class MapViewModel: ObservableObject {
        /// The portal item ID of the web map.
        private let portalItemID: PortalItem.ID?
        
        /// The offline map task.
        private let offlineMapTask: OfflineMapTask
        
        /// The preplanned map information.
        @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
        
        /// The offline preplanned map information sourced from downloaded mobile map packages.
        @Published private(set) var offlinePreplannedMapModels: [PreplannedMapModel]?
        
        init(map: Map) {
            offlineMapTask = OfflineMapTask(onlineMap: map)
            portalItemID = map.item?.id
        }
        
        /// Requests authorization to show notifications.
        nonisolated func requestUserNotificationAuthorization() async {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        }
        
        /// Gets the preplanned map areas from the offline map task and creates the map models.
        func makePreplannedMapModels() async {
            guard let portalItemID else { return }
            
            preplannedMapModels = await Result { @MainActor in
                try await offlineMapTask.preplannedMapAreas
                    .filter { $0.portalItem.id != nil }
                    .sorted(using: KeyPathComparator(\.portalItem.title))
                    .map {
                        PreplannedMapModel(
                            offlineMapTask: offlineMapTask,
                            mapArea: $0,
                            portalItemID: portalItemID,
                            preplannedMapAreaID: $0.portalItem.id!
                        )
                    }
            }
        }
        
        /// Makes offline preplanned map models with infomation from the downloaded mobile map 
        /// packages for the online map.
        func makeOfflinePreplannedMapModels() async {
            guard let portalItemID else { return }
            
            let preplannedDirectory = FileManager.default.preplannedDirectory(forPortalItemID: portalItemID)
            
            guard let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: preplannedDirectory.path()) else { return }
            
            var mapAreas: [OfflinePreplannedMapArea] = []
            
            for mapAreaID in mapAreaIDs {
                if let preplannedMapAreaID = PortalItem.ID(mapAreaID),
                   let mapArea = await createMapArea(
                    for: portalItemID,
                    preplannedMapAreaID: preplannedMapAreaID
                   ) {
                    mapAreas.append(mapArea)
                }
            }
            
            offlinePreplannedMapModels = mapAreas.map { mapArea in
                PreplannedMapModel(
                    offlineMapTask: offlineMapTask,
                    mapArea: mapArea,
                    portalItemID: portalItemID,
                    preplannedMapAreaID: mapArea.id!
                )
            }
            .sorted(using: KeyPathComparator(\.preplannedMapArea.title))
        }
        
        /// Creates a preplanned map area using a given portal item and map area ID to search for a corresponding
        /// downloaded mobile map package. If the mobile map package is not found then `nil` is returned.
        /// - Parameters:
        ///   - portalItemID: The portal item ID.
        ///   - preplannedMapAreaID: The preplanned map area ID.
        /// - Returns: The preplanned map area.
        private func createMapArea(
            for portalItemID: PortalItem.ID,
            preplannedMapAreaID: PortalItem.ID
        ) async -> OfflinePreplannedMapArea? {
            let fileURL = FileManager.default.preplannedDirectory(
                forPortalItemID: portalItemID,
                preplannedMapAreaID: preplannedMapAreaID
            )
            guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil }
            // Make sure the directory is not empty because the directory will exist as soon as the
            // job starts, so if the job fails, it will look like the mmpk was downloaded.
            guard !FileManager.default.isDirectoryEmpty(atPath: fileURL) else { return nil }
            let mmpk = MobileMapPackage.init(fileURL: fileURL)
            
            try? await mmpk.load()
            guard let item = mmpk.item else { return nil }
            
            return OfflinePreplannedMapArea(
                title: item.title,
                description: item.description,
                id: preplannedMapAreaID,
                thumbnail: item.thumbnail
            )
        }
    }
}

private struct OfflinePreplannedMapArea: PreplannedMapAreaProtocol {
    var packagingStatus: PreplannedMapArea.PackagingStatus?
    var title: String
    var description: String
    var thumbnail: LoadableImage?
    var id: PortalItem.ID?
    
    func retryLoad() async throws {}
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
        throw CancellationError()
    }
    
    init(
        title: String,
        description: String,
        id: PortalItem.ID,
        thumbnail: LoadableImage? = nil
    ) {
        self.title = title
        self.description = description
        self.id = id
        self.thumbnail = thumbnail
    }
}
