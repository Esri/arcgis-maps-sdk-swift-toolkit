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
    /// The mode that we are displaying models in.
    enum Mode {
        case undetermined
        case preplanned
        case onDemand
    }
    
    /// The portal item ID of the web map.
    private let portalItemID: Item.ID
    
    /// The offline map task.
    private let offlineMapTask: OfflineMapTask
    
    /// The preplanned map information.
    @Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error> = .success([])
    
    /// A Boolean value indicating if only offline models are being shown.
    @Published private(set) var isShowingOnlyOfflineModels = false
    
    /// The on-demand map information.
    @Published private(set) var onDemandMapModels: [OnDemandMapModel] = []
    
    /// The mode that we are displaying models in.
    @Published private(set) var mode: Mode = .undetermined
    
    /// A Boolean value indicating whether the models are loading.
    @Published private(set) var isLoadingModels = false

    /// A Boolean value indicating whether the web map is offline disabled.
    @Published private(set) var mapIsOfflineDisabled = false
    
    /// The online map.
    private let onlineMap: Map
    
    /// A Boolean value indicating whether there are downloaded preplanned map areas for the web map.
    private var hasDownloadedPreplannedMapAreas: Bool {
        if case.success(let preplannedModels) = preplannedMapModels {
            !preplannedModels.filter(\.status.isDownloaded).isEmpty
        } else {
            false
        }
    }
    
    /// A Boolean value indicating whether there are downloaded on-demand map areas for the web map.
    private var hasDownloadedOnDemandMapAreas: Bool {
        !onDemandMapModels.filter(\.status.isDownloaded).isEmpty
    }
    
    /// A Boolean value indicating whether there are downloaded map areas for the web map.
    private var hasDownloadedMapAreas: Bool {
        hasDownloadedPreplannedMapAreas || hasDownloadedOnDemandMapAreas
    }
    
    /// A Boolean value indicating if there are any preplanned map areas.
    private var hasAnyPreplannedMapAreas: Bool {
        switch preplannedMapModels {
        case .success(let success):
            !success.isEmpty
        case .failure:
            false
        }
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
        guard !hasDownloadedMapAreas else { return }
        
        OfflineManager.shared.removeMapInfo(for: portalItemID)
    }
    
    /// Loads the preplanned and on-demand models.
    func loadModels() async {
        isLoadingModels = true
        defer { isLoadingModels = false }
        
        // Determine if offline is disabled for the map.
        try? await onlineMap.retryLoad()
        mapIsOfflineDisabled = onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil
        guard !mapIsOfflineDisabled else { return }
        
        // Note: We don't reset the mode once it is determined.
        
        // First load preplanned map models.
        if mode == .undetermined || mode == .preplanned {
            await loadPreplannedMapModels()
            if mode == .undetermined, hasAnyPreplannedMapAreas {
                // If there are any preplanned map areas at all
                // and the mode is undetermined, then set mode to preplanned.
                mode = .preplanned
            }
        }
                
        // Load on-demand map models if mode is on-demand or still
        // undetermined.
        if mode == .undetermined || mode == .onDemand {
            await loadOnDemandMapModels()
            // If there are any on-demand areas at all, and the mode is
            // undetermined, then set mode to on-demand.
            if mode == .undetermined, !onDemandMapModels.isEmpty {
                mode = .onDemand
            }
        }
    }
    
    /// Loads the preplanned map models.
    private func loadPreplannedMapModels() async {
        let models = await PreplannedMapModel.loadPreplannedMapModels(
            offlineMapTask: offlineMapTask,
            portalItemID: portalItemID,
            onRemoveDownload: onRemoveDownloadOfPreplannedArea
        )
        preplannedMapModels = models.result
        isShowingOnlyOfflineModels = models.onlyOfflineModelsAreAvailable
    }
    
    /// The function called when a downloaded on-demand map area is removed.
    /// - Parameter model: The on-demand map model.
    func onRemoveDownloadOfOnDemandArea(for model: OnDemandMapModel) {
        onDemandMapModels.removeAll(where: { $0 === model })
        // Delete the saved map info if there are no more downloads for the
        // represented online map.
        guard !hasDownloadedMapAreas else { return }
        
        OfflineManager.shared.removeMapInfo(for: portalItemID)
    }
    
    /// Loads the on-demand map models.
    private func loadOnDemandMapModels() async {
        onDemandMapModels = await OnDemandMapModel.loadOnDemandMapModels(
            portalItemID: portalItemID,
            onRemoveDownload: onRemoveDownloadOfOnDemandArea(for:)
        )
    }
    
    /// Adds an on-demand map area, specifying the configuration for the area to take offline.
    /// - Parameter configuration: The configuration for the area to take offline.
    func addOnDemandMapArea(with configuration: OnDemandMapAreaConfiguration) {
        guard mode == .onDemand || mode == .undetermined else { return }
        
        let model = OnDemandMapModel(
            offlineMapTask: offlineMapTask,
            configuration: configuration,
            portalItemID: portalItemID,
            onRemoveDownload: onRemoveDownloadOfOnDemandArea(for:)
        )
        onDemandMapModels.append(model)
        onDemandMapModels.sort(by: { $0.title < $1.title })
        
        Task {
            // Download map area.
            await model.downloadOnDemandMapArea()
        }
    }
    
    /// Returns the next title for the on-demand map area.
    func nextOnDemandAreaTitle() -> String {
        func title(forIndex index: Int) -> String {
            .init(
                localized: "Area \(index)",
                bundle: .toolkitModule,
                comment: "The title for a map area."
            )
        }
        
        var index = onDemandMapModels.count + 1
        while onDemandMapModels.contains(where: { $0.title == title(forIndex: index) }) {
            index += 1
        }
        return title(forIndex: index)
    }
    
    /// Returns a Boolean value indicating if a proposed on-demand map area title
    /// is unique.
    func isProposeOnDemandAreaTitleUnique(_ proposedTitle: String) -> Bool {
        !onDemandMapModels.contains { $0.title == proposedTitle }
    }
}
