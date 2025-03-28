***REMOVED***
***REMOVED***Toolkit
***REMOVED***

***REMOVED***
struct OfflineMapAreasExampleApp: App {
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
