***REMOVED*** Copyright 2023 Esri
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
import BackgroundTasks
import Combine
import Foundation
import OSLog
import UIKit

***REMOVED***/ An object that manages saving and loading jobs so that they can continue to run if the
***REMOVED***/ app is backgrounded or even terminated.
***REMOVED***/
***REMOVED***/ The job manager is not instantiable, you must use the ``shared`` instance.
***REMOVED***/
***REMOVED***/ **Background**
***REMOVED***/
***REMOVED***/ Jobs are long running server operations. When a job instance is started on the client,
***REMOVED***/ it makes a request to a service asking it to start work on the server. At that point, the client
***REMOVED***/ polls the server intermittently to check the status of the work. Once the work is completed
***REMOVED***/ the result is downloaded with a background `URLSession`. This allows the download to
***REMOVED***/ complete out of process, and the download task can relaunch the app upon completion, even
***REMOVED***/ in the case where the app was terminated.
***REMOVED***/
***REMOVED***/ We do not expect users to keep an application in the foreground and wait for a job to complete.
***REMOVED***/ Once the job is started, if the app is backgrounded, we can use an app refresh
***REMOVED***/ background task to check the status of the work on the server. If the server work is complete
***REMOVED***/ we can start downloading the result in the background at that point. If the work on the server
***REMOVED***/ is not complete, we can reschedule another background app refresh to recheck status.
***REMOVED***/
***REMOVED***/ There is some iOS behavior to be aware of as well. In iOS, if an application is backgrounded,
***REMOVED***/ the operating system can terminate the app at its discretion. This means that jobs need to be
***REMOVED***/ serialized when an app is backgrounded so that if the app is terminated the jobs can be
***REMOVED***/ rehydrated upon relaunch of the app.
***REMOVED***/
***REMOVED***/ Also, in iOS, if the user of an app removes the app from the multitasking UI (aka force quits it),
***REMOVED***/ the system interprets this as a strong indication that the app should
***REMOVED***/ do no more work in the background. The consequences of this are two-fold for jobs.
***REMOVED***/ One, any background fetch tasks are not given any time until the app is relaunched again.
***REMOVED***/ And two, any background downloads that are in progress are canceled by the operating system.
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ The job manager is an `ObservableObject` with a mutable ``jobs`` property. Adding a job to this
***REMOVED***/ property will allow the job manager to do the work to make sure that we can rehydrate a job
***REMOVED***/ if an app is terminated.
***REMOVED***/
***REMOVED***/ As such, the job manager will:
***REMOVED***/
***REMOVED***/  - Serialize the job to the user defaults when the app is backgrounded
***REMOVED***/  - Deserialize the job when an application is relaunched
***REMOVED***/
***REMOVED***/ The job manager will help with the lifetime of jobs in other ways as well.
***REMOVED***/
***REMOVED***/ The job manager will ask the system for some background processing time when an app
***REMOVED***/ is backgrounded so that jobs that are not yet started on the server, can have some time to
***REMOVED***/ allow them to start. This means if you kick off a job and it hasn't actually started on the server
***REMOVED***/ when the app is backgrounded, the job should have enough time to start on the server which
***REMOVED***/ will cause it to enter into a polling state. When the job reaches the polling state the
***REMOVED***/ status of the work on the server can be checked intermittently.
***REMOVED***/
***REMOVED***/ To enable polling while an app is backgrounded, the job manager will request from the system a
***REMOVED***/ background refresh task (if enabled via the ``JobManager/preferredBackgroundStatusCheckSchedule``
***REMOVED***/ property). If the system later executes the background refresh task then the
***REMOVED***/ job manager will check the status of any running jobs. At that point the jobs may start
***REMOVED***/ downloading their result. Note, this does not work on the simulator, this behavior can only
***REMOVED***/ be tested on an actual device.
***REMOVED***/
***REMOVED***/ Now that the job can check status in the background, it can start downloading in the background.
***REMOVED***/ By default, jobs will download their results with background URL session. This means that the
***REMOVED***/ download can execute out of process, even if the app is terminated. If the app is terminated and
***REMOVED***/ then later relaunched by the system because a background downloaded completed, then you may
***REMOVED***/ call the ``JobManager/resumeAllPausedJobs()`` method from the application relaunch point,
***REMOVED***/ which will correlate the jobs to their respective downloads that completed and the jobs will
***REMOVED***/ then finish. The app relaunch point can happen via the SwiftUI modifier `.backgroundTask(.urlSession(...))`.
***REMOVED***/ In UIKit it would be the `UIApplicationDelegate` method `func application(UIApplication, handleEventsForBackgroundURLSession: String, completionHandler: () -> Void)`
***REMOVED***/ - Since: 200.3
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
***REMOVED******REMOVED***/ the "Background fetch" background mode in your application settings.
***REMOVED******REMOVED***/ - Note: You must also add "com.esri.ArcGISToolkit.jobManager.statusCheck" to the "Permitted
***REMOVED******REMOVED***/ background task scheduler identifiers" in your application's plist file. This only works on
***REMOVED******REMOVED***/ device and not on the simulator.
***REMOVED******REMOVED***/ More information can be found [here](https:***REMOVED***developer.apple.com/documentation/backgroundtasks/refreshing_and_maintaining_your_app_using_background_tasks).
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
***REMOVED******REMOVED***jobs.contains { $0.status == .started ***REMOVED***
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
***REMOVED******REMOVED******REMOVED*** Make sure the default background URLSession is re-created here
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
***REMOVED******REMOVED***/ Load any jobs that have been saved to UserDefaults.
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
***REMOVED******REMOVED******REMOVED***Logger.jobManager.debug("Out of background processing time.")
***REMOVED******REMOVED******REMOVED***self.endCurrentBackgroundTask()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.backgroundTaskIdentifier = identifier
***REMOVED***
***REMOVED***

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
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ To enable logging add an environment variable named "LOGGING_FOR_JOB_MANAGER" under Scheme
***REMOVED******REMOVED***/ -> Arguments -> Environment Variables
***REMOVED***static let jobManager: Logger = {
***REMOVED******REMOVED***if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_JOB_MANAGER") {
***REMOVED******REMOVED******REMOVED***return Logger(subsystem: "com.esri.ArcGISToolkit", category: "JobManager")
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return Logger(OSLog.disabled)
***REMOVED***
***REMOVED***()
***REMOVED***
