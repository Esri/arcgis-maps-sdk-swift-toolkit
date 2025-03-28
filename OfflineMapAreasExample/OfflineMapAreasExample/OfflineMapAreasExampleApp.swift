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
***REMOVED***Toolkit
***REMOVED***

***REMOVED***
struct OfflineMapAreasExampleApp: App {
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***OfflineMapAreasExampleView()
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Apply the `.offlineManager(referredBackgroundStatusCheckSchedule:jobCompletionAction:)` scene modifier
***REMOVED******REMOVED******REMOVED*** at the entry point of the application to setup background download support for the offline component.
***REMOVED******REMOVED******REMOVED*** Use of this scene modifier is required for the offline component to complete map area download jobs when
***REMOVED******REMOVED******REMOVED*** the app is backgrounded.
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set the `preferredBackgroundStatusCheckSchedule` to `.regularInterval(interval: 30)` to check the status
***REMOVED******REMOVED******REMOVED*** of the download job in the background every 30 seconds. Use the `jobCompletionAction` closure to send
***REMOVED******REMOVED******REMOVED*** a notification once a download job completes.
***REMOVED******REMOVED***.offlineManager(preferredBackgroundStatusCheckSchedule: .regularInterval(interval: 30)) { job in
***REMOVED******REMOVED******REMOVED******REMOVED*** Post a local notification that the job is finished.
***REMOVED******REMOVED******REMOVED***Self.notifyJobCompleted(job: job)
***REMOVED***
***REMOVED***
***REMOVED***

extension OfflineMapAreasExampleApp {
***REMOVED******REMOVED***/ Posts a local notification that the job completed with success or failure.
***REMOVED***static func notifyJobCompleted(job: any JobProtocol) {
***REMOVED******REMOVED***guard
***REMOVED******REMOVED******REMOVED***job.status == .succeeded || job.status == .failed
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let content = UNMutableNotificationContent()
***REMOVED******REMOVED***content.sound = UNNotificationSound.default
***REMOVED******REMOVED***
***REMOVED******REMOVED***let jobStatus = job.status == .succeeded ? "Succeeded" : "Failed"
***REMOVED******REMOVED***
***REMOVED******REMOVED***content.title = "Download \(jobStatus)"
***REMOVED******REMOVED***content.body = "An offline job has \(jobStatus.lowercased())."
***REMOVED******REMOVED***
***REMOVED******REMOVED***let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
***REMOVED******REMOVED***let identifier = UUID().uuidString
***REMOVED******REMOVED***let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
***REMOVED******REMOVED***
***REMOVED******REMOVED***UNUserNotificationCenter.current().add(request)
***REMOVED***
***REMOVED***
