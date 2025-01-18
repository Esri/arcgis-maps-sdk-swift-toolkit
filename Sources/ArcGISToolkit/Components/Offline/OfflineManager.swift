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

/// An object that maintains state for the offline components.
@MainActor
public class OfflineManager: ObservableObject {
    /// The shared offline manager.
    public static let shared = OfflineManager()
    
    /// The action to perform when a job completes.
    var jobCompletionAction: ((any JobProtocol) -> Void)?
    
    /// The job manager used by the offline manager.
    let jobManager = JobManager(uniqueID: "offlineManager")
    
    /// The jobs managed by this instance.
    var jobs: [any JobProtocol] { jobManager.jobs }
    
    /// The portal item information for webmaps that have downloaded map areas.
    @Published
    private(set) public var offlineMapInfos: [OfflineMapInfo] = []
    
    /// The available offline map view models.
    private var models: [Item.ID: OfflineMapViewModel] = [:]
    
    private init() {
        Logger.offlineManager.debug("Initializing OfflineManager")
        
        // Retrieves the offline map infos from the user defaults.
        loadOfflineMapInfos()
        
        // Observe each job's status.
        for job in jobManager.jobs {
            observeJob(job)
        }
        
        // Resume all paused jobs.
        Logger.offlineManager.debug("Resuming all paused jobs")
        jobManager.resumeAllPausedJobs()
    }
    
    /// Starts a job that will be managed by this instance.
    /// - Parameter job: The job to start.
    func start(job: any JobProtocol, portalItem: PortalItem) {
        Logger.offlineManager.debug("Starting Job from offline manager")
        jobManager.jobs.append(job)
        observeJob(job)
        job.start()
        Task.detached {
            await self.savePendingMapInfo(for: portalItem)
        }
    }
    
    /// Observes a job for completion.
    private func observeJob<Job: JobProtocol>(_ job: Job) {
        Task {
            Logger.offlineManager.debug("Observing job completion")
            
            // Wait for job to finish.
            let result = await job.result
            
            // Remove completed job from JobManager.
            Logger.offlineManager.debug("Removing completed job from job manager")
            jobManager.jobs.removeAll { $0 === job }
            
            // This isn't strictly required, but it helps to get the state saved as soon
            // as possible after removing a job instead of waiting for the app to be backgrounded.
            jobManager.saveState()
            
            // Call job completion action.
            jobCompletionAction?(job)
            
            // Check pending map infos.
            if let portalItem = onlineMapPrtalItem(for: job), let id = portalItem.id {
                try? handlePendingMapInfo(for: result, portalItemID: id)
            }
        }
    }
    
    private func onlineMapPrtalItem<Job: JobProtocol>(for job: Job) -> PortalItem? {
        switch job {
        case let downloadPreplanned as DownloadPreplannedOfflineMapJob:
            downloadPreplanned.onlineMap?.item as? PortalItem
        default:
            nil
        }
    }
    
    /// Retrieves the model for a given online map.
    /// - Precondition: `onlineMap.item?.id` is not `nil`.
    func model(for onlineMap: Map) -> OfflineMapViewModel {
        precondition(onlineMap.item?.id != nil)
        return models[onlineMap.item!.id!, setDefault: .init(onlineMap: onlineMap)]
    }
    
    /// Retrieves the model for a given `OfflineMapInfo`.
    private func model(for offlineMapInfo: OfflineMapInfo) -> OfflineMapViewModel {
        if let model = models[offlineMapInfo.portalItemID] {
            return model
        } else {
            // Only create the map here if we don't already have the model in memory.
            let onlineMap = Map(item: PortalItem(url: offlineMapInfo.portalItemURL)!)
            return model(for: onlineMap)
        }
    }
    
    /// Deletes map information for a given portal item ID from UserDefaults.
    /// - Parameter portalItemID: The portal item ID.
    func deleteMapInfo(for portalItemID: Item.ID) {
        offlineMapInfos.removeAll(where: { $0.portalItemID == portalItemID })
        saveOfflineMapInfosToDefaults()
    }
    
    /// Saves the offline map information to the defaults.
    private func saveOfflineMapInfosToDefaults() {
//        Logger.offlineManager.debug("Saving offline map info to user defaults")
//        do {
//            UserDefaults.standard.set(
//                try JSONEncoder().encode(offlineMapInfos),
//                forKey: Self.defaultsKey
//            )
//        } catch {
//            Logger.offlineManager.error("Error saving offline map info to user defaults: \(error.localizedDescription)")
//        }
    }
    
    /// Loads offline map information from offline manager directory.
    private func loadOfflineMapInfos() {
        let url = URL.offlineManagerDirectory()
        var infos = [OfflineMapInfo]()
        defer { self.offlineMapInfos = infos }
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path()) else { return }
        for dir in contents {
            let infoURL = url.appending(components: dir, "info.json")
            guard FileManager.default.fileExists(atPath: infoURL.path()) else { continue }
            Logger.offlineManager.debug("Found offline map info at \(infoURL.path())")
            guard let data = try? Data(contentsOf: infoURL),
                  let info = try? JSONDecoder().decode(OfflineMapInfo.self, from: data)
            else { continue }
            infos.append(info)
        }
    }
    
    private func savePendingMapInfo(for portalItem: PortalItem) async {
        guard let portalItemID = portalItem.id,
              let info = OfflineMapInfo(portalItem: portalItem)
        else { return }
        
        // First create directory for what we need to save to json
        let url = URL.pendingMapInfoDirectory(forPortalItem: portalItemID)
        let infoURL = url.appending(path: "info.json")
        
        Logger.offlineManager.debug("Saving pending offline map info to \(url.path())")
        
        // If already exists, return.
        let completedDir = URL.portalItemDirectory(forPortalItemID: portalItemID).appending(path: "info.json")
        guard !FileManager.default.fileExists(atPath: completedDir.path()) else {
            Logger.offlineManager.debug("Returning, info already exists in job completion directory: \(completedDir.path())")
            return
        }
        guard !FileManager.default.fileExists(atPath: infoURL.path()) else {
            Logger.offlineManager.debug("Returning, info already exists in pending directory: \(url.path())")
            return
        }
        
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        
        // Save json to file.
        if let data = try? JSONEncoder().encode(info) {
            try? data.write(to: infoURL, options: .atomic)
        }
        
        // Save thumbnail to file.
        if let thumbnail = portalItem.thumbnail {
            try? await thumbnail.load()
            if let image = thumbnail.image, let pngData = image.pngData() {
                let thumbnailURL = url.appending(path: "thumbnail.png")
                try? pngData.write(to: thumbnailURL, options: .atomic)
            }
        }
    }
    
    private func handlePendingMapInfo<Output>(
        for result: Result<Output, Error>,
        portalItemID: Item.ID) {
        switch result {
        case .success:
            // Move the pending info into the correct folder.
            let pendingURL = URL.pendingMapInfoDirectory(forPortalItem: portalItemID)
            let portalItemDir = URL.portalItemDirectory(forPortalItemID: portalItemID)
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: pendingURL.path()) else { return }
            for file in contents {
                let source = pendingURL.appending(path: file)
                let dest = portalItemDir.appending(path: file)
                guard !FileManager.default.fileExists(atPath: dest.path()) else { continue }
                Logger.offlineManager.debug("Moving offline map info for completed job to \(dest.path())")
                do {
                    try FileManager.default.moveItem(atPath: source.path(), toPath: dest.path())
                } catch {
                    Logger.offlineManager.error("Error moving offline map info file \(file): \(error.localizedDescription)")
                }
            }
        case .failure:
            // If job failed then do nothing. Pending info can stay in the caches directory
            // as it is likely going to be used when then user tries again.
            // If not, the OS will eventually delete it.
            break
        }
    }
    
    /// Removes all downloads for all offline maps.
    public func removeAllDownloads() throws {
        for offlineMapInfo in offlineMapInfos {
            try removeDownloads(for: offlineMapInfo)
        }
    }
    
    /// Removes any downloaded map areas for a particular map.
    /// - Parameter offlineMapInfo: The information for the offline map for which all downloads will
    /// be removed.
    public func removeDownloads(for offlineMapInfo: OfflineMapInfo) throws {
        let model = model(for: offlineMapInfo)
        // Don't load the preplanned models, only iterate the ones we have in memory.
        // This allows any views depending on these models to update accordingly,
        // without going over the network to get the preplanned map models.
        // If there are more downloaded that aren't in memory, we will delete the directory
        // to take care of those.
        if case .success(let preplannedModels) = model.preplannedMapModels {
            for preplannedModel in preplannedModels {
                preplannedModel.removeDownloadedPreplannedMapArea()
            }
        }
        // Now remove any offline map areas whose model isn't in memory by simply deleting the
        // preplanned directory.
        let preplannedDirectory = URL.preplannedDirectory(forPortalItemID: offlineMapInfo.portalItemID)
        try FileManager.default.removeItem(at: preplannedDirectory)
    }
}

public extension SwiftUI.Scene {
    /// Sets up the offline manager for offline toolkit components.
    /// - Parameters:
    ///   - preferredBackgroundStatusCheckSchedule: The preferred background status check schedule. See ``JobManager/preferredBackgroundStatusCheckSchedule`` for more details.
    ///   - jobCompletion: An action to perform when a job completes.
    @MainActor
    func offlineManager(
        preferredBackgroundStatusCheckSchedule: BackgroundStatusCheckSchedule,
        jobCompletion jobCompletionAction: ((any JobProtocol) -> Void)? = nil
    ) -> some SwiftUI.Scene {
        Logger.offlineManager.debug("Executing OfflineManager SwiftUI.Scene modifier")
        
        // Set the background status check schedule.
        OfflineManager.shared.jobManager.preferredBackgroundStatusCheckSchedule = preferredBackgroundStatusCheckSchedule
        
        // Set callback for job completion.
        OfflineManager.shared.jobCompletionAction = jobCompletionAction
        
        // Support app-relaunch after background downloads.
        return self.backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
            Logger.offlineManager.debug("Executing OfflineManager backgroundTask")
            
            // Allow the `ArcGISURLSession` to handle its background task events.
            await ArcGISEnvironment.backgroundURLSession.handleEventsForBackgroundTask()
            
            // When the app is re-launched from a background url session, resume any paused jobs,
            // and check the job status.
            await OfflineManager.shared.jobManager.resumeAllPausedJobs()
        }
    }
}

extension Logger {
    /// A logger for the offline manager.
    static var offlineManager: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_OFFLINE_MANAGER") {
            Logger(subsystem: "com.esri.ArcGISToolkit", category: "OfflineManager")
        } else {
            .init(.disabled)
        }
    }
}

public struct OfflineMapInfo: Codable {
    private var portalItemIDRawValue: String
    public var title: String
    public var description: String
    public var portalItemURL: URL
    
    internal init?(portalItem: PortalItem) {
        guard let idRawValue = portalItem.id?.rawValue,
              let url = portalItem.url
        else { return nil }
        
        self.portalItemIDRawValue = idRawValue
        self.title = portalItem.title
        self.description = portalItem.description.replacing(/<[^>]+>/, with: "")
        self.portalItemURL = url
    }
}

public extension OfflineMapInfo {
    var portalItemID: Item.ID {
        .init(portalItemIDRawValue)!
    }
}

private extension Dictionary {
    /// Returns the value for the key, and if the value is nil it first stores
    /// the default value in the dictionary then returns the default value.
    subscript(key: Key, setDefault defaultValue: @autoclosure () -> Value) -> Value {
        mutating get {
            return self[key] ?? {
                let value = defaultValue()
                self[key] = value
                return value
            }()
        }
    }
}
