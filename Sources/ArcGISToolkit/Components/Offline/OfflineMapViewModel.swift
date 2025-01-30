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
    
    /// The function called when a downloaded preplanned map area is removed.
    func onRemoveDownloadOfPreplannedArea() {
        // Delete the saved map info if there are no more downloads for the
        // represented online map.
        guard case.success(let models) = preplannedMapModels,
              models.filter(\.status.isDownloaded).isEmpty
        else { return }
        OfflineManager.shared.removeMapInfo(for: portalItemID)
    }
    
    func loadPreplannedMapModels() async {
        let models = await PreplannedMapModel.loadPreplannedMapModels(
            offlineMapTask: offlineMapTask,
            portalItemID: portalItemID,
            onRemoveDownload: onRemoveDownloadOfPreplannedArea
        )
        preplannedMapModels = models.result
        isShowingOnlyOfflineModels = models.onlyOfflineModelsAreAvailable
    }
    
    /// The function called when a downloaded on demand map area is removed.
    /// - Parameter model: The on demand map model.
    func onRemoveDownloadOfOnDemandArea(for model: OnDemandMapModel) {
        guard let models = onDemandMapModels else { return }
        onDemandMapModels?.removeAll(where: { $0.areaID == model.areaID })
        // Delete the saved map info if there are no more downloads for the
        // represented online map.
        guard models.filter(\.status.isDownloaded).isEmpty else { return }
        OfflineManager.shared.removeMapInfo(for: portalItemID)
    }
    
    func loadOnDemandMapModels() async {
        onDemandMapModels = await OnDemandMapModel.loadOnDemandMapModels(portalItemID: portalItemID, onRemoveDownload: onRemoveDownloadOfOnDemandArea(for:))
    }
    
    func addOnDemandMapArea(with configuration: OnDemandMapAreaConfiguration) {
        guard onDemandMapModels != nil else { return }
        
        let model = OnDemandMapModel(
            offlineMapTask: offlineMapTask,
            configuration: configuration,
            portalItemID: portalItemID,
            onRemoveDownload: onRemoveDownloadOfOnDemandArea(for:)
        )
        onDemandMapModels?.append(model)
        onDemandMapModels?.sort(by: { $0.title < $1.title })
        
        Task {
            // Download map area.
            await model.downloadOnDemandMapArea()
        }
    }
    
    /// Returns the next title for the on-demand map area.
    func nextOnDemandAreaTitle() -> String {
        func title(forIndex index: Int) -> String {
            "Area \(index)"
        }
        
        guard let onDemandMapModels else { return title(forIndex: 1) }
        var index = onDemandMapModels.count + 1
        while onDemandMapModels.contains(where: { $0.title == title(forIndex: index) }) {
            index += 1
        }
        return title(forIndex: index)
    }
}
