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
        /// The mode has not been determined yet.
        case notLoaded
        /// Offline is disabled for the web map.
        case offlineDisabled
        /// No preplanned areas defined, no on-demand areas downloaded yet.
        /// In this case we will default to show on-demand mode, unless
        /// preplanned areas are later defined on the web map.
        case ambiguous
        /// Preplanned map areas are defined, or have been downloaded.
        case preplanned
        /// On-demand map areas have been downloaded.
        case onDemand
        /// Cannot determine if there are preplanned areas because there is
        /// no internet and no map area downloaded.
        case noInternetAvailable
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
    @Published private(set) var mode: Mode = .notLoaded
    
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
    /// - Parameter model: The preplanned map model.
    func onRemoveDownloadOfPreplannedArea(_ model: PreplannedMapModel) {
        // Delete the saved map info if there are no more downloads for the
        // represented online map.
        if !hasDownloadedMapAreas {
            OfflineManager.shared.removeMapInfo(for: portalItemID)
        }
        
        // If we are only showing offline models,
        // and the model that had it's area deleted cannot be re-downloaded,
        // then remove it from the list so it's not longer shown.
        if case .success(var preplannedModels) = preplannedMapModels,
           isShowingOnlyOfflineModels,
           !model.preplannedMapArea.supportsRedownloading
        {
            preplannedModels.removeAll { $0 === model }
            self.preplannedMapModels = .success(preplannedModels)
        }
    }
    
    /// Loads the preplanned and on-demand models.
    func loadModels() async {
        // Determine if offline is disabled for the map.
        guard mode != .offlineDisabled else { return }
        try? await onlineMap.retryLoad()
        if onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil {
            // The web map is offline disabled.
            mode = .offlineDisabled
            return
        }
        // Note: We don't reset the mode once it is determined.
        
        switch mode {
        case .preplanned:
            await loadPreplannedMapModels()
        case .onDemand:
            await loadOnDemandMapModels()
        case .noInternetAvailable, .ambiguous, .notLoaded:
            await determineMode()
        case .offlineDisabled:
            fatalError("Offline disabled mode should have been handled earlier.")
        }
        
        /// Attempts to determine the mode.
        /// - Precondition: `mode == .ambiguous || mode == .noInternetAvailable || mode == .notLoaded`
        func determineMode() async {
            precondition(mode == .ambiguous || mode == .noInternetAvailable || mode == .notLoaded)
            
            // Start by trying to load preplanned map models.
            await loadPreplannedMapModels()
            
            if hasAnyPreplannedMapAreas {
                // If there are any preplanned map areas, set mode to preplanned.
                mode = .preplanned
                return
            }
            
            // Try to load on-demand map models.
            await loadOnDemandMapModels()
            
            // If there are on-demand areas on device, set mode to on-demand.
            if !onDemandMapModels.isEmpty {
                mode = .onDemand
                return
            }
            
            if isShowingOnlyOfflineModels {
                // In this case there are no preplanned or on-demand map areas and we can
                // only show offline models (which there are none) because
                // there is no internet. In that case we set the mode to
                // `noInternetAvailable`.
                mode = .noInternetAvailable
                return
            }
            
            // Connected to the Internet, no preplanned map area,
            // no on-demand map area on device, the mode is ambiguous.
            mode = .ambiguous
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
        guard mode == .onDemand || mode == .ambiguous else { return }
        
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
