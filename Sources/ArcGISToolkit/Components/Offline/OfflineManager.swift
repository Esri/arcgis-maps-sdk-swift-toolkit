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
import OSLog
import SwiftUI

/// A utility class that maintains states of offline map areas and their
/// file structures on the device.
///
/// This component is based on ``JobManager`` and provides high-level APIs to
/// manage offline map areas and access their data. A custom UI can be built
/// using the APIs provided.
///
/// **Features**
///
/// The component supports both ahead-of-time(preplanned) and on-demand
/// workflows for offline mapping. It allows you to:
///
/// - Observe job status.
/// - Access map info for web maps that have saved map areas via `OfflineManager.shared.offlineMapInfos`.
/// - Remove offline map areas from the device.
/// - Run the jobs while the app is in background or even terminated.
/// - Get notified when the jobs complete via the `jobCompletionAction` closure in `offlineManager(preferredBackgroundStatusCheckSchedule:jobCompletionAction:)`.
///
/// **Behavior**
///
/// The offline manager is not instantiable, you must use the ``shared`` instance.
/// Set the `offlineManager(preferredBackgroundStatusCheckSchedule:jobCompletion:)`
/// modifier at the entry point of your application to add additional setup
/// required for the component to use the job manager. For example:
///
/// ```swift
/// @main
/// struct ExampleOfflineApp: App {
///     var body: some SwiftUI.Scene {
///         WindowGroup {
///             ContentView()
///         }
///         // Setup the offline toolkit components for the app.
///         .offlineManager(preferredBackgroundStatusCheckSchedule: .regularInterval(interval: 30)) { job in
///             // Do something after the job completes…
///         }
///     }
/// }
/// ```
///
/// > Note: The `OfflineManager` can be used independently of any UI components,
/// > making it suitable for automated workflows or custom implementations.
/// - Since: 200.7
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
    
    /// The portal item information for web maps that have downloaded map areas.
    @Published
    private(set) public var offlineMapInfos: [OfflineMapInfo] = []
    
    /// The available offline map view models.
    private var models: [Item.ID: OfflineMapViewModel] = [:]
    
    private init() {
        Logger.offlineManager.debug("Initializing OfflineManager")
        
        // Retrieve the offline map infos.
        loadOfflineMapInfos()
        
        // Observe each job's status.
        for job in jobManager.jobs {
            observeJob(job)
        }
        
        // Resume all paused jobs.
        let count = jobManager.jobs.filter { $0.status == .paused }
            .count
        Logger.offlineManager.debug("Resuming all paused jobs (\(count)).")
        jobManager.resumeAllPausedJobs()
    }
    
    /// Starts a job that will be managed by this instance.
    /// - Parameters:
    ///   - job: The job to start.
    ///   - portalItem: The portal item whose map is being taken offline.
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
            if let portalItem = onlineMapPortalItem(for: job), let id = portalItem.id {
                handlePendingMapInfo(for: result, portalItemID: id)
            }
        }
    }
    
    /// Figures out and returns the portal item associated with the online map for a particular
    /// offline job.
    private func onlineMapPortalItem<Job: JobProtocol>(for job: Job) -> PortalItem? {
        switch job {
        case let downloadPreplanned as DownloadPreplannedOfflineMapJob:
            downloadPreplanned.onlineMap?.item as? PortalItem
        case let generateOfflineMapJob as GenerateOfflineMapJob:
            generateOfflineMapJob.onlineMap?.item as? PortalItem
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
    
    /// Deletes map information from disk for a given portal item ID.
    /// This should be called when an online map no longer contains any offline
    /// map areas.
    /// - Parameter portalItemID: The portal item ID.
    func removeMapInfo(for portalItemID: Item.ID) {
        offlineMapInfos.removeAll(where: { $0.portalItemID == portalItemID })
        OfflineMapInfo.remove(from: URL.portalItemDirectory(forPortalItemID: portalItemID))
    }
    
    /// Loads offline map information from offline manager directory.
    private func loadOfflineMapInfos() {
        let url = URL.offlineManagerDirectory()
        var infos = [OfflineMapInfo]()
        defer { self.offlineMapInfos = infos }
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path()) else { return }
        for dir in contents {
            guard let info = OfflineMapInfo.make(from: url.appending(path: dir)) else { continue }
            infos.append(info)
        }
    }
    
    /// Saves the map info to the pending folder for a particular portal item.
    /// The info will stay in that folder until the job completes.
    private func savePendingMapInfo(for portalItem: PortalItem) async {
        guard let portalItemID = portalItem.id else { return }
        
        // First create directory for what we need to save to json
        let url = URL.pendingMapInfoDirectory(forPortalItem: portalItemID)
        
        // If already exists, return.
        // This check is helpful if two jobs are kicked off in a row that the second one
        // doesn't try to re-add the pending info.
        guard !OfflineMapInfo.doesInfoExists(at: url) else {
            Logger.offlineManager.debug("No need to save pending info as pending offline map info already exists.")
            return
        }
        
        // Create the info.
        guard let info = await OfflineMapInfo(portalItem: portalItem) else {
            Logger.offlineManager.debug("Cannot save pending info as offline info could not be created.")
            return
        }
        // Make sure the directory exists.
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        // Save the info to the pending directory.
        info.save(to: url)
    }
    
    /// For a successful job, this function moves the pending map info from the pending
    /// folder to its final destination.
    private func handlePendingMapInfo<Output>(
        for result: Result<Output, Error>,
        portalItemID: Item.ID
    ) {
        guard !offlineMapInfos.contains(where: { $0.portalItemID == portalItemID }) else { return }
        switch result {
        case .success:
            // Move the pending info into the correct folder.
            let pendingURL = URL.pendingMapInfoDirectory(forPortalItem: portalItemID)
            let portalItemDir = URL.portalItemDirectory(forPortalItemID: portalItemID)
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: pendingURL.path()) else { return }
            for file in contents {
                let source = pendingURL.appending(path: file)
                let dest = portalItemDir.appending(path: file)
                // Don't overwrite if file already exists.
                guard !FileManager.default.fileExists(atPath: dest.path()) else { continue }
                Logger.offlineManager.debug("Moving offline map info for completed job to \(dest.path())")
                do {
                    try FileManager.default.moveItem(atPath: source.path(), toPath: dest.path())
                } catch {
                    Logger.offlineManager.error("Error moving offline map info file \(file): \(error.localizedDescription)")
                }
                if let info = OfflineMapInfo.make(from: portalItemDir) {
                    offlineMapInfos.append(info)
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
                preplannedModel.removeDownloadedArea()
            }
        }
        for onDemandModel in model.onDemandMapModels {
            onDemandModel.removeDownloadedArea()
        }
        // Now remove any offline map areas whose model isn't in memory by simply deleting the
        // whole portal item directory. This will also delete the map info.
        let portalItemDirectory = URL.portalItemDirectory(forPortalItemID: offlineMapInfo.portalItemID)
        try FileManager.default.removeItem(at: portalItemDirectory)
        
        // Remove offline map info for this map.
        offlineMapInfos.removeAll { $0.portalItemID == offlineMapInfo.portalItemID }
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
