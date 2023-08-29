***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import Foundation
***REMOVED***
***REMOVED***
import BackgroundTasks
import OSLog

***REMOVED***/ An enum that defines a schedule for background status checks.
public enum BackgroundStatusCheckSchedule {
***REMOVED******REMOVED***/ No background status checks will be requested.
***REMOVED***case disabled
***REMOVED******REMOVED***/ Requests that the system schedule a background check at a regular interval.
***REMOVED******REMOVED***/ Ultimately it is up to the discretion of the system if that check is run.
***REMOVED***case regularInterval(interval: TimeInterval)
***REMOVED***

extension Logger {
***REMOVED******REMOVED***/ A logger for the job manager.
***REMOVED******REMOVED***/ To enable logging add an environment variable named "LOGGING_FOR_JOB_MANAGER".
***REMOVED***static let jobManager: Logger = {
***REMOVED******REMOVED***let logger: Logger
***REMOVED******REMOVED***if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_JOB_MANAGER") {
***REMOVED******REMOVED******REMOVED***logger = Logger(subsystem: "com.esri.ArcGISToolkit", category: "JobManager")
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***logger = Logger(OSLog.disabled)
***REMOVED***
***REMOVED******REMOVED***return logger
***REMOVED***()
***REMOVED***

***REMOVED***/ An object that manages saving and loading jobs so that they can continue to run if the
***REMOVED***/ app is backgrounded or even terminated.
***REMOVED***/ There are 4 situations that the job manager helps with:
***REMOVED***/ 1. The job manager will serialize jobs to the user defaults when an app is backgrounded
***REMOVED***/ or terminated and then deserialize those jobs whenever an app is launched.
***REMOVED***/ 2. The job manager will ask the system for some background processing time when an app
***REMOVED***/ is backgrounded so that jobs that are not yet started on the server, can have some time to
***REMOVED***/ allow them to start. This means if you kick off a job and it hasn't actually started on the server
***REMOVED***/ when the app is backgrounded, the job should have enough time to start on the server which
***REMOVED***/ will cause it to enter into a polling state. When the job is in the polling state it checks
***REMOVED***/ the status of the server job every so often.
***REMOVED***/ 3. The job manager will request from the system a background refresh task (if enabled via
***REMOVED***/ the ``JobManager/preferredBackgroundStatusCheckSchedule`` property). This will happen
***REMOVED***/ when the app is backgrounded. If the system later executes the background refresh task then the
***REMOVED***/ job manager will check the status of any running jobs. At that point the jobs may start
***REMOVED***/ downloading their result.
***REMOVED***/ 4. By default, Jobs will download their results with background URL session. This means that the
***REMOVED***/ download can execute out of process, even if the app is terminated. If the app is terminated and
***REMOVED***/ then later relaunched by the system because a background downloaded completed, then you may
***REMOVED***/ call the ``JobManager/resumeAllPausedJobs()`` method from the application relaunch point,
***REMOVED***/ which will correllate the jobs to their respective downloads that completed and the jobs will
***REMOVED***/ then finish.
@MainActor
public class JobManager: ObservableObject {
***REMOVED******REMOVED***/ The shared job manager.
***REMOVED***public static let `shared` = JobManager()
***REMOVED***
***REMOVED******REMOVED***/ The jobs being managed by the job manager.
***REMOVED***@Published
***REMOVED***public var jobs: [any JobProtocol] = []
***REMOVED***
***REMOVED******REMOVED***/ The key for which state will be serialized under the user defaults.
***REMOVED***private var defaultsKey: String {
***REMOVED******REMOVED***return "com.esri.ArcGISToolkit.jobManager.jobs"
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The preferred schedule for performing status checks while the application is in the
***REMOVED******REMOVED***/ background. This allows an application to check to see if jobs have completed and optionally
***REMOVED******REMOVED***/ post a local notification to update the user. The default value is `disabled`.
***REMOVED******REMOVED***/ When the value of this property is not `disabled`, this setting is just a preference.
***REMOVED******REMOVED***/ The operating system ultimately decides when to allow a background task to run.
***REMOVED******REMOVED***/ If you enable background status checks then you must also make sure to have enabled
***REMOVED******REMOVED***/ "Background Fetch" and "Background Processing" background modes in your application settings.
***REMOVED******REMOVED***/ You must also add "com.esri.ArcGISToolkit.jobManager.statusCheck" to the "Permitted background task scheduler identifiers"
***REMOVED******REMOVED***/ in your application's plist file.
***REMOVED******REMOVED***/ More information can be found here: https:***REMOVED***developer.apple.com/documentation/backgroundtasks/refreshing_and_maintaining_your_app_using_background_tasks
***REMOVED***public var preferredBackgroundStatusCheckSchedule: BackgroundStatusCheckSchedule = .disabled
***REMOVED***
***REMOVED******REMOVED***/ The background task identifier for status checks.
***REMOVED***private let statusChecksTaskIdentifier = "com.esri.ArcGISToolkit.jobManager.statusCheck"
***REMOVED***
***REMOVED******REMOVED*** A Boolean value indicating whether a background status check is scheduled.
***REMOVED***private var isBackgroundStatusChecksScheduled = false
***REMOVED***
***REMOVED******REMOVED***/ An initializer for the job manager.
***REMOVED***private init() {
***REMOVED******REMOVED***NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
***REMOVED******REMOVED***NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
***REMOVED******REMOVED***NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED***BGTaskScheduler.shared.register(forTaskWithIdentifier: statusChecksTaskIdentifier, using: nil) { task in
***REMOVED******REMOVED******REMOVED******REMOVED*** Reset flag because once the task is launched, we need to reschedule if we want to do
***REMOVED******REMOVED******REMOVED******REMOVED*** another background task.
***REMOVED******REMOVED******REMOVED***self.isBackgroundStatusChecksScheduled = false
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***Logger.jobManager.debug("Performing status checks.")
***REMOVED******REMOVED******REMOVED******REMOVED***await self.performStatusChecks()
***REMOVED******REMOVED******REMOVED******REMOVED***Logger.jobManager.debug("Status checks completed.")
***REMOVED******REMOVED******REMOVED******REMOVED***self.scheduleBackgroundStatusCheck()
***REMOVED******REMOVED******REMOVED******REMOVED***task.setTaskCompleted(success: true)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Load jobs from the saved state.
***REMOVED******REMOVED***loadState()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Schedules a status check in the background if one is not already scheduled.
***REMOVED***private func scheduleBackgroundStatusCheck() {
***REMOVED******REMOVED******REMOVED*** Return if already scheduled.
***REMOVED******REMOVED***guard !isBackgroundStatusChecksScheduled else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Do not schedule if there are no running jobs.
***REMOVED******REMOVED***guard hasRunningJobs else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure the preferred background status check schedule
***REMOVED******REMOVED***guard case .regularInterval(let timeInterval) = preferredBackgroundStatusCheckSchedule else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***isBackgroundStatusChecksScheduled = true
***REMOVED******REMOVED***
***REMOVED******REMOVED***let request = BGAppRefreshTaskRequest(identifier: statusChecksTaskIdentifier)
***REMOVED******REMOVED***request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: Int(timeInterval), to: .now)
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try BGTaskScheduler.shared.submit(request)
***REMOVED******REMOVED******REMOVED***Logger.jobManager.debug("Background task scheduled.")
***REMOVED*** catch(let error) {
***REMOVED******REMOVED******REMOVED***Logger.jobManager.error("Background task scheduling error \(error.localizedDescription)")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if there are jobs running.
***REMOVED***private var hasRunningJobs: Bool {
***REMOVED******REMOVED***!jobs.filter({ $0.status == .started ***REMOVED***).isEmpty
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Called when the app moves back to the foreground.
***REMOVED***@objc private func appWillEnterForeground() {
***REMOVED******REMOVED******REMOVED*** End any current background task.
***REMOVED******REMOVED***endCurrentBackgroundTask()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Called when the app moves to the background.
***REMOVED***@objc private func appWillResignActive() {
***REMOVED******REMOVED******REMOVED*** Start a background task if necessary.
***REMOVED******REMOVED***beginBackgroundTask()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Schedule background status checks.
***REMOVED******REMOVED***scheduleBackgroundStatusCheck()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save the jobs to the user defaults when the app moves to the background.
***REMOVED******REMOVED***saveState()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Called when the app will be terminated.
***REMOVED***@objc private func appWillTerminate() {
***REMOVED******REMOVED***Logger.jobManager.debug("App will terminate.")
***REMOVED******REMOVED******REMOVED*** Save the jobs to the user defaults when the app will be terminated to save the latest state.
***REMOVED******REMOVED***saveState()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Check the status of all managed jobs.
***REMOVED***public func performStatusChecks() async {
***REMOVED******REMOVED***await withTaskGroup(of: Void.self) { group in
***REMOVED******REMOVED******REMOVED***for job in jobs {
***REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await job.checkStatus()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Resumes all paused jobs.
***REMOVED***public func resumeAllPausedJobs() {
***REMOVED******REMOVED******REMOVED*** Make sure the default background URL session is re-created here
***REMOVED******REMOVED******REMOVED*** in case this method is called from an app relaunch due to background downloads
***REMOVED******REMOVED******REMOVED*** completed for a terminated app. We need the session to be re-created in that case.
***REMOVED******REMOVED***_ = ArcGISEnvironment.backgroundURLSession
***REMOVED******REMOVED***
***REMOVED******REMOVED***jobs.filter { $0.status == .paused ***REMOVED***
***REMOVED******REMOVED******REMOVED***.forEach { $0.start() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Saves all managed jobs to User Defaults.
***REMOVED***public func saveState() {
***REMOVED******REMOVED***Logger.jobManager.debug("Saving state.")
***REMOVED******REMOVED***let array = jobs.map { $0.toJSON() ***REMOVED***
***REMOVED******REMOVED***UserDefaults.standard.setValue(array, forKey: defaultsKey)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Load any jobs that have been saved to User Defaults.
***REMOVED***private func loadState() {
***REMOVED******REMOVED***Logger.jobManager.debug("Loading state.")
***REMOVED******REMOVED***guard let strings = UserDefaults.standard.array(forKey: defaultsKey) as? [String] else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***jobs = strings.compactMap {
***REMOVED******REMOVED******REMOVED***try? Job.fromJSON($0) as? any JobProtocol
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current background task identifier.
***REMOVED***var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
***REMOVED***
***REMOVED******REMOVED***/ Ends any current background task.
***REMOVED***private func endCurrentBackgroundTask() {
***REMOVED******REMOVED***guard let backgroundTaskIdentifier else {
***REMOVED******REMOVED******REMOVED***Logger.jobManager.debug("No current background task to end.")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***Logger.jobManager.debug("Ending current background task.")
***REMOVED******REMOVED***UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
***REMOVED******REMOVED***self.backgroundTaskIdentifier = nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Starts a background task for extended time in the background if we have jobs that are
***REMOVED******REMOVED***/ started but have yet to begin polling.
***REMOVED***private func beginBackgroundTask() {
***REMOVED******REMOVED******REMOVED*** Jobs that are started but do not yet have a server job ID are jobs that
***REMOVED******REMOVED******REMOVED*** can benefit from starting a background task for extra execution time.
***REMOVED******REMOVED******REMOVED*** This will hopefully allow a job to get to the polling state before the app is suspended.
***REMOVED******REMOVED******REMOVED*** Once in a polling state that's where background refreshes can check job status.
***REMOVED******REMOVED***if !jobs.contains(where: ({ $0.status == .started && $0.serverJobID.isEmpty ***REMOVED***)) {
***REMOVED******REMOVED******REMOVED***Logger.jobManager.debug("No jobs that require starting a background task.")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Already started.
***REMOVED******REMOVED***guard backgroundTaskIdentifier == nil else {
***REMOVED******REMOVED******REMOVED***Logger.jobManager.debug("Background task already started.")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Logger.jobManager.debug("Starting a background task.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let identifier = UIApplication.shared.beginBackgroundTask() {
***REMOVED******REMOVED******REMOVED***Logger.jobManager.debug("Out of background processesing time.")
***REMOVED******REMOVED******REMOVED***self.endCurrentBackgroundTask()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.backgroundTaskIdentifier = identifier
***REMOVED***
***REMOVED***
