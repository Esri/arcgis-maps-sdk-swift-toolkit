import ArcGIS
import ArcGISToolkit
import SwiftUI

@main
struct OfflineMapAreasExampleApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            OfflineMapAreasExampleView()
        }
        // Setup the offline manager.
        .offlineManager { offlineManager in
            // Prefer to check the status of jobs in the background every 30 seconds.
            offlineManager.preferredBackgroundStatusCheckSchedule = .regularInterval(interval: 30)
            
            // If iOS 26 is available then setup the offline manager to utilize
            // `BGContinuedProcessingTask`.
            if #available(iOS 26.0, *) {
                offlineManager.useBGContinuedProcessingTasks = true
            }
            
            // Use the `onJobCompletion` closure to send a notification once a download job completes.
            offlineManager.onJobCompletion = {
                Self.notifyJobCompleted(job: $0)
            }
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
