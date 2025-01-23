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

/// The model class that represents information for an offline map.
@MainActor
class OfflineMapViewModel: ObservableObject {
    /// The portal item ID of the web map.
    private let portalItemID: Item.ID
    
    /// The offline map task.
    private let offlineMapTask: OfflineMapTask
    
    /// The preplanned map information.
    @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
    
    /// A Boolean value indicating if only offline models are being shown.
    @Published private(set) var isShowingOnlyOfflineModels = false
    
    /// The on-demand map information.
    @Published private(set) var onDemandMapModels: [OnDemandMapModel]?
    
    /// The online map.
    private let onlineMap: Map
    
    /// A Boolean value indicating whether the web map is offline disabled.
    var mapIsOfflineDisabled: Bool {
        onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil
    }
    
    /// Creates an offline map areas view model for a given web map.
    /// - Parameter onlineMap: The web map.
    /// - Precondition: `onlineMap.item?.id` is not `nil`.
    init(onlineMap: Map) {
        precondition(onlineMap.item?.id != nil)
        offlineMapTask = OfflineMapTask(onlineMap: onlineMap)
        self.onlineMap = onlineMap
        portalItemID = onlineMap.item!.id!
    }
    
    /// Gets the preplanned map areas from the offline map task and loads the map models.
    func loadPreplannedMapModels() async {
        if offlineMapTask.loadStatus != .loaded {
            try? await offlineMapTask.retryLoad()
        }
        
        // Reset flag.
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
                            preplannedMapAreaID: $0.portalItem.id!,
                            onRemoveDownload: onRemoveDownloadOfPreplannedArea(withID:)
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
            guard let preplannedMapAreaID = Item.ID(mapAreaID),
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
                preplannedMapAreaID: mapArea.id!,
                onRemoveDownload: onRemoveDownloadOfPreplannedArea(withID:)
            )
            preplannedMapModels.append(model)
        }
        
        return preplannedMapModels
            .filter(\.status.isDownloaded)
            .sorted(by: { $0.preplannedMapArea.title < $1.preplannedMapArea.title })
    }
    
    /// The function called when a downloaded preplanned map area is removed.
    func onRemoveDownloadOfPreplannedArea(withID preplannedAreaID: Item.ID) {
        // Delete the saved map info if there are no more downloads for the
        // represented online map.
        guard case.success(let models) = preplannedMapModels,
              models.filter(\.status.isDownloaded).isEmpty
        else { return }
        OfflineManager.shared.removeMapInfo(for: portalItemID)
    }
    
    /// Creates a preplanned map area using a given portal item and map area ID to search for a corresponding
    /// downloaded mobile map package. If the mobile map package is not found then `nil` is returned.
    /// - Parameters:
    ///   - portalItemID: The portal item ID.
    ///   - preplannedMapAreaID: The preplanned map area ID.
    /// - Returns: The preplanned map area.
    private func makeMapArea(
        portalItemID: Item.ID,
        preplannedMapAreaID: Item.ID
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
    
    private func makeOnDemandMapArea(
        portalItemID: PortalItem.ID,
        onDemandMapAreaID: UUID
    ) async -> OfflineOnDemandMapArea? {
        let fileURL = URL.onDemandDirectory(
            forPortalItemID: portalItemID,
            onDemandMapAreaID: onDemandMapAreaID
        )
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil }
        let mmpk = MobileMapPackage(fileURL: fileURL)
        
        try? await mmpk.load()
        guard let item = mmpk.item else { return nil }

        return .init(
            id: onDemandMapAreaID,
            title: item.title,
            description: item.description,
            thumbnail: item.thumbnail
        )
    }
    
    func loadOnDemandMapModels() async {
        let onDemandDirectory = URL.onDemandDirectory(forPortalItemID: portalItemID)
        
        guard let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: onDemandDirectory.path()) else {
            onDemandMapModels = []
            return
        }
        
        var onDemandMapModels: [OnDemandMapModel] = []
        
        // Look up the ongoing jobs for on-demand map models.
        let ongoingJobs = OfflineManager.shared.jobs
            .lazy
            .compactMap { $0 as? GenerateOfflineMapJob }
            .filter {
                UUID(uuidString: $0.downloadDirectoryURL.deletingPathExtension().lastPathComponent) != nil
            }
        
        for job in ongoingJobs {
            let id = UUID(uuidString: job.downloadDirectoryURL.deletingPathExtension().lastPathComponent)!
            let parameters = job.parameters
            guard let info = parameters.itemInfo, let minScale = parameters.minScale, let maxScale = parameters.maxScale, let aoi = parameters.areaOfInterest else {
                continue
            }
            let mapArea = OnDemandMapArea(id: id, title: info.title, minScale: minScale, maxScale: maxScale, areaOfInterest: aoi)
            let model = OnDemandMapModel(
                offlineMapTask: offlineMapTask,
                onDemandMapArea: mapArea,
                portalItemID: portalItemID
            )
            onDemandMapModels.append(model)
        }
        
        // Look up the downloaded on-demand map models.
        for mapAreaID in mapAreaIDs {
            guard let onDemandMapAreaID = UUID(uuidString: mapAreaID),
                  let mapArea = await makeOnDemandMapArea(
                    portalItemID: portalItemID,
                    onDemandMapAreaID: onDemandMapAreaID
                  ) else {
                continue
            }
            let model = OnDemandMapModel(
                offlineMapTask: offlineMapTask,
                onDemandMapArea: mapArea,
                portalItemID: portalItemID
            )
            onDemandMapModels.append(model)
        }
        
        self.onDemandMapModels = onDemandMapModels
            .sorted(by: { $0.onDemandMapArea.title < $1.onDemandMapArea.title })
    }
    
    func addOnDemandMapArea(_ onDemandMapArea: OnDemandMapArea) {
        let model = OnDemandMapModel(offlineMapTask: offlineMapTask, onDemandMapArea: onDemandMapArea, portalItemID: portalItemID)
        if onDemandMapModels != nil {
            onDemandMapModels!.append(model)
            onDemandMapModels!.sort(by: { $0.onDemandMapArea.title < $1.onDemandMapArea.title })
        }
        
        Task {
            // Download map area.
            await model.downloadOnDemandMapArea()
        }
    }
}

private struct OfflinePreplannedMapArea: PreplannedMapAreaProtocol {
    var title: String
    var description: String
    var id: Item.ID?
    var packagingStatus: PreplannedMapArea.PackagingStatus?
    var thumbnail: LoadableImage?
    
    func retryLoad() async throws {}
    
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
        fatalError()
    }
}

// This struct represents an on-demand area that is downloaded.
struct OfflineOnDemandMapArea: OnDemandMapAreaProtocol {
    var id: UUID
    var title: String
    var description: String
    var thumbnail: LoadableImage?
}
