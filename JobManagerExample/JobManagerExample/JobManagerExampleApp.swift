***REMOVED*** Copyright 2023 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***Toolkit
import OSLog
***REMOVED***

***REMOVED***
struct JobManagerExampleApp: App {
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***JobManagerExampleView()
***REMOVED***
***REMOVED******REMOVED***.backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
***REMOVED******REMOVED******REMOVED***Logger.jobManagerExample.debug("URLSession background task SwiftUI callback.")
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
***REMOVED******REMOVED***/ A logger for the job manager.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ To enable logging add an environment variable named "LOGGING_FOR_JOB_MANAGER_EXAMPLE" under Scheme
***REMOVED******REMOVED***/ -> Arguments -> Environment Variables
***REMOVED***static let jobManagerExample: Logger = {
***REMOVED******REMOVED***if ProcessInfo.processInfo.environment.keys.contains("LOGGING_FOR_JOB_MANAGER_EXAMPLE") {
***REMOVED******REMOVED******REMOVED***return Logger(subsystem: "com.esri.ArcGISToolkit.Examples", category: "JobManagerExample")
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return Logger(OSLog.disabled)
***REMOVED***
***REMOVED***()
***REMOVED***
