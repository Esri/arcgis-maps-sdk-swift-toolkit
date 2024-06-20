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
class PreplannedMapModel: ObservableObject, Identifiable {
    /// The preplanned map area.
    let preplannedMapArea: any PreplannedMapAreaProtocol
    
    /// The task to use to take the area offline.
    private let offlineMapTask: OfflineMapTask?
    
    /// The ID of the web map.
    private let portalItemID: PortalItem.ID
    
    /// The ID of the preplanned map area.
    private let preplannedMapAreaID: PortalItem.ID
    
    /// The mobile map package for the preplanned map area.
    private(set) var mobileMapPackage: MobileMapPackage?
    
    /// The currently running download job.
    @Published private(set) var job: DownloadPreplannedOfflineMapJob?
    
    /// The combined status of the preplanned map area.
    @Published private(set) var status: Status = .notLoaded
    
    /// A Boolean value indicating if a user notification should be shown when a job completes.
    private let showsUserNotificationOnCompletion: Bool
    
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
        self.showsUserNotificationOnCompletion = showsUserNotificationOnCompletion
        
        if let foundJob = lookupDownloadJob() {
            startAndObserveJob(foundJob)
        } else if let mmpk = lookupMobileMapPackage() {
            self.mobileMapPackage = mmpk
            self.status = .downloaded
        }
    }
    
    init(
        mapArea: PreplannedMapAreaProtocol,
        portalItemID: PortalItem.ID,
        preplannedMapAreaID: PortalItem.ID
    ) {
        preplannedMapArea = mapArea
        self.portalItemID = portalItemID
        self.preplannedMapAreaID = preplannedMapAreaID
        showsUserNotificationOnCompletion = false
        offlineMapTask = nil
        
        if let mmpk = lookupMobileMapPackage() {
            self.mobileMapPackage = mmpk
            self.status = .downloaded
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
    
    /// Look up the job associated with this preplanned map model.
    private func lookupDownloadJob() -> DownloadPreplannedOfflineMapJob? {
        JobManager.shared.jobs
            .lazy
            .compactMap { $0 as? DownloadPreplannedOfflineMapJob }
            .first {
                $0.downloadDirectoryURL.deletingPathExtension().lastPathComponent == preplannedMapAreaID.rawValue
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
            return
        }
    }
    
    /// Updates the status based on the download result of the mobile map package.
    func updateDownloadStatus(for downloadResult: Result<DownloadPreplannedOfflineMapResult, any Error>?) {
        switch downloadResult {
        case .success:
            status = .downloaded
        case .failure(let error):
            status = .downloadFailure(error)
        case .none:
            return
        }
    }
    
    /// Looks up the mobile map package directory for locally downloaded package.
    private func lookupMobileMapPackage() -> MobileMapPackage? {
        let fileURL = FileManager.default.mmpkDirectory(
            forPortalItemID: portalItemID,
            preplannedMapAreaID: preplannedMapAreaID
        )
        guard FileManager.default.fileExists(atPath: fileURL.relativePath) else { return nil }
        return MobileMapPackage.init(fileURL: fileURL)
    }
    
    /// Posts a local notification that the job completed with success or failure.
    /// - Precondition: `job.status == .succeeded || job.status == .failed`
    private static func notifyJobCompleted(job: DownloadPreplannedOfflineMapJob) async throws {
        precondition(job.status == .succeeded || job.status == .failed)
        guard
            let preplannedMapArea = job.parameters.preplannedMapArea,
            let id = preplannedMapArea.id
        else { return }
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        
        let jobStatus = job.status == .succeeded ? "Succeeded" : "Failed"
        
        content.title = "Download \(jobStatus)"
        content.body = "The job for \(preplannedMapArea.title) has \(jobStatus.lowercased())."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = id.rawValue
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await UNUserNotificationCenter.current().add(request)
    }
    
    /// Downloads the preplanned map area.
    /// - Precondition: `status.allowsDownload`
    func downloadPreplannedMapArea() async {
        precondition(status.allowsDownload)
        guard let offlineMapTask else { return }
        status = .downloading
        
        do {
            let parameters = try await preplannedMapArea.makeParameters(using: offlineMapTask)
            let mmpkDirectory = FileManager.default.mmpkDirectory(
                forPortalItemID: portalItemID,
                preplannedMapAreaID: preplannedMapAreaID
            )
            try FileManager.default.createDirectory(at: mmpkDirectory, withIntermediateDirectories: true)
            
            // Create the download preplanned offline map job.
            let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
                parameters: parameters,
                downloadDirectory: mmpkDirectory
            )
            JobManager.shared.jobs.append(job)
            startAndObserveJob(job)
        } catch {
            status = .downloadFailure(error)
        }
    }
    
    /// Sets the job property of this instance, starts the job, observes it, and
    /// when it's done, updates the status, removes the job from the job manager,
    /// and fires a user notification.
    private func startAndObserveJob(_ job: DownloadPreplannedOfflineMapJob) {
        self.job = job
        job.start()
        status = .downloading
        Task {
            let result = await job.result
            updateDownloadStatus(for: result)
            mobileMapPackage = try? result.map { $0.mobileMapPackage }.get()
            JobManager.shared.jobs.removeAll { $0 === job }
            if showsUserNotificationOnCompletion && (job.status == .succeeded || job.status == .failed) {
                try? await Self.notifyJobCompleted(job: job)
            }
            self.job = nil
            writeMetadata()
        }
    }
    
    /// Writes the metadata for the preplanned map model to an associated `metadata.json` file.
    private func writeMetadata() {
        do {
            // Write preplanned map area thumbnail image to `thumbnail.png` file.
            if let thumbnail = preplannedMapArea.thumbnail?.image {
                let thumbnailPath = FileManager.default.thumbnailPath(
                    forPortalItemID: portalItemID,
                    preplannedMapAreaID: preplannedMapAreaID
                )
                
                if let thumbnailData = thumbnail.pngData() {
                    try thumbnailData.write(to: thumbnailPath, options: .atomic)
                }
            }
            
            // Write preplanned map area metadata to `metadata.json` file.
            let metadataPath = FileManager.default.metadataPath(
                forPortalItemID: portalItemID,
                preplannedMapAreaID: preplannedMapAreaID
            )
            
            let jsonObject: [String: Any] = [
                OfflineMapAreasView.title : preplannedMapArea.title,
                OfflineMapAreasView.description : preplannedMapArea.description,
                OfflineMapAreasView.id : preplannedMapAreaID.rawValue
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .sortedKeys)
            try jsonData.write(to: metadataPath, options: .atomic)
        } catch {
            return
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
        
        /// A Boolean value indicating if download is allowed for this status.
        var allowsDownload: Bool {
            switch self {
            case .notLoaded, .loading, .loadFailure, .packaging, .packageFailure,
                    .downloading, .downloaded:
                false
            case .packaged, .downloadFailure:
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
    func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters
    
    var packagingStatus: PreplannedMapArea.PackagingStatus? { get }
    var title: String { get }
    var description: String { get }
    var thumbnail: LoadableImage? { get }
    var thumbnailImage: UIImage? { get }
    var id: PortalItem.ID? { get }
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
    
    var thumbnailImage: UIImage? { nil }
    
    var description: String {
        portalItem.description
    }
    
    var id: PortalItem.ID? {
        portalItem.id
    }
}

extension FileManager {
    private static let jsonPathExtension: String = "json"
    private static let metadataFilePath: String = "metadata"
    private static let offlineMapAreasPath: String = "OfflineMapAreas"
    private static let packageDirectoryPath: String = "Package"
    private static let preplannedDirectoryPath: String = "Preplanned"
    private static let pngPathExtension: String = "png"
    private static let thumbnailFilePath: String = "thumbnail"
    
    /// The path to the documents folder.
    private var documentsDirectory: URL {
        URL.documentsDirectory
    }
    
    /// The path to the offline map areas directory within the documents directory.
    /// `Documents/OfflineMapAreas`
    private var offlineMapAreasDirectory: URL {
        documentsDirectory.appending(
            path: Self.offlineMapAreasPath,
            directoryHint: .isDirectory
        )
    }
    
    /// The path to the web map directory for a specific portal item.
    /// `Documents/OfflineMapAreas/<Portal Item ID>`
    /// - Parameter portalItemID: The ID of the web map portal item.
    private func portalItemDirectory(forPortalItemID portalItemID: PortalItem.ID) -> URL {
        offlineMapAreasDirectory.appending(path: portalItemID.rawValue, directoryHint: .isDirectory)
    }
    
    /// The path to the preplanned map areas directory.
    /// `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned`
    /// - Parameter portalItemID: The ID of the web map portal item.
    func preplannedAreasDirectory(forPortalItemID portalItemID: PortalItem.ID) -> URL {
        portalItemDirectory(forPortalItemID: portalItemID)
            .appending(
                path: Self.preplannedDirectoryPath,
                directoryHint: .isDirectory
            )
    }
    
    /// The path to the directory for a given preplanned map area from a specific portal item.
    /// `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/<Preplanned Area ID>`
    /// - Parameters:
    ///  - portalItemID: The ID of the web map portal item.
    ///  - preplannedMapAreaID: The ID of the preplanned map area.
    private func preplannedDirectory(
        forPortalItemID portalItemID: PortalItem.ID,
        preplannedMapAreaID: PortalItem.ID
    ) -> URL {
        preplannedAreasDirectory(forPortalItemID: portalItemID)
            .appending(
                path: preplannedMapAreaID.rawValue,
                directoryHint: .isDirectory
            )
    }
    
    /// The path to the`metadata.json` file for a specific preplanned map area.
    /// `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/metadata.json`
    /// - Parameters:
    ///   - portalItemID: The ID of the web map portal item.
    ///   - preplannedMapAreaID: The ID of the preplanned map area.
    func metadataPath(
        forPortalItemID portalItemID: PortalItem.ID,
        preplannedMapAreaID: PortalItem.ID
    ) -> URL {
        preplannedDirectory(
            forPortalItemID: portalItemID,
            preplannedMapAreaID: preplannedMapAreaID
        )
        .appending(path: Self.metadataFilePath)
        .appendingPathExtension(Self.jsonPathExtension)
    }
    
    /// The path to the thumbnail image file for a specific preplanned map area.
    /// `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/thumbnail.png`
    /// - Parameters:
    ///   - portalItemID: The ID of the web map portal item.
    ///   - preplannedMapAreaID: The ID of the preplanned map area.
    func thumbnailPath(
        forPortalItemID portalItemID: PortalItem.ID,
        preplannedMapAreaID: PortalItem.ID
    ) -> URL {
        preplannedDirectory(
            forPortalItemID: portalItemID,
            preplannedMapAreaID: preplannedMapAreaID
        )
        .appending(path: Self.thumbnailFilePath)
        .appendingPathExtension(Self.pngPathExtension)
    }
    
    /// The path to the mobile map package directory for a specific preplanned map area.
    /// `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/<Preplanned Area ID>`
    /// - Parameters:
    ///   - portalItemID: The ID of the web map portal item.
    ///   - preplannedMapAreaID: The ID of the preplanned map area.
    func mmpkDirectory(
        forPortalItemID portalItemID: PortalItem.ID,
        preplannedMapAreaID: PortalItem.ID
    ) -> URL {
        preplannedDirectory(
            forPortalItemID: portalItemID,
            preplannedMapAreaID: preplannedMapAreaID
        )
        .appending(path: preplannedMapAreaID.rawValue)
    }
}

