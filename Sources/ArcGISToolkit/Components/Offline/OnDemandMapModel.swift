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
    /// The on-demand map area.
    let onDemandMapArea: any OnDemandMapAreaProtocol
    
    /// The mobile map package directory URL.
    let mmpkDirectoryURL: URL
    
    /// The task to use to take the area offline.
    private let offlineMapTask: OfflineMapTask
    
    /// The ID of the online map.
    private let portalItemID: Item.ID
    
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
    
    init(
        offlineMapTask: OfflineMapTask,
        mapArea: OnDemandMapAreaProtocol,
        portalItemID: PortalItem.ID
    ) {
        self.onDemandMapArea = mapArea
        self.offlineMapTask = offlineMapTask
        self.portalItemID = portalItemID
        mmpkDirectoryURL = .onDemandDirectory(
            forPortalItemID: portalItemID,
            onDemandMapAreaID: onDemandMapArea.id
        )
        
        if let foundJob = lookupDownloadJob() {
            Logger.offlineManager.debug("Found executing job for on-demand area \(mapArea.id.uuidString, privacy: .public)")
            observeJob(foundJob)
        } else if let mmpk = lookupMobileMapPackage() {
            Logger.offlineManager.debug("Found MMPK for area \(mapArea.id.uuidString, privacy: .public)")
            // TODO: ?
            status = .downloaded
            Task.detached { await self.loadAndUpdateMobileMapPackage(mmpk: mmpk) }
        } else {
            status = .initialized
        }
    }
    
    /// Tries to load a mobile map package and if successful, then updates state
    /// associated with it.
    private func loadAndUpdateMobileMapPackage(mmpk: MobileMapPackage) async {
        do {
            try await mmpk.load()
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
            if let mmpk = try? result.get().mobileMapPackage {
                await loadAndUpdateMobileMapPackage(mmpk: mmpk)
            }
            self.job = nil
        }
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
