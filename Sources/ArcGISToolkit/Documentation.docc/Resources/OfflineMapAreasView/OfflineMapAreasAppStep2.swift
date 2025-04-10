import ArcGIS
import ArcGISToolkit
import SwiftUI

@main
struct OfflineMapAreasExampleApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            OfflineMapAreasExampleView()
        }
        // Setup the offline toolkit components.
        .offlineManager(preferredBackgroundStatusCheckSchedule: .regularInterval(interval: 30)) { job in
            // Post a local notification that the job is finished.
            Self.notifyJobCompleted(job: job)
        }
    }
}

extension OfflineMapAreasExampleApp {
    /// Posts a local notification that the job completed with success or failure.
    static func notifyJobCompleted(job: some JobProtocol) {
        guard
            job.status == .succeeded || job.status == .failed
        else { return }
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        
        let jobStatus = job.status == .succeeded ? "Succeeded" : "Failed"
        
        content.title = "Download \(jobStatus)"
        content.body = "An offline job has \(jobStatus.lowercased())."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
