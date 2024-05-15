***REMOVED*** Copyright 2024 Esri
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
***REMOVED***

***REMOVED***
struct OfflineMapAreasExampleApp: App {
***REMOVED***
***REMOVED***init() {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED*** Allow the `ArcGISURLSession` to handle it's background task events.
***REMOVED******REMOVED******REMOVED***await ArcGISEnvironment.backgroundURLSession.handleEventsForBackgroundTask()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** When the app is re-launched from a background url session, resume any paused jobs,
***REMOVED******REMOVED******REMOVED******REMOVED*** and check the job status.
***REMOVED******REMOVED******REMOVED***JobManager.shared.resumeAllPausedJobs()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***OfflineMapAreasExampleView()
***REMOVED***
***REMOVED***
***REMOVED***
