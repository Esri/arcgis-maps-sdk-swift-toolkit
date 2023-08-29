***REMOVED***
***REMOVED***  JobManagerExampleApp.swift
***REMOVED***  JobManagerExample
***REMOVED***
***REMOVED***  Created by Ryan Olson on 8/15/23.
***REMOVED***

***REMOVED***
***REMOVED***Toolkit
***REMOVED***
import OSLog

***REMOVED***
struct JobManagerExampleApp: App {
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED******REMOVED***JobManagerExampleView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
***REMOVED******REMOVED******REMOVED***Logger.jobManagerExample.debug("UrlSession background task SwiftUI callback.")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Allow the `ArcGISURLSession` to handle it's background task events.
***REMOVED******REMOVED******REMOVED***await ArcGISEnvironment.backgroundURLSession.handleEventsForBackgroundTask()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** When the app is re-launched from a background url session, resume any paused jobs,
***REMOVED******REMOVED******REMOVED******REMOVED*** and check the job status.
***REMOVED******REMOVED******REMOVED***await JobManager.shared.resumeAllPausedJobs()
***REMOVED***
***REMOVED***
***REMOVED***

extension Logger {
***REMOVED******REMOVED***/ A logger for the job manager example.
***REMOVED******REMOVED***/ To enable logging add an environment variable named "LOGGING_FOR_JOB_MANAGER_EXAMPLE".
***REMOVED***static let jobManagerExample: Logger = {
***REMOVED******REMOVED***if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_JOB_MANAGER_EXAMPLE") {
***REMOVED******REMOVED******REMOVED***return Logger(subsystem: "com.esri.ArcGISToolkit.Examples", category: "JobManagerExample")
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return Logger(OSLog.disabled)
***REMOVED***
***REMOVED***()
***REMOVED***
