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
        .backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
            // Allow the `ArcGISURLSession` to handle it's background task events.
            await ArcGISEnvironment.backgroundURLSession.handleEventsForBackgroundTask()
            
            // When the app is re-launched from a background url session, resume any paused jobs,
            // and check the job status.
            await JobManager.shared.resumeAllPausedJobs()
        }
    }
}
