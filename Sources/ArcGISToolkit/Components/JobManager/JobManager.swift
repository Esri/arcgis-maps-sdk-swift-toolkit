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

public enum BackgroundStatusCheckSchedule {
***REMOVED***case disabled
***REMOVED***case regularInterval(interval: TimeInterval)
***REMOVED***

***REMOVED***/ An object that manages saving jobs when the app is backgrounded and can reload them later.
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
***REMOVED******REMOVED***let notificationCenter = NotificationCenter.default
***REMOVED******REMOVED***notificationCenter.addObserver(self, selector: #selector(appMovingToBackground), name: UIApplication.willResignActiveNotification, object: nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED***BGTaskScheduler.shared.register(forTaskWithIdentifier: statusChecksTaskIdentifier, using: nil) { task in
***REMOVED******REMOVED******REMOVED******REMOVED*** Reset flag because once the task is launched, we need to reschedule if we want to do
***REMOVED******REMOVED******REMOVED******REMOVED*** another background task.
***REMOVED******REMOVED******REMOVED***self.isBackgroundStatusChecksScheduled = false
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***print("-- performing status checks")
***REMOVED******REMOVED******REMOVED******REMOVED***await self.performStatusChecks()
***REMOVED******REMOVED******REMOVED******REMOVED***print("-- completed")
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
***REMOVED******REMOVED******REMOVED***print("Background task scheduled.")
***REMOVED*** catch(let error) {
***REMOVED******REMOVED******REMOVED***print("Background task scheduling error \(error.localizedDescription)")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if there are jobs running.
***REMOVED***private var hasRunningJobs: Bool {
***REMOVED******REMOVED***!jobs.filter({ $0.status == .started ***REMOVED***).isEmpty
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Called when the app moves to the background.
***REMOVED***@objc private func appMovingToBackground() {
***REMOVED******REMOVED******REMOVED*** Schedule background status checks.
***REMOVED******REMOVED***scheduleBackgroundStatusCheck()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save the jobs to the user defaults when the app moves to the background.
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
***REMOVED******REMOVED***/ Saves all managed jobs to User Defaults.
***REMOVED***private func saveState() {
***REMOVED******REMOVED***let array = jobs.map { $0.toJSON() ***REMOVED***
***REMOVED******REMOVED***UserDefaults.standard.setValue(array, forKey: defaultsKey)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Load any jobs that have been saved to User Defaults.
***REMOVED***private func loadState() {
***REMOVED******REMOVED***guard let strings = UserDefaults.standard.array(forKey: defaultsKey) as? [String] else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***jobs = strings.compactMap {
***REMOVED******REMOVED******REMOVED***try? Job.fromJSON($0) as? any JobProtocol
***REMOVED***
***REMOVED***
***REMOVED***
