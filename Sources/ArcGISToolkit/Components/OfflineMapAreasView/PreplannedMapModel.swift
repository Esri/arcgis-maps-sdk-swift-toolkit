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
    
    /// The ID of the web map.
    private let portalItemID: String
    
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
        offlineMapTask: OfflineMapTask,
        mapArea: PreplannedMapAreaProtocol,
        portalItemID: String
    ) {
        self.offlineMapTask = offlineMapTask
        preplannedMapArea = mapArea
        self.portalItemID = portalItemID
        
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
                    result = await job?.result.map { $0.mobileMapPackage }
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
        case .success(let mobileMapPackage):
            status = .downloaded
            self.mobileMapPackage = mobileMapPackage
        case .failure(let error):
            status = .downloadFailure(error)
        case .none:
            return
        }
    }
    
    /// Sets the mobile map package if downloaded locally.
    func setMobileMapPackage() {
        guard job == nil else { return }
        
        // Construct file URL for mobile map package with file structure:
        // .../OfflineMapAreas/Preplanned/{id}/Package/{id}.mmpk
        let fileURL = FileManager.default.preplannedDirectory(forPortalItemID: portalItemID)
            .appending(path: preplannedMapAreaID, directoryHint: .isDirectory)
            .appending(component: FileManager.packageDirectoryPath, directoryHint: .isDirectory)
            .appendingPathComponent(preplannedMapAreaID)
            .appendingPathExtension(FileManager.mmpkPathExtension)
        
        if FileManager.default.fileExists(atPath: fileURL.relativePath) {
            self.mobileMapPackage = MobileMapPackage.init(fileURL: fileURL)
            status = .downloaded
        }
    }
    
    /// Posts a local notification that the job completed with success or failure.
    func notifyJobCompleted() {
        guard let job,
              job.status == .succeeded || job.status == .failed,
              let preplannedMapArea = job.parameters.preplannedMapArea,
              let id = preplannedMapArea.id else { return }
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        
        let jobStatus = job.status == .succeeded ? "Succeeded" : "Failed"
        
        content.title = "Download \(jobStatus)"
        content.body = "The job for \(preplannedMapArea.title) has \(jobStatus.lowercased())."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = id.rawValue
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
            
            let mmpkDirectory = FileManager.default.mmpkDirectory(forPortalItemID: portalItemID, preplannedMapAreaID: preplannedMapAreaID)
            
            try FileManager.default.createDirectory(at: mmpkDirectory, withIntermediateDirectories: true)
            
            await runDownloadTask(for: parameters, in: mmpkDirectory)
        } catch {
            // If creating the parameters or directories fails, set the failure.
            self.result = .failure(error)
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
        portalItem.description
    }
    
    var id: PortalItem.ID? {
        portalItem.id
    }
}

private extension FileManager {
    static let mmpkPathExtension: String = "mmpk"
    static let offlineMapAreasPath: String = "OfflineMapAreas"
    static let packageDirectoryPath: String = "Package"
    static let preplannedDirectoryPath: String = "Preplanned"
    
    /// The path to the documents folder.
    var documentsDirectory: URL {
        URL.documentsDirectory
    }
    
    /// The path to the offline map areas directory within the documents directory.
    var offlineMapAreasDirectory: URL {
        documentsDirectory.appending(
            path: Self.offlineMapAreasPath,
            directoryHint: .isDirectory
        )
    }
    
    /// The path to the web map directory for a specific portal item.
    /// - Parameter portalItemID: The ID of the web map portal item.
    func webMapDirectory(forPortalItemID portalItemID: String) -> URL {
        offlineMapAreasDirectory.appending(path: portalItemID, directoryHint: .isDirectory)
    }
    
    /// The path to the preplanned map areas directory for a specific portal item.
    /// - Parameter portalItemID: The ID of the web map portal item.
    func preplannedDirectory(forPortalItemID portalItemID: String) -> URL {
        webMapDirectory(forPortalItemID: portalItemID).appending(
            path: Self.preplannedDirectoryPath,
            directoryHint: .isDirectory
        )
    }
    
    /// The path to the download directory for the preplanned map area metadata and mobile map package.
    /// - Parameters:
    ///   - portalItemID: The ID of the web map portal item.
    ///   - preplannedMapAreaID: The ID of the preplanned map area.
    func downloadDirectory(forPortalItemID portalItemID: String, preplannedMapAreaID: String) -> URL {
        preplannedDirectory(forPortalItemID: portalItemID)
            .appending(
                path: preplannedMapAreaID,
                directoryHint: .isDirectory
            )
    }
    
    /// The path to the package directory for the preplanned map area mobile map package.
    /// - Parameters:
    ///   - portalItemID: The ID of the web map portal item.
    ///   - preplannedMapAreaID: The ID of the preplanned map area.
    func packageDirectory(forPortalItemID portalItemID: String, preplannedMapAreaID: String) -> URL {
        downloadDirectory(forPortalItemID: portalItemID, preplannedMapAreaID: preplannedMapAreaID)
            .appending(
                component: Self.packageDirectoryPath,
                directoryHint: .isDirectory
            )
    }
    
    /// The path to the mobile map package file for the preplanned map area mobile map package.
    /// - Parameters:
    ///   - portalItemID: The ID of the web map portal item.
    ///   - preplannedMapAreaID: The ID of the preplanned map area.
    func mmpkDirectory(forPortalItemID portalItemID: String, preplannedMapAreaID: String) -> URL {
        packageDirectory(forPortalItemID: portalItemID, preplannedMapAreaID: preplannedMapAreaID)
            .appendingPathComponent(preplannedMapAreaID)
            .appendingPathExtension(Self.mmpkPathExtension)
    }
}
