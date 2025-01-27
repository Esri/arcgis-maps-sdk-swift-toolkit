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
    let onDemandMapArea: any OnDemandMapAreaProtocol
    
    let mmpkDirectoryURL: URL
    
    private let offlineMapTask: OfflineMapTask
    
    private let portalItemID: PortalItem.ID
    
    private var mobileMapPackage: MobileMapPackage?
    
    private(set) var directorySize = 0
    
    @Published private(set) var job: GenerateOfflineMapJob?
    
    @Published private(set) var status: Status = .initialized
    
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
        onDemandMapArea: OnDemandMapAreaProtocol,
        portalItemID: PortalItem.ID
    ) {
        self.onDemandMapArea = onDemandMapArea
        self.offlineMapTask = offlineMapTask
        self.portalItemID = portalItemID
        mmpkDirectoryURL = .onDemandDirectory(
            forPortalItemID: portalItemID,
            onDemandMapAreaID: onDemandMapArea.id
        )
        
        if let foundJob = lookupDownloadJob() {
            Logger.offlineManager.debug("Found executing job for on-demand area \(onDemandMapArea.id.uuidString, privacy: .public)")
            observeJob(foundJob)
            status = .downloading
        } else if let mmpk = lookupMobileMapPackage() {
            Logger.offlineManager.debug("Found MMPK for area \(onDemandMapArea.id.uuidString, privacy: .public)")
            mobileMapPackage = mmpk
            directorySize = FileManager.default.sizeOfDirectory(at: mmpkDirectoryURL)
            status = .downloaded
        } else {
            status = .initialized
        }
    }
    
    /// Look up the job associated with this map model.
    private func lookupDownloadJob() -> GenerateOfflineMapJob? {
        OfflineManager.shared.jobs
            .lazy
            .compactMap { $0 as? GenerateOfflineMapJob }
            .first {
                $0.downloadDirectoryURL.deletingPathExtension().lastPathComponent == onDemandMapArea.id.uuidString
            }
    }
    
    /// Updates the status based on the download result of the mobile map package.
    func updateDownloadStatus(for downloadResult: Result<GenerateOfflineMapResult, any Error>) {
        switch downloadResult {
        case .success:
            status = .downloaded
        case .failure(let error):
            status = .downloadFailure(error)
            // Remove contents of mmpk directory when download fails.
            try? FileManager.default.removeItem(at: mmpkDirectoryURL)
        }
    }
    
    /// Looks up the mobile map package directory for downloaded package.
    private func lookupMobileMapPackage() -> MobileMapPackage? {
        let fileURL = URL.onDemandDirectory(
            forPortalItemID: portalItemID,
            onDemandMapAreaID: onDemandMapArea.id
        )
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil }
        return MobileMapPackage(fileURL: fileURL)
    }
    
    func downloadOnDemandMapArea() async {
        precondition(status.allowsDownload)
        status = .downloading
        guard let onDemandMapArea = onDemandMapArea as? OnDemandMapArea else { return }
        
        do {
            let parameters = try await offlineMapTask.makeDefaultGenerateOfflineMapParameters(
                areaOfInterest: onDemandMapArea.areaOfInterest,
                minScale: onDemandMapArea.minScale,
                maxScale: onDemandMapArea.maxScale
            )
            // Set the update mode to no updates as the offline map is display-only.
            parameters.updateMode = .noUpdates
            try FileManager.default.createDirectory(at: mmpkDirectoryURL, withIntermediateDirectories: true)
            guard let itemInfo = parameters.itemInfo else { return }
            itemInfo.title = onDemandMapArea.title
            itemInfo.description = ""
            
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
    func removeDownloadedOnDemandMapArea() {
        try? FileManager.default.removeItem(at: mmpkDirectoryURL)
        // Reload the model after local files removal.
        status = .initialized
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
            if status.isDownloaded {
                self.mobileMapPackage = try? result.get().mobileMapPackage
                self.directorySize = FileManager.default.sizeOfDirectory(at: mmpkDirectoryURL)
            }
            self.job = nil
        }
    }
}

extension OnDemandMapModel {
    /// The status of the map area model.
    enum Status {
        case initialized
        /// Map area is being downloaded.
        case downloading
        /// Map area is downloaded.
        case downloaded
        /// Map area failed to download.
        case downloadFailure(Error)
        /// Downloaded mobile map package failed to load.
        case mmpkLoadFailure(Error)
        
        /// A Boolean value indicating whether the model is in a state
        /// where it needs to be loaded or reloaded.
        var needsToBeLoaded: Bool {
            switch self {
            case .downloading, .downloaded, .mmpkLoadFailure:
                false
            default:
                true
            }
        }
        
        /// A Boolean value indicating if download is allowed for this status.
        var allowsDownload: Bool {
            switch self {
            case .downloading, .downloaded, .mmpkLoadFailure:
                false
            case .initialized, .downloadFailure:
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

/// A type that acts as a preplanned map area.
protocol OnDemandMapAreaProtocol: Sendable {
    var id: UUID { get }
    var title: String { get }
}

// This struct represents an on-demand area that hasn't been downloaded to disk.
struct OnDemandMapArea: OnDemandMapAreaProtocol {
    let id: UUID
    let title: String
    let minScale: Double
    let maxScale: Double
    let areaOfInterest: Geometry
}

private extension FileManager {
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
}

