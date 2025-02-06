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
import Combine
import Foundation
import UIKit
internal import os

@MainActor
class OnDemandMapModel: ObservableObject, Identifiable {
    /// The configuration for taking the map area offline.
    let configuration: OnDemandMapAreaConfiguration?
    
    /// The directory URL for this area.
    private let directory: URL
    
    /// The task to use to take the area offline.
    private let offlineMapTask: OfflineMapTask?
    
    /// The ID of the online map.
    private let portalItemID: Item.ID
    
    /// The unique ID of the map area.
    let areaID: OnDemandAreaID
    
    /// The title of the map area.
    let title: String
    
    /// The action to perform when an on demand map area is deleted.
    private let onRemoveDownloadAction: (OnDemandMapModel) -> Void
    
    /// A thumbnail for the map area.
    @Published private(set) var thumbnail: UIImage?
    
    /// The mobile map package for the preplanned map area.
    @Published private(set) var mobileMapPackage: MobileMapPackage?
    
    /// The file size of the on-demand map area.
    @Published private(set) var directorySize = 0
    
    /// The currently running offline map job.
    @Published private(set) var job: GenerateOfflineMapJob?
    
    /// The combined status of the on-demand map area.
    @Published private(set) var status: Status = .initialized
    
    /// The first map from the mobile map package.
    @Published private(set) var map: Map?
    
    /// The URL to the thumbnail for this area.
    private var thumbnailURL: URL {
        directory.appending(component: "thumbnail.png")
    }
    
    /// The URL to the mobile map package for this area.
    private var mmpkDirectoryURL: URL {
        Self.mmpkDirectory(forOnDemandDirectory: directory)
    }
    
    /// Returns a mobile map package directory for an on-demand directory.
    static func mmpkDirectory(forOnDemandDirectory directory: URL) -> URL {
        directory.appending(component: "mmpk")
    }
    
    /// Creates an on-demand map area model with a configuration
    /// for taking the area offline.
    init(
        offlineMapTask: OfflineMapTask,
        configuration: OnDemandMapAreaConfiguration,
        portalItemID: PortalItem.ID,
        onRemoveDownload: @escaping (OnDemandMapModel) -> Void
    ) {
        self.configuration = configuration
        self.offlineMapTask = offlineMapTask
        self.portalItemID = portalItemID
        self.onRemoveDownloadAction = onRemoveDownload
        self.title = configuration.title
        self.areaID = configuration.areaID
        self.thumbnail = configuration.thumbnail
        directory = .onDemandDirectory(
            forPortalItemID: portalItemID,
            onDemandMapAreaID: configuration.areaID
        )
        // Save thumbnail to file.
        if let thumbnail = configuration.thumbnail, let pngData = thumbnail.pngData() {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try? pngData.write(to: thumbnailURL, options: .atomic)
        }
    }
    
    /// Creates an on-demand map area model for a job that
    /// is currently running.
    init(
        job: GenerateOfflineMapJob,
        areaID: OnDemandAreaID,
        portalItemID: PortalItem.ID,
        onRemoveDownload: @escaping (OnDemandMapModel) -> Void
    ) {
        self.configuration = nil
        self.job = job
        self.areaID = areaID
        self.title = job.parameters.itemInfo?.title ?? "Unknown"
        self.portalItemID = portalItemID
        self.onRemoveDownloadAction = onRemoveDownload
        self.offlineMapTask = nil
        directory = .onDemandDirectory(
            forPortalItemID: portalItemID,
            onDemandMapAreaID: areaID
        )
        thumbnail = UIImage(contentsOfFile: thumbnailURL.path())
        
        Logger.offlineManager.debug("Found executing job for on-demand area \(areaID)")
        observeJob(job)
    }
    
    /// Creates an on-demand map area model for a map area that has already been downloaded.
    init?(
        areaID: OnDemandAreaID,
        portalItemID: PortalItem.ID,
        onRemoveDownload: @escaping (OnDemandMapModel) -> Void
    ) async {
        self.areaID = areaID
        self.portalItemID = portalItemID
        self.onRemoveDownloadAction = onRemoveDownload
        directory = URL.onDemandDirectory(forPortalItemID: portalItemID, onDemandMapAreaID: areaID)
        configuration = nil
        offlineMapTask = nil
        let mmpkDirectory = Self.mmpkDirectory(forOnDemandDirectory: directory)
        guard FileManager.default.fileExists(atPath: mmpkDirectory.path()) else { return nil }
        let mmpk = MobileMapPackage(fileURL: mmpkDirectory)
        try? await mmpk.load()
        title = mmpk.item?.title ?? "Unknown"
        thumbnail = UIImage(contentsOfFile: thumbnailURL.path())
        Logger.offlineManager.debug("Found on-demand area at \(self.mmpkDirectoryURL.path(), privacy: .private)")
        await loadAndUpdateMobileMapPackage(mmpk: mmpk)
    }
    
    /// Tries to load a mobile map package and if successful, then updates state
    /// associated with it.
    /// - Parameter mmpk: The mobile map package.
    private func loadAndUpdateMobileMapPackage(mmpk: MobileMapPackage) async {
        do {
            try await mmpk.load()
            // Set status to downloaded if not already set.
            switch status {
            case .downloaded:
                break
            default:
                status = .downloaded
            }
            mobileMapPackage = mmpk
            directorySize = FileManager.default.sizeOfDirectory(at: mmpkDirectoryURL)
            map = mmpk.maps.first
            if thumbnail == nil, let loadable = mmpk.item?.thumbnail {
                try? await loadable.load()
                thumbnail = loadable.image
            }
        } catch {
            status = .mmpkLoadFailure(error)
            mobileMapPackage = nil
            directorySize = 0
            map = nil
        }
    }
    
    /// Downloads the on-demand map area.
    /// - Precondition: `allowsDownload == true`
    /// - Precondition: `configuration != nil`
    /// - Precondition: `configurofflineMapTaskation != nil`
    func downloadOnDemandMapArea() async {
        precondition(status.allowsDownload)
        guard let configuration, let offlineMapTask else { preconditionFailure() }
        
        status = .downloading
        
        do {
            let parameters = try await offlineMapTask.makeDefaultGenerateOfflineMapParameters(
                areaOfInterest: configuration.areaOfInterest,
                minScale: configuration.minScale,
                maxScale: configuration.maxScale
            )
            
            // Set the update mode to no updates as the offline map is display-only.
            parameters.updateMode = .noUpdates
            
            // Update item info on parameters
            if let itemInfo = parameters.itemInfo {
                itemInfo.title = configuration.title
                itemInfo.description = ""
            }
            
            // Don't allow job to continue if errors.
            parameters.continuesOnErrors = false
            
            // Make sure the directory exists.
            try FileManager.default.createDirectory(at: mmpkDirectoryURL, withIntermediateDirectories: true)
            
            let job = offlineMapTask.makeGenerateOfflineMapJob(
                parameters: parameters,
                downloadDirectory: mmpkDirectoryURL
            )
            
            OfflineManager.shared.start(job: job, portalItem: offlineMapTask.portalItem!)
            observeJob(job)
        } catch {
            status = .downloadFailure(error)
        }
    }
    
    /// Removes the downloaded map area from disk and resets the status.
    func removeDownloadedArea() {
        try? FileManager.default.removeItem(at: directory)
        status = .initialized
        
        // Call the closure for the remove download action.
        onRemoveDownloadAction(self)
    }
    
    /// Sets the job property of this instance, starts the job, observes it, and
    /// when it's done, updates the status, removes the job from the job manager,
    /// and fires a user notification.
    private func observeJob(_ job: GenerateOfflineMapJob) {
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
    private func updateDownloadStatus(for downloadResult: Result<GenerateOfflineMapResult, any Error>) {
        switch downloadResult {
        case .success:
            Logger.offlineManager.info("GenerateOfflineMap job succeeded.")
            status = .downloaded
        case .failure(let error):
            if error is CancellationError {
                Logger.offlineManager.info("GenerateOfflineMap job cancelled.")
                status = .downloadCancelled
            } else {
                Logger.offlineManager.error("GenerateOfflineMap job failed with error: \(error).")
                status = .downloadFailure(error)
            }
            // Remove contents of mmpk directory when download fails.
            try? FileManager.default.removeItem(at: mmpkDirectoryURL)
        }
    }
}

extension OnDemandMapModel {
    static func loadOnDemandMapModels(
        portalItemID: Item.ID,
        onRemoveDownload: @escaping (OnDemandMapModel) -> Void
    ) async -> [OnDemandMapModel] {
        var onDemandMapModels: [OnDemandMapModel] = []
        
        // Look up the ongoing jobs for on-demand map models.
        let ongoingJobs = OfflineManager.shared.jobs
            .lazy
            .compactMap { $0 as? GenerateOfflineMapJob }
            .filter { $0.onlineMap?.item?.id == portalItemID }
            .compactMap {
                guard let areaID = OnDemandAreaID(mmpkDirectory: $0.downloadDirectoryURL) else {
                    return Optional<OnDemandMapModel>.none
                }
                return OnDemandMapModel(
                    job: $0,
                    areaID: areaID,
                    portalItemID: portalItemID,
                    onRemoveDownload: onRemoveDownload
                )
            }
        
        onDemandMapModels.append(contentsOf: ongoingJobs)
        
        // Look up the already downloaded on-demand map models.
        let onDemandDirectory = URL.onDemandDirectory(forPortalItemID: portalItemID)
        if let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: onDemandDirectory.path()) {
            for mapAreaID in mapAreaIDs.compactMap(OnDemandAreaID.init(pathComponent:)) {
                // If we already have one (ie. a job is already be running and the
                // directory is exists so we found it here), then we continue.
                guard !onDemandMapModels.contains(where: { $0.areaID == mapAreaID }) else { continue }
                if let mapArea = await OnDemandMapModel.init(
                    areaID: mapAreaID,
                    portalItemID: portalItemID,
                    onRemoveDownload: onRemoveDownload
                ) {
                    // If we could create the model, then add it.
                    onDemandMapModels.append(mapArea)
                } else {
                    // If we couldn't create the model, it was a case where the job was
                    // cancelled and the user didn't remove the job from the list, in
                    // that case we cleanup the directory.
                    try? FileManager.default.removeItem(
                        at: URL.onDemandDirectory(forPortalItemID: portalItemID, onDemandMapAreaID: mapAreaID)
                    )
                }
            }
        }
        
        return onDemandMapModels
            .sorted(by: { $0.title < $1.title })
    }
}

extension OnDemandMapModel {
    /// The status of the map area model.
    enum Status {
        /// The model is initialized but a job hasn't been started and the area has not been downloaded.
        case initialized
        /// Map area is being downloaded.
        case downloading
        /// Map area is downloaded.
        case downloaded
        /// Map area failed to download.
        case downloadFailure(Error)
        /// The job was cancelled.
        case downloadCancelled
        /// Downloaded mobile map package failed to load.
        case mmpkLoadFailure(Error)
        
        /// A Boolean value indicating if download is allowed for this status.
        var allowsDownload: Bool {
            switch self {
            case .downloading, .downloaded, .mmpkLoadFailure, .downloadCancelled,
                    .downloadFailure:
                false
            case .initialized:
                true
            }
        }
        
        /// A Boolean value indicating whether the map area is downloaded.
        var isDownloaded: Bool {
            if case .downloaded = self { true } else { false }
        }
    }
}

extension OnDemandMapModel: Equatable {
    nonisolated static func == (lhs: OnDemandMapModel, rhs: OnDemandMapModel) -> Bool {
        return lhs === rhs
    }
}

extension OnDemandMapModel: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

/// Represents the unique ID of an on-demand map area.
struct OnDemandAreaID: CustomStringConvertible, Equatable {
    let uuid: UUID
    var description: String { uuid.uuidString }
    
    /// Creates an new on-demand area ID from a `UUID`.
    private init(uuid: UUID) {
        self.uuid = uuid
    }
    
    /// Creates a new unique on-demand area ID.
    init() { uuid = UUID() }
    
    /// Creates an on-demand area ID from a path component string.
    /// Returns `nil` if an invalid string is passed in.
    /// - Parameter pathComponent: The path component.
    init?(pathComponent: String) {
        guard let uuid = UUID(uuidString: pathComponent) else { return nil }
        self.init(uuid: uuid)
    }
    
    /// Creates an on-demand area from the directory of the mmpk for the on-demand area.
    /// - Parameter directory: The directory where the mmpk is.
    init?(mmpkDirectory: URL) {
        // Typically the directory will look something like this:
        // OnDemand/<UUID>/mmpk
        // We need to remove the mmpk component, and grab the UUID.
        let pathComponent = mmpkDirectory.deletingPathExtension().deletingLastPathComponent().lastPathComponent
        self.init(pathComponent: pathComponent)
    }
}

// A value that carries configuration for an on-demand map area.
struct OnDemandMapAreaConfiguration {
    /// A unique ID for the on-demand map area.
    let areaID = OnDemandAreaID()
    /// A title for the offline area.
    let title: String
    /// The min-scale to take offline.
    let minScale: Double
    /// The max-scale to take offline.
    let maxScale: Double
    /// The area of interest to take offline.
    let areaOfInterest: Geometry
    /// The thumbnail of the area.
    let thumbnail: UIImage?
}
