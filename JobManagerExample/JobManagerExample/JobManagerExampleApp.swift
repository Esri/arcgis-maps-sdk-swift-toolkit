// Copyright 2023 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import OSLog
import SwiftUI

@main
struct JobManagerExampleApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            JobManagerExampleView()
        }
        .backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
            Logger.jobManagerExample.debug("URLSession background task SwiftUI callback.")
            
            // Allow the `ArcGISURLSession` to handle it's background task events.
            await ArcGISEnvironment.backgroundURLSession.handleEventsForBackgroundTask()
            
            // When the app is re-launched from a background url session, resume any paused jobs,
            // and check the job status.
            await JobManager.shared.resumeAllPausedJobs()
        }
    }
}

extension Logger {
    /// A logger for the job manager example.
    /// To enable logging add an environment variable named "LOGGING_FOR_JOB_MANAGER_EXAMPLE" under
    /// Scheme > Arguments > Environment Variables
    static let jobManagerExample: Logger = {
        if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_JOB_MANAGER_EXAMPLE") {
            return Logger(subsystem: "com.esri.ArcGISToolkit.Examples", category: "JobManagerExample")
        } else {
            return Logger(OSLog.disabled)
        }
    }()
}
