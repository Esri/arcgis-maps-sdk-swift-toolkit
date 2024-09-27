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
import OSLog
import SwiftUI

/// An object that encapsulates state about a preplanned map.
@MainActor
class PreplannedMapModel: ObservableObject, Identifiable {
    /// The preplanned map area.
    let preplannedMapArea: any PreplannedMapAreaProtocol
    
    /// The ID of the preplanned map area.
    let preplannedMapAreaID: PortalItem.ID
    
    /// The mobile map package directory URL.
    private let mmpkDirectoryURL: URL
    
    /// The task to use to take the area offline.
    private let offlineMapTask: OfflineMapTask
    
    /// The ID of the web map.
    private let portalItemID: PortalItem.ID
    
    /// The mobile map package for the preplanned map area.
    private var mobileMapPackage: MobileMapPackage?
    
    /// The file size of the preplanned map area.
    private(set) var directorySize = 0
    
    /// The currently running download job.
    @Published private(set) var job: DownloadPreplannedOfflineMapJob?
    
    /// The combined status of the preplanned map area.
    @Published private(set) var status: Status = .notLoaded
    
    /// A Boolean value indicating if a user notification should be shown when a job completes.
    let showsUserNotificationOnCompletion: Bool
    
    /// The first map from the mobile map package.
    var map: Map? { 
        get async {
            if let mobileMapPackage {
                if mobileMapPackage.loadStatus != .loaded {
                    do {
                        try await mobileMapPackage.load()
                    } catch {
                        status = .mmpkLoadFailure(error)
                    }
                }
                return mobileMapPackage.maps.first
            } else {
                return nil
            }
        }
    }
    
    init(
        offlineMapTask: OfflineMapTask,
        mapArea: PreplannedMapAreaProtocol,
        portalItemID: PortalItem.ID,
        preplannedMapAreaID: PortalItem.ID,
        showsUserNotificationOnCompletion: Bool = true
    ) {
        self.offlineMapTask = offlineMapTask
        preplannedMapArea = mapArea
        self.portalItemID = portalItemID
        self.preplannedMapAreaID = preplannedMapAreaID
        mmpkDirectoryURL = FileManager.default.preplannedDirectory(
            forPortalItemID: portalItemID,
            preplannedMapAreaID: preplannedMapAreaID
        )
        self.showsUserNotificationOnCompletion = showsUserNotificationOnCompletion
        
        if let foundJob = lookupDownloadJob() {
            Logger.offlineManager.debug("Found executing job for area \(preplannedMapAreaID.rawValue, privacy: .public)")
            observeJob(foundJob)
        } else if let mmpk = lookupMobileMapPackage() {
            Logger.offlineManager.debug("Found MMPK for area \(preplannedMapAreaID.rawValue, privacy: .public)")
            mobileMapPackage = mmpk
            directorySize = FileManager.default.sizeOfDirectory(at: mmpkDirectoryURL)
            status = .downloaded
        }
    }
    
    /// Loads the preplanned map area and updates the status.
    func load() async {
        guard status.needsToBeLoaded else { return }
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
    
    /// Look up the job associated with this preplanned map model.
    private func lookupDownloadJob() -> DownloadPreplannedOfflineMapJob? {
        OfflineManager.shared.jobs
            .lazy
            .compactMap { $0 as? DownloadPreplannedOfflineMapJob }
            .first {
                $0.downloadDirectoryURL.deletingPathExtension().lastPathComponent == preplannedMapAreaID.rawValue
            }
    }
    
    /// Updates the status based on the download result of the mobile map package.
    func updateDownloadStatus(for downloadResult: Result<DownloadPreplannedOfflineMapResult, any Error>) {
        switch downloadResult {
        case .success:
            withAnimation(.easeInOut) {
                status = .downloaded
            }
        case .failure(let error):
            status = .downloadFailure(error)
        }
    }
    
    /// Looks up the mobile map package directory for locally downloaded package.
    private func lookupMobileMapPackage() -> MobileMapPackage? {
        let fileURL = FileManager.default.preplannedDirectory(
            forPortalItemID: portalItemID,
            preplannedMapAreaID: preplannedMapAreaID
        )
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil }
        // Make sure the directory is not empty because the directory will exist as soon as the
        // job starts, so if the job fails, it will look like the mmpk was downloaded.
        guard !FileManager.default.isDirectoryEmpty(atPath: fileURL) else { return nil }
        return MobileMapPackage.init(fileURL: fileURL)
    }
    
    /// Downloads the preplanned map area.
    /// - Precondition: `canDownload`
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
            
            OfflineManager.shared.start(job: job)
            observeJob(job)
        } catch {
            status = .downloadFailure(error)
        }
    }
    
    /// Removes the downloaded preplanned map area from disk and resets the status.
    func removeDownloadedPreplannedMapArea() {
        try? FileManager.default.removeItem(at: mmpkDirectoryURL)
        // Reload the model after local files removal.
        status = .notLoaded
        Task { await load() }
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
            if status.isDownloaded {
                self.mobileMapPackage = try? result.get().mobileMapPackage
                self.directorySize = FileManager.default.sizeOfDirectory(at: mmpkDirectoryURL)
            }
            self.job = nil
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
        /// where it needs to be loaded or reloaded.
        var needsToBeLoaded: Bool {
            switch self {
            case .loading, .packaging, .packaged, .downloading, .downloaded, .mmpkLoadFailure:
                false
            default:
                true
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
        
        /// A Boolean value indicating whether the local files can be removed.
        var allowsRemoval: Bool {
            switch self {
            case .downloaded, .mmpkLoadFailure, .downloadFailure, .loadFailure, .packageFailure:
                true
            default:
                false
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

private extension FileManager {
    /// The path to the documents folder.
    private var documentsDirectory: URL {
        URL.documentsDirectory
    }
    
    /// The path to the offline map areas directory within the documents directory.
    /// `Documents/OfflineMapAreas/`
    private var offlineMapAreasDirectory: URL {
        documentsDirectory.appending(component: "OfflineMapAreas/")
    }
    
    /// The path to the web map directory for a specific portal item.
    /// `Documents/OfflineMapAreas/<Portal Item ID>`
    /// - Parameter portalItemID: The ID of the web map portal item.
    private func portalItemDirectory(forPortalItemID portalItemID: PortalItem.ID) -> URL {
        offlineMapAreasDirectory.appending(path: portalItemID.rawValue, directoryHint: .isDirectory)
    }
    
    /// Calculates the size of a directory and all its contents.
    /// - Parameter url: The directory's URL.
    /// - Returns: The total size in bytes.
    func sizeOfDirectory(at url: URL) -> Int {
        guard let enumerator = enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }
        var accumulatedSize = 0
        for case let fileURL as URL in enumerator {
            guard let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
                continue
            }
            accumulatedSize += size
        }
        return accumulatedSize
    }
    
    /// The path to the preplanned map areas directory for a specific portal item.
    /// `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/<Preplanned Area ID>/`
    /// - Parameters:
    ///   - portalItemID: The ID of the web map portal item.
    ///   - preplannedMapAreaID: The ID of the preplanned map area portal item.
    /// - Returns: A URL to the preplanned map area directory.
    func preplannedDirectory(
        forPortalItemID portalItemID: PortalItem.ID,
        preplannedMapAreaID: PortalItem.ID
    ) -> URL {
        portalItemDirectory(forPortalItemID: portalItemID)
            .appending(components: "Preplanned", "\(preplannedMapAreaID)/")
    }
    
    /// Returns a Boolean value indicating if the specified directory is empty.
    /// - Parameter path: The path to check.
    func isDirectoryEmpty(atPath path: URL) -> Bool {
        (try? FileManager.default.contentsOfDirectory(atPath: path.path()).isEmpty) ?? true
    }
}
