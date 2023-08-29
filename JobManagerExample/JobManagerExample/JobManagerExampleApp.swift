//
//  JobManagerExampleApp.swift
//  JobManagerExample
//
//  Created by Ryan Olson on 8/15/23.
//

import SwiftUI
import ArcGISToolkit
import ArcGIS
import OSLog

@main
struct JobManagerExampleApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            NavigationView {
                JobManagerExampleView()
            }
        }
        .backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
            Logger.jobManagerExample.debug("UrlSession background task SwiftUI callback.")
            
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
    /// To enable logging add an environment variable named "LOGGING_FOR_JOB_MANAGER_EXAMPLE".
    static let jobManagerExample: Logger = {
        if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_JOB_MANAGER_EXAMPLE") {
            return Logger(subsystem: "com.esri.ArcGISToolkit.Examples", category: "JobManagerExample")
        } else {
            return Logger(OSLog.disabled)
        }
    }()
}
