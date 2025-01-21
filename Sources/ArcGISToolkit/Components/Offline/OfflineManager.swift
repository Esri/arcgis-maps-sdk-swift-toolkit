***REMOVED*** Copyright 2024 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import OSLog
***REMOVED***

***REMOVED***/ An object that maintains state for the offline components.
@MainActor
public class OfflineManager: ObservableObject {
***REMOVED******REMOVED***/ The shared offline manager.
***REMOVED***public static let shared = OfflineManager()
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when a job completes.
***REMOVED***var jobCompletionAction: ((any JobProtocol) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The job manager used by the offline manager.
***REMOVED***let jobManager = JobManager(uniqueID: "offlineManager")
***REMOVED***
***REMOVED******REMOVED***/ The jobs managed by this instance.
***REMOVED***var jobs: [any JobProtocol] { jobManager.jobs ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The portal item information for webmaps that have downloaded map areas.
***REMOVED***@Published
***REMOVED***private(set) public var offlineMapInfos: [OfflineMapInfo] = []
***REMOVED***
***REMOVED******REMOVED***/ The available offline map view models.
***REMOVED***private var models: [Item.ID: OfflineMapViewModel] = [:]
***REMOVED***
***REMOVED***private init() {
***REMOVED******REMOVED***Logger.offlineManager.debug("Initializing OfflineManager")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Retrieves the offline map infos.
***REMOVED******REMOVED***loadOfflineMapInfos()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Observe each job's status.
***REMOVED******REMOVED***for job in jobManager.jobs {
***REMOVED******REMOVED******REMOVED***observeJob(job)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Resume all paused jobs.
***REMOVED******REMOVED***Logger.offlineManager.debug("Resuming all paused jobs")
***REMOVED******REMOVED***jobManager.resumeAllPausedJobs()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Starts a job that will be managed by this instance.
***REMOVED******REMOVED***/ - Parameter job: The job to start.
***REMOVED***func start(job: any JobProtocol, portalItem: PortalItem) {
***REMOVED******REMOVED***Logger.offlineManager.debug("Starting Job from offline manager")
***REMOVED******REMOVED***jobManager.jobs.append(job)
***REMOVED******REMOVED***observeJob(job)
***REMOVED******REMOVED***job.start()
***REMOVED******REMOVED***Task.detached {
***REMOVED******REMOVED******REMOVED***await self.savePendingMapInfo(for: portalItem)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Observes a job for completion.
***REMOVED***private func observeJob<Job: JobProtocol>(_ job: Job) {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Observing job completion")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED******REMOVED***let result = await job.result
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Remove completed job from JobManager.
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Removing completed job from job manager")
***REMOVED******REMOVED******REMOVED***jobManager.jobs.removeAll { $0 === job ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** This isn't strictly required, but it helps to get the state saved as soon
***REMOVED******REMOVED******REMOVED******REMOVED*** as possible after removing a job instead of waiting for the app to be backgrounded.
***REMOVED******REMOVED******REMOVED***jobManager.saveState()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Call job completion action.
***REMOVED******REMOVED******REMOVED***jobCompletionAction?(job)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Check pending map infos.
***REMOVED******REMOVED******REMOVED***if let portalItem = onlineMapPortalItem(for: job), let id = portalItem.id {
***REMOVED******REMOVED******REMOVED******REMOVED***handlePendingMapInfo(for: result, portalItemID: id)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Figures out and returns the portal item associated with the online map for a particular
***REMOVED******REMOVED***/ offline job.
***REMOVED***private func onlineMapPortalItem<Job: JobProtocol>(for job: Job) -> PortalItem? {
***REMOVED******REMOVED***switch job {
***REMOVED******REMOVED***case let downloadPreplanned as DownloadPreplannedOfflineMapJob:
***REMOVED******REMOVED******REMOVED***downloadPreplanned.onlineMap?.item as? PortalItem
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Retrieves the model for a given online map.
***REMOVED******REMOVED***/ - Precondition: `onlineMap.item?.id` is not `nil`.
***REMOVED***func model(for onlineMap: Map) -> OfflineMapViewModel {
***REMOVED******REMOVED***precondition(onlineMap.item?.id != nil)
***REMOVED******REMOVED***return models[onlineMap.item!.id!, setDefault: .init(onlineMap: onlineMap)]
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Retrieves the model for a given `OfflineMapInfo`.
***REMOVED***private func model(for offlineMapInfo: OfflineMapInfo) -> OfflineMapViewModel {
***REMOVED******REMOVED***if let model = models[offlineMapInfo.portalItemID] {
***REMOVED******REMOVED******REMOVED***return model
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED*** Only create the map here if we don't already have the model in memory.
***REMOVED******REMOVED******REMOVED***let onlineMap = Map(item: PortalItem(url: offlineMapInfo.portalItemURL)!)
***REMOVED******REMOVED******REMOVED***return model(for: onlineMap)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes map information from disk for a given portal item ID.
***REMOVED******REMOVED***/ - Parameter portalItemID: The portal item ID.
***REMOVED***func removeMapInfo(for portalItemID: Item.ID) {
***REMOVED******REMOVED***offlineMapInfos.removeAll(where: { $0.portalItemID == portalItemID ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let dir = URL.portalItemDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED***try? FileManager.default.removeItem(at: dir.appending(path: "info.json"))
***REMOVED******REMOVED***try? FileManager.default.removeItem(at: dir.appending(path: "thumbnail.png"))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads offline map information from offline manager directory.
***REMOVED***private func loadOfflineMapInfos() {
***REMOVED******REMOVED***let url = URL.offlineManagerDirectory()
***REMOVED******REMOVED***var infos = [OfflineMapInfo]()
***REMOVED******REMOVED***defer { self.offlineMapInfos = infos ***REMOVED***
***REMOVED******REMOVED***guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path()) else { return ***REMOVED***
***REMOVED******REMOVED***for dir in contents {
***REMOVED******REMOVED******REMOVED***guard let info = makeOfflineMapInfo(url: url.appending(path: dir)) else { continue ***REMOVED***
***REMOVED******REMOVED******REMOVED***infos.append(info)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an offline map info for a given URL.
***REMOVED***private func makeOfflineMapInfo(url: URL) -> OfflineMapInfo? {
***REMOVED******REMOVED***let infoURL = url.appending(components: "info.json")
***REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: infoURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED***Logger.offlineManager.debug("Found offline map info at \(infoURL.path())")
***REMOVED******REMOVED***guard let data = try? Data(contentsOf: infoURL) else { return nil ***REMOVED***
***REMOVED******REMOVED***return try? JSONDecoder().decode(OfflineMapInfo.self, from: data)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Saves the map info to the pending folder for a particular portal item.
***REMOVED******REMOVED***/ The info will stay in that folder until the job completes.
***REMOVED***private func savePendingMapInfo(for portalItem: PortalItem) async {
***REMOVED******REMOVED***guard let portalItemID = portalItem.id,
***REMOVED******REMOVED******REMOVED***  !offlineMapInfos.contains(where: { $0.portalItemID == portalItemID ***REMOVED***),
***REMOVED******REMOVED******REMOVED***  let info = OfflineMapInfo(portalItem: portalItem)
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** First create directory for what we need to save to json
***REMOVED******REMOVED***let url = URL.pendingMapInfoDirectory(forPortalItem: portalItemID)
***REMOVED******REMOVED***let infoURL = url.appending(path: "info.json")
***REMOVED******REMOVED***
***REMOVED******REMOVED***Logger.offlineManager.debug("Saving pending offline map info to \(url.path())")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If already exists, return.
***REMOVED******REMOVED***let completedDir = URL.portalItemDirectory(forPortalItemID: portalItemID).appending(path: "info.json")
***REMOVED******REMOVED***guard !FileManager.default.fileExists(atPath: completedDir.path()) else {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Returning, info already exists in job completion directory: \(completedDir.path())")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard !FileManager.default.fileExists(atPath: infoURL.path()) else {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Returning, info already exists in pending directory: \(url.path())")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save json to file.
***REMOVED******REMOVED***if let data = try? JSONEncoder().encode(info) {
***REMOVED******REMOVED******REMOVED***try? data.write(to: infoURL, options: .atomic)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save thumbnail to file.
***REMOVED******REMOVED***if let thumbnail = portalItem.thumbnail {
***REMOVED******REMOVED******REMOVED***try? await thumbnail.load()
***REMOVED******REMOVED******REMOVED***if let image = thumbnail.image, let pngData = image.pngData() {
***REMOVED******REMOVED******REMOVED******REMOVED***let thumbnailURL = url.appending(path: "thumbnail.png")
***REMOVED******REMOVED******REMOVED******REMOVED***try? pngData.write(to: thumbnailURL, options: .atomic)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ For a successful job, this function moves the pending map info from the pending
***REMOVED******REMOVED***/ folder to its final destination.
***REMOVED***private func handlePendingMapInfo<Output>(
***REMOVED******REMOVED***for result: Result<Output, Error>,
***REMOVED******REMOVED***portalItemID: Item.ID) {
***REMOVED******REMOVED******REMOVED***guard !offlineMapInfos.contains(where: { $0.portalItemID == portalItemID ***REMOVED***) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Move the pending info into the correct folder.
***REMOVED******REMOVED******REMOVED******REMOVED***let pendingURL = URL.pendingMapInfoDirectory(forPortalItem: portalItemID)
***REMOVED******REMOVED******REMOVED******REMOVED***let portalItemDir = URL.portalItemDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED******REMOVED***guard let contents = try? FileManager.default.contentsOfDirectory(atPath: pendingURL.path()) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***for file in contents {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let source = pendingURL.appending(path: file)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let dest = portalItemDir.appending(path: file)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Don't overwrite if file already exists.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard !FileManager.default.fileExists(atPath: dest.path()) else { continue ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Moving offline map info for completed job to \(dest.path())")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try FileManager.default.moveItem(atPath: source.path(), toPath: dest.path())
***REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Logger.offlineManager.error("Error moving offline map info file \(file): \(error.localizedDescription)")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let info = makeOfflineMapInfo(url: portalItemDir) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapInfos.append(info)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If job failed then do nothing. Pending info can stay in the caches directory
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** as it is likely going to be used when then user tries again.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If not, the OS will eventually delete it.
***REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Removes all downloads for all offline maps.
***REMOVED***public func removeAllDownloads() throws {
***REMOVED******REMOVED***for offlineMapInfo in offlineMapInfos {
***REMOVED******REMOVED******REMOVED***try removeDownloads(for: offlineMapInfo)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Removes any downloaded map areas for a particular map.
***REMOVED******REMOVED***/ - Parameter offlineMapInfo: The information for the offline map for which all downloads will
***REMOVED******REMOVED***/ be removed.
***REMOVED***public func removeDownloads(for offlineMapInfo: OfflineMapInfo) throws {
***REMOVED******REMOVED***let model = model(for: offlineMapInfo)
***REMOVED******REMOVED******REMOVED*** Don't load the preplanned models, only iterate the ones we have in memory.
***REMOVED******REMOVED******REMOVED*** This allows any views depending on these models to update accordingly,
***REMOVED******REMOVED******REMOVED*** without going over the network to get the preplanned map models.
***REMOVED******REMOVED******REMOVED*** If there are more downloaded that aren't in memory, we will delete the directory
***REMOVED******REMOVED******REMOVED*** to take care of those.
***REMOVED******REMOVED***if case .success(let preplannedModels) = model.preplannedMapModels {
***REMOVED******REMOVED******REMOVED***for preplannedModel in preplannedModels {
***REMOVED******REMOVED******REMOVED******REMOVED***preplannedModel.removeDownloadedPreplannedMapArea()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Now remove any offline map areas whose model isn't in memory by simply deleting the
***REMOVED******REMOVED******REMOVED*** whole portal item directory. This will also delete the map info.
***REMOVED******REMOVED***let portalItemDirectory = URL.portalItemDirectory(forPortalItemID: offlineMapInfo.portalItemID)
***REMOVED******REMOVED***try FileManager.default.removeItem(at: portalItemDirectory)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Remove offline map info for this map.
***REMOVED******REMOVED***offlineMapInfos.removeAll { $0.portalItemID == offlineMapInfo.portalItemID ***REMOVED***
***REMOVED***
***REMOVED***

public extension SwiftUI.Scene {
***REMOVED******REMOVED***/ Sets up the offline manager for offline toolkit components.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - preferredBackgroundStatusCheckSchedule: The preferred background status check schedule. See ``JobManager/preferredBackgroundStatusCheckSchedule`` for more details.
***REMOVED******REMOVED***/   - jobCompletion: An action to perform when a job completes.
***REMOVED***@MainActor
***REMOVED***func offlineManager(
***REMOVED******REMOVED***preferredBackgroundStatusCheckSchedule: BackgroundStatusCheckSchedule,
***REMOVED******REMOVED***jobCompletion jobCompletionAction: ((any JobProtocol) -> Void)? = nil
***REMOVED***) -> some SwiftUI.Scene {
***REMOVED******REMOVED***Logger.offlineManager.debug("Executing OfflineManager SwiftUI.Scene modifier")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set the background status check schedule.
***REMOVED******REMOVED***OfflineManager.shared.jobManager.preferredBackgroundStatusCheckSchedule = preferredBackgroundStatusCheckSchedule
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set callback for job completion.
***REMOVED******REMOVED***OfflineManager.shared.jobCompletionAction = jobCompletionAction
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Support app-relaunch after background downloads.
***REMOVED******REMOVED***return self.backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Executing OfflineManager backgroundTask")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Allow the `ArcGISURLSession` to handle its background task events.
***REMOVED******REMOVED******REMOVED***await ArcGISEnvironment.backgroundURLSession.handleEventsForBackgroundTask()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** When the app is re-launched from a background url session, resume any paused jobs,
***REMOVED******REMOVED******REMOVED******REMOVED*** and check the job status.
***REMOVED******REMOVED******REMOVED***await OfflineManager.shared.jobManager.resumeAllPausedJobs()
***REMOVED***
***REMOVED***
***REMOVED***

extension Logger {
***REMOVED******REMOVED***/ A logger for the offline manager.
***REMOVED***static var offlineManager: Logger {
***REMOVED******REMOVED***if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_OFFLINE_MANAGER") {
***REMOVED******REMOVED******REMOVED***Logger(subsystem: "com.esri.ArcGISToolkit", category: "OfflineManager")
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***.init(.disabled)
***REMOVED***
***REMOVED***
***REMOVED***

public struct OfflineMapInfo: Codable {
***REMOVED***private var portalItemIDRawValue: String
***REMOVED***public var title: String
***REMOVED***public var description: String
***REMOVED***public var portalItemURL: URL
***REMOVED***
***REMOVED***internal init?(portalItem: PortalItem) {
***REMOVED******REMOVED***guard let idRawValue = portalItem.id?.rawValue,
***REMOVED******REMOVED******REMOVED***  let url = portalItem.url
***REMOVED******REMOVED***else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.portalItemIDRawValue = idRawValue
***REMOVED******REMOVED***self.title = portalItem.title
***REMOVED******REMOVED***self.description = portalItem.description.replacing(/<[^>]+>/, with: "")
***REMOVED******REMOVED***self.portalItemURL = url
***REMOVED***
***REMOVED***

public extension OfflineMapInfo {
***REMOVED***var portalItemID: Item.ID {
***REMOVED******REMOVED***.init(portalItemIDRawValue)!
***REMOVED***
***REMOVED***

private extension Dictionary {
***REMOVED******REMOVED***/ Returns the value for the key, and if the value is nil it first stores
***REMOVED******REMOVED***/ the default value in the dictionary then returns the default value.
***REMOVED***subscript(key: Key, setDefault defaultValue: @autoclosure () -> Value) -> Value {
***REMOVED******REMOVED***mutating get {
***REMOVED******REMOVED******REMOVED***return self[key] ?? {
***REMOVED******REMOVED******REMOVED******REMOVED***let value = defaultValue()
***REMOVED******REMOVED******REMOVED******REMOVED***self[key] = value
***REMOVED******REMOVED******REMOVED******REMOVED***return value
***REMOVED******REMOVED***()
***REMOVED***
***REMOVED***
***REMOVED***
