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

internal import os

/// An object that encapsulates state about a preplanned map.
@MainActor
class PreplannedMapModel: ObservableObject, Identifiable {
    /// The preplanned map area.
    let preplannedMapArea: any PreplannedMapAreaProtocol
    
    /// The ID of the preplanned map area.
    let preplannedMapAreaID: Item.ID
    
    /// The mobile map package directory URL.
    private let mmpkDirectoryURL: URL
    
    /// The task to use to take the area offline.
    private let offlineMapTask: OfflineMapTask
    
    /// The ID of the online map.
    private let portalItemID: Item.ID
    
    /// The action to perform when a preplanned map area is deleted.
    private let onRemoveDownloadAction: () -> Void
    
    /// The mobile map package for the preplanned map area.
    @Published private(set) var mobileMapPackage: MobileMapPackage?
    
    /// The file size of the preplanned map area.
    @Published private(set) var directorySize = 0
    
    /// The currently running download job.
    @Published private(set) var job: DownloadPreplannedOfflineMapJob?
    
    /// The combined status of the preplanned map area.
    @Published private(set) var status: Status = .notLoaded {
        willSet {
            let statusString = "\(newValue)"
            Logger.offlineManager.debug("Setting status to \(statusString) for area \(self.preplannedMapAreaID.rawValue)")
        }
    }
    
    /// The first map from the mobile map package.
    @Published private(set) var map: Map?
    
    init(
        offlineMapTask: OfflineMapTask,
        mapArea: PreplannedMapAreaProtocol,
        portalItemID: Item.ID,
        preplannedMapAreaID: Item.ID,
        onRemoveDownload: @escaping () -> Void
    ) {
        self.offlineMapTask = offlineMapTask
        preplannedMapArea = mapArea
        self.portalItemID = portalItemID
        self.preplannedMapAreaID = preplannedMapAreaID
        self.onRemoveDownloadAction = onRemoveDownload
        
        mmpkDirectoryURL = .preplannedDirectory(
            forPortalItemID: portalItemID,
            preplannedMapAreaID: preplannedMapAreaID
        )
    }
    
    /// Depending on the state, this either:
    /// - observes an in-flight job
    /// - looks up the mobile map package if it exists on disk
    /// - loads the pre-planned map area
    func load() async {
        if job == nil, let foundJob = lookupDownloadJob() {
            Logger.offlineManager.debug("Found executing job for preplanned area \(self.preplannedMapAreaID.rawValue)")
            observeJob(foundJob)
        } else if mobileMapPackage == nil, let mmpk = lookupMobileMapPackage() {
            Logger.offlineManager.debug("Found MMPK for area \(self.preplannedMapAreaID.rawValue)")
            await self.loadAndUpdateMobileMapPackage(mmpk: mmpk)
        } else if status.canLoadPreplannedMapArea {
            Logger.offlineManager.debug("Loading preplanned map area for \(self.preplannedMapAreaID.rawValue)")
            await loadPreplannedMapArea()
        } else {
            Logger.offlineManager.debug("Already loaded for preplanned map area \(self.preplannedMapAreaID.rawValue)")
        }
    }
    
    /// Loads the preplanned map area.
    private func loadPreplannedMapArea() async {
        do {
            // Load preplanned map area to obtain packaging status.
            status = .loading
            try await preplannedMapArea.retryLoad()
            // Note: Packaging status is `nil` for compatibility with
            // legacy webmaps that have incomplete metadata.
            // If the area loads, then you know for certain the status is complete.
            status = preplannedMapArea.packagingStatus.map(Status.init) ?? .packaged
        } catch MappingError.packagingNotComplete {
            // Load will throw an `MappingError.packagingNotComplete` error if not complete,
            // this case is not a normal load failure.
            status = preplannedMapArea.packagingStatus.map(Status.init) ?? .packageFailure
        } catch {
            // Normal load failure.
            status = .loadFailure(error)
        }
    }
    
    /// Tries to load a mobile map package and if successful, then updates state
    /// associated with it.
    private func loadAndUpdateMobileMapPackage(mmpk: MobileMapPackage) async {
        do {
            try await mmpk.load()
            status = .downloaded
            mobileMapPackage = mmpk
            directorySize = FileManager.default.sizeOfDirectory(at: mmpkDirectoryURL)
            map = mmpk.maps.first
        } catch {
            status = .mmpkLoadFailure(error)
            mobileMapPackage = nil
            directorySize = 0
            map = nil
        }
    }
    
    /// Look up the job associated with this preplanned map model.
    private func lookupDownloadJob() -> DownloadPreplannedOfflineMapJob? {
        OfflineManager.shared.jobs
            .lazy
            .compactMap { $0 as? DownloadPreplannedOfflineMapJob }
            .first {
                $0.downloadDirectoryURL.deletingPathExtension().lastPathComponent == preplannedMapAreaID.rawValue
            }
    }
    
    /// Looks up the mobile map package directory for locally downloaded package.
    private func lookupMobileMapPackage() -> MobileMapPackage? {
        let fileURL = URL.preplannedDirectory(
            forPortalItemID: portalItemID,
            preplannedMapAreaID: preplannedMapAreaID
        )
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil }
        return MobileMapPackage(fileURL: fileURL)
    }
    
    /// Downloads the preplanned map area.
    /// - Precondition: `allowsDownload == true`
    func downloadPreplannedMapArea() async {
        precondition(status.allowsDownload)
        
        status = .downloading
        do {
            let parameters = try await preplannedMapArea.makeParameters(using: offlineMapTask)
            try FileManager.default.createDirectory(at: mmpkDirectoryURL, withIntermediateDirectories: true)
            
            // Create the download preplanned offline map job.
            let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
                parameters: parameters,
                downloadDirectory: mmpkDirectoryURL
            )
            
            OfflineManager.shared.start(job: job, portalItem: offlineMapTask.portalItem!)
            observeJob(job)
        } catch {
            status = .downloadFailure(error)
        }
    }
    
    /// Removes the downloaded preplanned map area from disk and resets the status.
    func removeDownloadedArea() {
        try? FileManager.default.removeItem(at: mmpkDirectoryURL)
        
        // Reload the model after local files removal.
        status = .notLoaded
        Task { await load() }
        
        // Call the closure for the remove download action.
        onRemoveDownloadAction()
    }
    
    /// Sets the job property of this instance, starts the job, observes it, and
    /// when it's done, updates the status, removes the job from the job manager,
    /// and fires a user notification.
    private func observeJob(_ job: DownloadPreplannedOfflineMapJob) {
        self.job = job
        status = .downloading
        Task { [weak self, job] in
            let result = await job.result
            guard let self else { return }
            self.updateDownloadStatus(for: result)
            if let mmpk = try? result.get().mobileMapPackage {
                await loadAndUpdateMobileMapPackage(mmpk: mmpk)
            }
            self.job = nil
        }
    }
    
    /// Updates the status based on the download result of the mobile map package.
    private func updateDownloadStatus(for downloadResult: Result<DownloadPreplannedOfflineMapResult, any Error>) {
        switch downloadResult {
        case .success:
            status = .downloaded
        case .failure(let error):
            status = .downloadFailure(error)
            // Remove contents of mmpk directory when download fails.
            try? FileManager.default.removeItem(at: mmpkDirectoryURL)
        }
    }
    
}

extension PreplannedMapModel {
    /// The status of the preplanned map area model.
    enum Status {
        /// Preplanned map area not loaded.
        case notLoaded
        /// Preplanned map area is loading.
        case loading
        /// Preplanned map area failed to load.
        case loadFailure(Error)
        /// Preplanned map area is packaging.
        case packaging
        /// Preplanned map area is packaged and ready for download.
        case packaged
        /// Preplanned map area packaging failed.
        case packageFailure
        /// Preplanned map area is being downloaded.
        case downloading
        /// Preplanned map area is downloaded.
        case downloaded
        /// Preplanned map area failed to download.
        case downloadFailure(Error)
        /// Downloaded mobile map package failed to load.
        case mmpkLoadFailure(Error)
        
        /// A Boolean value indicating whether the model is in a state
        /// where it can load the preplanned map area.
        var canLoadPreplannedMapArea: Bool {
            switch self {
            case .notLoaded, .loadFailure, .packageFailure:
                true
            case .loading, .packaging, .packaged, .downloading, .downloaded, .mmpkLoadFailure, .downloadFailure:
                false
            }
        }
        
        /// A Boolean value indicating if download is allowed for this status.
        var allowsDownload: Bool {
            switch self {
            case .notLoaded, .loading, .loadFailure, .packaging, .packageFailure,
                    .downloading, .downloaded, .mmpkLoadFailure:
                false
            case .packaged, .downloadFailure:
                true
            }
        }
        
        /// A Boolean value indicating whether the preplanned map area is downloaded.
        var isDownloaded: Bool {
            if case .downloaded = self { true } else { false }
        }
    }
}

private extension PreplannedMapModel.Status {
    init(packagingStatus: PreplannedMapArea.PackagingStatus) {
        self = switch packagingStatus {
        case .processing: .packaging
        case .failed: .packageFailure
        case .complete: .packaged
        @unknown default: fatalError("Unknown case")
        }
    }
}

extension PreplannedMapModel: Equatable {
    nonisolated static func == (lhs: PreplannedMapModel, rhs: PreplannedMapModel) -> Bool {
        return lhs === rhs
    }
}

extension PreplannedMapModel: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

/// A type that acts as a preplanned map area.
protocol PreplannedMapAreaProtocol: Sendable {
    func retryLoad() async throws
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters
    
    var packagingStatus: PreplannedMapArea.PackagingStatus? { get }
    var title: String { get }
    var description: String { get }
    var thumbnail: LoadableImage? { get }
}

/// Extend `PreplannedMapArea` to conform to `PreplannedMapAreaProtocol`.
extension PreplannedMapArea: PreplannedMapAreaProtocol {
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
        // Create the parameters for the download preplanned offline map job.
        let parameters = try await offlineMapTask.makeDefaultDownloadPreplannedOfflineMapParameters(
            preplannedMapArea: self
        )
        // Set the update mode to no updates as the offline map is display-only.
        parameters.updateMode = .noUpdates
        
        return parameters
    }
    
    var title: String {
        portalItem.title
    }
    
    var thumbnail: LoadableImage? {
        portalItem.thumbnail
    }
    
    var description: String {
        // Remove HTML tags from description.
        portalItem.description.replacing(/<[^>]+>/, with: "")
    }
}

/// A value that contains the result of loading the preplanned map models for
/// a given online map.
struct PreplannedModels {
    /// The result of loading the preplanned models.
    let result: Result<[PreplannedMapModel], Error>
    /// A Boolean value indicating if only offline models are available.
    let onlyOfflineModelsAreAvailable: Bool
}

extension PreplannedMapModel {
    /// Gets the preplanned map areas from the offline map task and loads the map models.
    static func loadPreplannedMapModels(
        offlineMapTask: OfflineMapTask,
        portalItemID: Item.ID,
        onRemoveDownload: @escaping () -> Void
    ) async -> PreplannedModels {
        if offlineMapTask.loadStatus != .loaded {
            try? await offlineMapTask.retryLoad()
        }
        
        var onlyOfflineModelsAreAvailable = false
        
        let result = await Result { @MainActor in
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
                            onRemoveDownload: onRemoveDownload
                        )
                    }
            } catch {
                // If not connected to the internet, then return only the offline models.
                if error.isNoInternetConnectionError {
                    onlyOfflineModelsAreAvailable = true
                    return await loadOfflinePreplannedMapModels(
                        offlineMapTask: offlineMapTask,
                        portalItemID: portalItemID,
                        onRemoveDownload: onRemoveDownload
                    )
                } else {
                    throw error
                }
            }
        }
        
        return .init(result: result, onlyOfflineModelsAreAvailable: onlyOfflineModelsAreAvailable)
    }
    
    /// Loads the offline preplanned map models with information from the downloaded mobile map
    /// packages for the online map.
    private static func loadOfflinePreplannedMapModels(
        offlineMapTask: OfflineMapTask,
        portalItemID: Item.ID,
        onRemoveDownload: @escaping () -> Void
    ) async -> [PreplannedMapModel] {
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
                onRemoveDownload: onRemoveDownload
            )
            preplannedMapModels.append(model)
        }
        
        return preplannedMapModels
            .sorted(by: { $0.preplannedMapArea.title < $1.preplannedMapArea.title })
    }
    
    /// Creates a preplanned map area using a given portal item and map area ID to search for a corresponding
    /// downloaded mobile map package. If the mobile map package is not found then `nil` is returned.
    /// - Parameters:
    ///   - portalItemID: The portal item ID.
    ///   - preplannedMapAreaID: The preplanned map area ID.
    /// - Returns: The preplanned map area.
    private static func makeMapArea(
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
