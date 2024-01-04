***REMOVED***
***REMOVED***Toolkit
***REMOVED***

***REMOVED***
struct JobManagerTutorialApp: App {
***REMOVED***init() {
***REMOVED******REMOVED***ArcGISEnvironment.apiKey = APIKey("Valid API Key")
***REMOVED***

***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***JobManagerTutorialView()
***REMOVED***
***REMOVED******REMOVED***.backgroundTask(.urlSession(ArcGISEnvironment.defaultBackgroundURLSessionIdentifier)) {
***REMOVED******REMOVED******REMOVED******REMOVED*** Allow the `ArcGISURLSession` to handle it's background task events.
***REMOVED******REMOVED******REMOVED***await ArcGISEnvironment.backgroundURLSession.handleEventsForBackgroundTask()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** When the app is re-launched from a background url session, resume any paused jobs,
***REMOVED******REMOVED******REMOVED******REMOVED*** and check the job status.
***REMOVED******REMOVED******REMOVED***await JobManager.shared.resumeAllPausedJobs()
***REMOVED***
***REMOVED***
***REMOVED***
