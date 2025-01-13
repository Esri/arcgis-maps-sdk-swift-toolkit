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
***REMOVED******REMOVED***/ The webmap portal items that have downloaded map areas.
***REMOVED***@Published
***REMOVED***private(set) public var offlineMaps: [PortalItem] = []
***REMOVED***
***REMOVED******REMOVED***/ The key for which offline maps will be serialized under the user defaults.
***REMOVED***let defaultsKey = "com.esri.ArcGISToolkit.offlineManager.offlineMaps"
***REMOVED***
***REMOVED***private init() {
***REMOVED******REMOVED***Logger.offlineManager.debug("Initializing OfflineManager")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Observe each job's status.
***REMOVED******REMOVED***for job in jobManager.jobs {
***REMOVED******REMOVED******REMOVED***observeJob(job)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Resume all paused jobs.
***REMOVED******REMOVED***Logger.offlineManager.debug("Resuming all paused jobs")
***REMOVED******REMOVED***jobManager.resumeAllPausedJobs()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Loads webmap portal items from UserDefaults.
***REMOVED******REMOVED***loadFromDefaults()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Starts a job that will be managed by this instance.
***REMOVED******REMOVED***/ - Parameter job: The job to start.
***REMOVED***func start(job: any JobProtocol) {
***REMOVED******REMOVED***Logger.offlineManager.debug("Starting Job from offline manager")
***REMOVED******REMOVED***jobManager.jobs.append(job)
***REMOVED******REMOVED***observeJob(job)
***REMOVED******REMOVED***job.start()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Observes a job for completion.
***REMOVED***private func observeJob(_ job: any JobProtocol) {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Observing job completion")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Wait for job to finish.
***REMOVED******REMOVED******REMOVED***_ = try? await job.output
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
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Saves the portal item to UserDefaults.
***REMOVED******REMOVED***/ - Parameter item: The portal item.
***REMOVED***func savePortalItem(_ item: PortalItem) {
***REMOVED******REMOVED***var savedMapIDs = UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let portalItemID = item.id?.description,
***REMOVED******REMOVED******REMOVED***  !savedMapIDs.contains(portalItemID) else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***savedMapIDs.append(portalItemID)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save portal item ID.
***REMOVED******REMOVED***UserDefaults.standard.set(savedMapIDs, forKey: defaultsKey)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let itemJSON = item.toJSON()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save portal item JSON.
***REMOVED******REMOVED***UserDefaults.standard.set(itemJSON, forKey: portalItemID)
***REMOVED******REMOVED***
***REMOVED******REMOVED***offlineMaps.append(item)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes a given portal item from UserDefaults.
***REMOVED******REMOVED***/ - Parameter item: The portal item.
***REMOVED***func deletePortalItem(_ item: PortalItem) {
***REMOVED******REMOVED***guard let portalItemID = item.id?.description else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***UserDefaults.standard.removeObject(forKey: portalItemID)
***REMOVED******REMOVED***
***REMOVED******REMOVED***offlineMaps.removeAll(where: { $0.id?.description == portalItemID ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var savedMapIDs = UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
***REMOVED******REMOVED***
***REMOVED******REMOVED***savedMapIDs.removeAll(where: { $0 == portalItemID ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***UserDefaults.standard.set(savedMapIDs, forKey: defaultsKey)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads webmap portal items that have been saved to UserDefaults.
***REMOVED***private func loadFromDefaults() {
***REMOVED******REMOVED***let savedMapIDs = UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
***REMOVED******REMOVED***
***REMOVED******REMOVED***offlineMaps = savedMapIDs
***REMOVED******REMOVED******REMOVED***.flatMap {
***REMOVED******REMOVED******REMOVED******REMOVED***UserDefaults.standard.string(forKey: $0) ***REMOVED*** Portal item JSON string for webmap ID.
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.flatMap {
***REMOVED******REMOVED******REMOVED******REMOVED***return PortalItem(json: $0, portal: .arcGISOnline(connection: .anonymous))
***REMOVED******REMOVED***
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
