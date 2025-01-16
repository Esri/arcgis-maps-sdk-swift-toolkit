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

extension OfflineMapAreasView {
    /// The model class for the offline map areas view.
    @MainActor
    class MapViewModel: ObservableObject {
        /// The portal item ID of the web map.
        private let portalItemID: PortalItem.ID
        
        /// The offline map task.
        private let offlineMapTask: OfflineMapTask
        
        /// The preplanned map information.
        @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
        
        /// A Boolean value indicating if only offline models are being shown.
        @Published private(set) var isShowingOnlyOfflineModels = false
        
        /// The online map.
        private let onlineMap: Map
        
        /// Creates an offline map areas view model for a given web map.
        /// - Parameter map: The web map.
        /// - Precondition: `map.item?.id` is not `nil`.
        init(map: Map) {
            precondition(map.item?.id != nil)
            offlineMapTask = OfflineMapTask(onlineMap: map)
            onlineMap = map
            portalItemID = map.item!.id!
        }
        
        /// Gets the preplanned map areas from the offline map task and loads the map models.
        func loadPreplannedMapModels() async {
            if offlineMapTask.loadStatus != .loaded {
                try? await offlineMapTask.retryLoad()
            }
            
            // Reset flag
            isShowingOnlyOfflineModels = false
            
            preplannedMapModels = await Result { @MainActor in
                do {
                    return try await offlineMapTask.preplannedMapAreas
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
                } catch {
                    // If not connected to the internet, then return only the offline models.
                    if let urlError = error as? URLError,
                       urlError.code == .notConnectedToInternet {
                        isShowingOnlyOfflineModels = true
                        return await loadOfflinePreplannedMapModels()
                    } else {
                        throw error
                    }
                }
            }
        }
        
        /// Loads the offline preplanned map models with information from the downloaded mobile map
        /// packages for the online map.
        func loadOfflinePreplannedMapModels() async -> [PreplannedMapModel] {
            let preplannedDirectory = URL.preplannedDirectory(forPortalItemID: portalItemID)
            
            guard let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: preplannedDirectory.path()) else { return [] }
            
            var preplannedMapModels: [PreplannedMapModel] = []
            
            for mapAreaID in mapAreaIDs {
                guard let preplannedMapAreaID = PortalItem.ID(mapAreaID),
                      let mapArea = await makeMapArea(
                        portalItemID: portalItemID,
                        preplannedMapAreaID: preplannedMapAreaID
                      ) else {
                    continue
                }
                let model = PreplannedMapModel(
                    offlineMapTask: offlineMapTask,
                    mapArea: mapArea,
                    portalItemID: portalItemID,
                    preplannedMapAreaID: mapArea.id!
                )
                preplannedMapModels.append(model)
            }
            
            return preplannedMapModels
                .filter(\.status.isDownloaded)
                .sorted(by: { $0.preplannedMapArea.title < $1.preplannedMapArea.title })
        }
        
        /// Creates a preplanned map area using a given portal item and map area ID to search for a corresponding
        /// downloaded mobile map package. If the mobile map package is not found then `nil` is returned.
        /// - Parameters:
        ///   - portalItemID: The portal item ID.
        ///   - preplannedMapAreaID: The preplanned map area ID.
        /// - Returns: The preplanned map area.
        private func makeMapArea(
            portalItemID: PortalItem.ID,
            preplannedMapAreaID: PortalItem.ID
        ) async -> OfflinePreplannedMapArea? {
            let fileURL = URL.preplannedDirectory(
                forPortalItemID: portalItemID,
                preplannedMapAreaID: preplannedMapAreaID
            )
            guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil }
            let mmpk = MobileMapPackage(fileURL: fileURL)
            
            try? await mmpk.load()
            guard let item = mmpk.item else { return nil }
            
            return .init(
                title: item.title,
                description: item.description,
                id: preplannedMapAreaID,
                thumbnail: item.thumbnail
            )
        }
        
        
        /// A Boolean value indicating whether the web map is offline disabled.
        var mapIsOfflineDisabled: Bool {
            onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil
        }
    }
}

private struct OfflinePreplannedMapArea: PreplannedMapAreaProtocol {
    var title: String
    var description: String
    var id: PortalItem.ID?
    var packagingStatus: PreplannedMapArea.PackagingStatus?
    var thumbnail: LoadableImage?
    
    func retryLoad() async throws {}
    
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
        fatalError()
    }
}
