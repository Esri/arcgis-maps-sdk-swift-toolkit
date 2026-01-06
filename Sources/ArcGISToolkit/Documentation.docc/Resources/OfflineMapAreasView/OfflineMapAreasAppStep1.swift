import ArcGIS
import ArcGISToolkit
import SwiftUI

@main
struct OfflineMapAreasExampleApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            OfflineMapAreasExampleView()
        }
        // Setup the offline manager with a configuration.
        // The configuration will specify to prefer to check the status of jobs
        // in the background every 30 seconds.
        .offlineManager(
            configuration:
                OfflineManagerConfiguration(
                    preferredBackgroundStatusCheckSchedule: .regularInterval(interval: 30)
                )
        )
    }
}
