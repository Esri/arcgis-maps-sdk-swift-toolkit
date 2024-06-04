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

import SwiftUI
import ArcGIS

/// An object that encapsulates state about a preplanned map.
public class PreplannedMapModel: ObservableObject, Identifiable {
    /// The preplanned map area.
    let preplannedMapArea: any PreplannedMapAreaProtocol
    
    /// The view model for the map.
    private var mapViewModel: OfflineMapAreasView.MapViewModel
    
    /// The task to use to take the area offline.
    private let offlineMapTask: OfflineMapTask
    
    /// The download directory for the preplanned map areas.
    private let preplannedDirectory: URL
    
    /// The ID of the preplanned map area.
    private let preplannedMapAreaID: String
    
    /// The mobile map package for the preplanned map area.
    private(set) var mobileMapPackage: MobileMapPackage?
    
    /// The currently running download job.
    @Published private(set) var job: DownloadPreplannedOfflineMapJob?
    
    /// The combined status of the preplanned map area.
    @Published private(set) var status: Status = .notLoaded

    /// The result of the download job. When the result is `.success` the mobile map package is returned.
    /// If the result is `.failure` then the error is returned. The result will be `nil` when the preplanned
    /// map area is still packaging or loading.
    @Published private(set) var result: Result<MobileMapPackage, Error>?
    
    /// A Boolean value indicating if download can be called.
    var canDownload: Bool {
        switch status {
        case .notLoaded, .loading, .loadFailure, .packaging, .packageFailure,
                .downloading, .downloaded:
            false
        case .packaged, .downloadFailure:
            true
        }
    }
    
    init?(
        preplannedMapArea: PreplannedMapAreaProtocol,
        mapViewModel: OfflineMapAreasView.MapViewModel,
        mobileMapPackage: MobileMapPackage? = nil
    ) {
        offlineMapTask = mapViewModel.offlineMapTask
        self.preplannedMapArea = preplannedMapArea
        self.mobileMapPackage = mobileMapPackage
        preplannedDirectory = mapViewModel.preplannedDirectory
        
        if let itemID = preplannedMapArea.id {
            preplannedMapAreaID = itemID.rawValue
        } else {
            return nil
        }
        
        self.mapViewModel = mapViewModel
    
        // Kick off a load of the map area.
        Task.detached {
            await self.load()
            await self.updateDownloadStatus()
        }
    }
    
    /// Loads the preplanned map area and updates the status.
    @MainActor
    private func load() async {
        do {
            // Load preplanned map area to obtain packaging status.
            status = .loading
            try await preplannedMapArea.retryLoad()
            // Note: Packaging status is `nil` for compatibility with
            // legacy webmaps that have incomplete metadata.
            // If the area loads, then you know for certain the status is complete.
            updateStatus(for: preplannedMapArea.packagingStatus ?? .complete)
        } catch MappingError.packagingNotComplete {
            // Load will throw an `MappingError.packagingNotComplete` error if not complete,
            // this case is not a normal load failure.
            updateStatus(for: preplannedMapArea.packagingStatus ?? .failed)
        } catch {
            // Normal load failure.
            status = .loadFailure(error)
        }
    }
    
    /// Updates the status for a given packaging status.
    @MainActor
    private func updateStatus(for packagingStatus: PreplannedMapArea.PackagingStatus) {
        // Update area status for a given packaging status.
        switch packagingStatus {
        case .processing:
            status = .packaging
        case .failed:
            status = .packageFailure
        case .complete:
            status = .packaged
        @unknown default:
            fatalError("Unknown packaging status")
        }
    }
    
    /// Updates the status to downloaded if the mobile map pacakge exists.
    @MainActor
    private func updateDownloadStatus() {
        self.mobileMapPackage = mapViewModel.mobileMapPackages.first(where: { $0.fileURL.lastPathComponent == preplannedMapArea.id?.rawValue.appending(".mmpk") })
        
        if mobileMapPackage != nil {
            status = .downloaded
        }
    }
    
    /// Updates the status based on the download result of the mobile map package.
    @MainActor
    func updateDownloadStatus(for downloadResult: Optional<Result<MobileMapPackage, any Error>>) {
        switch downloadResult {
        case .success:
            status = .downloaded
        case .failure(let error):
            status = .downloadFailure(error)
        case .none:
            updateDownloadStatus()
        }
    }
    
    /// Posts a local notification that the job completed.
    func notifyJobCompleted(_ jobStatus: Job.Status) {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        
        if jobStatus == .succeeded {
            content.title = "Download Succeeded"
            content.body = "The job for City Hall Area has completed successfully."
        } else if jobStatus == .failed {
            content.title = "Download Failed"
            content.body = "The job for City Hall Area failed."
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "My Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

extension PreplannedMapModel {
    /// Downloads the given preplanned map area.
    /// - Parameter preplannedMapArea: The preplanned map area to be downloaded.
    /// - Precondition: `canDownload`
    @MainActor
    func downloadPreplannedMapArea() async {
        precondition(canDownload)
        
        let downloadDirectory = preplannedDirectory
            .appending(path: preplannedMapAreaID, directoryHint: .isDirectory)
        
        let packageDirectory = downloadDirectory
            .appending(component: "package", directoryHint: .isDirectory)
        
        try? FileManager.default.createDirectory(atPath: downloadDirectory.relativePath, withIntermediateDirectories: true)
        
        try? FileManager.default.createDirectory(atPath: packageDirectory.relativePath, withIntermediateDirectories: true)
        
        let mmpkDirectory = packageDirectory
            .appendingPathComponent(preplannedMapAreaID)
            .appendingPathExtension("mmpk")

        let parameters: DownloadPreplannedOfflineMapParameters
        
        do {
            // Creates the parameters for the download preplanned offline map job.
            parameters = try await makeParameters(preplannedMapArea: preplannedMapArea.mapArea!)
        } catch {
            // If creating the parameters fails, set the failure.
            self.result = .failure(error)
            return
        }
        
        // Creates the download preplanned offline map job.
        let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
            parameters: parameters,
            downloadDirectory: mmpkDirectory
        )
        
        mapViewModel.jobManager.jobs.append(job)
        
        self.job = job
        
        // Starts the job.
        job.start()
        
        if canDownload {
            status = .downloading
        }
        
        // Awaits the output of the job and assigns the result.
        result = await job.result.map { $0.mobileMapPackage }
    }
    
    /// Creates the parameters for a download preplanned offline map job.
    /// - Parameter preplannedMapArea: The preplanned map area to create parameters for.
    /// - Returns: A `DownloadPreplannedOfflineMapParameters` if there are no errors.
    func makeParameters(
        preplannedMapArea: PreplannedMapArea
    ) async throws -> DownloadPreplannedOfflineMapParameters {
        // Creates the default parameters.
        let parameters = try await offlineMapTask.makeDefaultDownloadPreplannedOfflineMapParameters(
            preplannedMapArea: preplannedMapArea
        )
        // Sets the update mode to no updates as the offline map is display-only.
        parameters.updateMode = .noUpdates
        return parameters
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
    }
}

extension PreplannedMapModel: Hashable {
    public static func == (lhs: PreplannedMapModel, rhs: PreplannedMapModel) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

/// A type that acts as a preplanned map area.
protocol PreplannedMapAreaProtocol {
    func retryLoad() async throws
    
    var mapArea: PreplannedMapArea? { get }
    var packagingStatus: PreplannedMapArea.PackagingStatus? { get }
    var title: String { get }
    var description: String { get }
    var thumbnail: LoadableImage? { get }
    var id: PortalItem.ID? { get }
}

/// Extend `PreplannedMapArea` to conform to `PreplannedMapAreaProtocol`.
extension PreplannedMapArea: PreplannedMapAreaProtocol {
    var mapArea: PreplannedMapArea? {
        self
    }
    
    var title: String {
        portalItem.title
    }
    
    var thumbnail: LoadableImage? {
        portalItem.thumbnail
    }
    
    var description: String {
        portalItem.description
    }
    
    var id: PortalItem.ID? {
        portalItem.id
    }
}
