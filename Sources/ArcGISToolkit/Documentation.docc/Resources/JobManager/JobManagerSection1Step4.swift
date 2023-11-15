import ArcGIS
import ArcGISToolkit
import SwiftUI

@main
struct JobManagerTutorialApp: App {
    init() {
        ArcGISEnvironment.apiKey = APIKey("Valid API Key")
    }

    var body: some SwiftUI.Scene {
        WindowGroup {
            JobManagerTutorialView()
        }
    }
}
