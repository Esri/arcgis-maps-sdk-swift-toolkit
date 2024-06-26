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
***REMOVED***@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***OfflineMapAreasExampleView()
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Setup the offline toolkit components.
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
***REMOVED******REMOVED******REMOVED***job.status == .succeeded || job.status == .failed,
***REMOVED******REMOVED******REMOVED***let job = job as? DownloadPreplannedOfflineMapJob,
***REMOVED******REMOVED******REMOVED***let preplannedMapArea = job.parameters.preplannedMapArea,
***REMOVED******REMOVED******REMOVED***let id = preplannedMapArea.portalItem.id
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let content = UNMutableNotificationContent()
***REMOVED******REMOVED***content.sound = UNNotificationSound.default
***REMOVED******REMOVED***
***REMOVED******REMOVED***let jobStatus = job.status == .succeeded ? "Succeeded" : "Failed"
***REMOVED******REMOVED***
***REMOVED******REMOVED***content.title = "Download \(jobStatus)"
***REMOVED******REMOVED***content.body = "The job for \(preplannedMapArea.portalItem.title) has \(jobStatus.lowercased())."
***REMOVED******REMOVED***
***REMOVED******REMOVED***let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
***REMOVED******REMOVED***let identifier = id.rawValue
***REMOVED******REMOVED***let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
***REMOVED******REMOVED***
***REMOVED******REMOVED***UNUserNotificationCenter.current().add(request)
***REMOVED***
***REMOVED***
