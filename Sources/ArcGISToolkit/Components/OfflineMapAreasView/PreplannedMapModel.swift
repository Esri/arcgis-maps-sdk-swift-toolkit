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
@MainActor
public class PreplannedMapModel: ObservableObject, Identifiable {
    /// The preplanned map area.
    let preplannedMapArea: any PreplannedMapAreaProtocol
    
    /// The task to use to take the area offline.
    private let offlineMapTask: OfflineMapTask
    
    /// The download directory for the preplanned map areas.
    private let preplannedDirectory: URL
    
    /// The ID of the preplanned map area.
    private let  preplannedMapAreaID: String
    
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
        offlineMapTask: OfflineMapTask,
        mapArea: PreplannedMapAreaProtocol,
        directory: URL
    ) {
        self.offlineMapTask = offlineMapTask
        preplannedMapArea = mapArea
        preplannedDirectory = directory
        
        if let itemID = preplannedMapArea.id {
            preplannedMapAreaID = itemID.rawValue
        } else {
            return nil
        }
        
        setDownloadJob()
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
    
    /// Sets the model download preplanned offline map job if the job is in progress.
    private func setDownloadJob() {
        for case let preplannedJob as DownloadPreplannedOfflineMapJob in JobManager.shared.jobs {
            if preplannedJob.downloadDirectoryURL.deletingPathExtension().lastPathComponent == preplannedMapAreaID {
                job = preplannedJob
                status = .downloading
                Task {
                    result = await preplannedJob.result.map { $0.mobileMapPackage }
                }
            }
        }
    }
    
    /// Updates the status for a given packaging status.
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
    
    /// Updates the status based on the download result of the mobile map package.
    func updateDownloadStatus(for downloadResult: Optional<Result<MobileMapPackage, any Error>>) {
        switch downloadResult {
        case .success:
            status = .downloaded
            if let mobileMapPackage = try? downloadResult?.get() {
                self.mobileMapPackage = mobileMapPackage
            }
        case .failure(let error):
            status = .downloadFailure(error)
        case .none:
            if let mobileMapPackage = try? downloadResult?.get() {
                setMobileMapPackage(mobileMapPackage)
            }
        }
    }
    
    /// Sets the mobile map package once downloaded.
    /// - Parameter mobileMapPackage: The mobile map package.
    func setMobileMapPackage(_ mobileMapPackage: MobileMapPackage) {
        // Set the mobile map package if already downloaded or the download job succeeded.
        if job == nil || job?.status == .succeeded {
            // Set the mobile map package if it downloaded.
            self.mobileMapPackage = mobileMapPackage
            status = .downloaded
        }
    }
    
    /// Sets the mobile map package if downloaded locally.
    func setMobileMapPackageFromDownloads() {
        let mobileMapPackages = OfflineMapAreasView.urls(
            in: preplannedDirectory,
            withPathExtension: "mmpk"
        ).map(MobileMapPackage.init(fileURL:))
        
        if let mobileMapPackage = mobileMapPackages.first(where: {
            $0.fileURL.deletingPathExtension().lastPathComponent == preplannedMapArea.id?.rawValue
        }) {
            setMobileMapPackage(mobileMapPackage)
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
    
    /// Downloads the preplanned map area.
    /// - Precondition: `canDownload`
    func downloadPreplannedMapArea() async {
        precondition(canDownload)
        status = .downloading

        do {
            guard let parameters = try await preplannedMapArea.makeParameters(using: offlineMapTask) else { return }
            
            let mmpkDirectory = try createDownloadDirectories()
            
            await runDownloadTask(for: parameters, in: mmpkDirectory)
        } catch {
            // If creating the parameters or directories fails, set the failure.
            self.result = .failure(error)
        }
    }
    
    /// Creates download directories for the preplanned map area and its mobile map package.
    /// - Returns: The URL for the mobile map package directory.
    private func createDownloadDirectories() throws -> URL {
        do {
            let downloadDirectory = preplannedDirectory
                .appending(path: preplannedMapAreaID, directoryHint: .isDirectory)
            
            let packageDirectory = downloadDirectory
                .appending(component: PreplannedMapModel.PathComponents.package.rawValue, directoryHint: .isDirectory)
            
            try FileManager.default.createDirectory(atPath: downloadDirectory.relativePath, withIntermediateDirectories: true)
            
            try FileManager.default.createDirectory(atPath: packageDirectory.relativePath, withIntermediateDirectories: true)
            
            let mmpkDirectory = packageDirectory
                .appendingPathComponent(preplannedMapAreaID)
                .appendingPathExtension(PreplannedMapModel.PathComponents.mmpk.rawValue)
            
            return mmpkDirectory
        } catch {
            throw error
        }
    }
    
    /// Runs the download task to download the preplanned offline map.
    /// - Parameters:
    ///   - parameters: The parameters used to download the offline map.
    ///   - mmpkDirectory: The directory used to place the mobile map package result.
    private func runDownloadTask(
        for parameters: DownloadPreplannedOfflineMapParameters,
        in mmpkDirectory: URL
    ) async {
        // Create the download preplanned offline map job.
        let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
            parameters: parameters,
            downloadDirectory: mmpkDirectory
        )
        
        JobManager.shared.jobs.append(job)
        
        self.job = job
        
        // Start the job.
        job.start()
        
        // Await the output of the job and assigns the result.
        result = await job.result.map { $0.mobileMapPackage }
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
        
        /// A Boolean value indicating whether the model is in a state
        /// where it needs to be loaded or reloaded.
        var needsToBeLoaded: Bool {
            switch self {
            case .loading, .packaging, .packaged, .downloading, .downloaded:
                false
            default:
                true
            }
        }
    }
}

private extension PreplannedMapModel {
    enum PathComponents: String {
        case package = "package"
        case mmpk = "mmpk"
    }
}

extension PreplannedMapModel: Hashable {
    nonisolated public static func == (lhs: PreplannedMapModel, rhs: PreplannedMapModel) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

/// A type that acts as a preplanned map area.
protocol PreplannedMapAreaProtocol {
    func retryLoad() async throws
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters?
    
    var packagingStatus: PreplannedMapArea.PackagingStatus? { get }
    var title: String { get }
    var description: String { get }
    var thumbnail: LoadableImage? { get }
    var id: PortalItem.ID? { get }
}

/// Extend `PreplannedMapArea` to conform to `PreplannedMapAreaProtocol`.
extension PreplannedMapArea: PreplannedMapAreaProtocol {
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters? {
        do {
            // Create the parameters for the download preplanned offline map job.
            let parameters = try await offlineMapTask.makeDefaultDownloadPreplannedOfflineMapParameters(
                preplannedMapArea: self
            )
            // Set the update mode to no updates as the offline map is display-only.
            parameters.updateMode = .noUpdates
            
            return parameters
        } catch {
            throw error
        }
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