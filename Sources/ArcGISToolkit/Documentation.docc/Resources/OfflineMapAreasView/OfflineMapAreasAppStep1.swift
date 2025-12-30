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
        }
    }
}
