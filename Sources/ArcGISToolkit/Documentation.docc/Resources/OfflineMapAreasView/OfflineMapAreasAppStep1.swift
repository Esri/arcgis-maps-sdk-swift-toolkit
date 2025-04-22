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
        .offlineManager(preferredBackgroundStatusCheckSchedule: .regularInterval(interval: 30))
    }
}
