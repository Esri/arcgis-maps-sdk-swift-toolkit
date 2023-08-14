***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

public actor JobManager {
***REMOVED***public struct ID: RawRepresentable {
***REMOVED******REMOVED***public var rawValue: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***public init(rawValue: String) {
***REMOVED******REMOVED******REMOVED***self.rawValue = rawValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public static let shared = JobManager(id: .init(rawValue: "shared"))
***REMOVED***
***REMOVED***private let id: ID
***REMOVED***
***REMOVED***private var defaultsKey: String {
***REMOVED******REMOVED***return "com.esri.ArcGISToolkit.jobManager.\(id.rawValue).jobs"
***REMOVED***
***REMOVED***
***REMOVED***public init(id: ID) {
***REMOVED******REMOVED***self.id = id
***REMOVED***
***REMOVED***
***REMOVED***private var isSavingSuppressed = false
***REMOVED***
***REMOVED***private func withSavingSuppressed<T>(body: @Sendable (isolated JobManager) throws -> T) rethrows -> T {
***REMOVED******REMOVED***isSavingSuppressed = true
***REMOVED******REMOVED***defer { isSavingSuppressed = false ***REMOVED***
***REMOVED******REMOVED***return try body(self)
***REMOVED***
***REMOVED***
***REMOVED***private var jobs: [any JobProtocol] = []
***REMOVED***
***REMOVED******REMOVED***/ Saves all managed jobs to User Defaults.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This happens automatically when the jobs are registered/unregistered.
***REMOVED******REMOVED***/ It also happens when a job's status changes.
***REMOVED***private func saveJobsToUserDefaults() {
***REMOVED******REMOVED******REMOVED***guard !suppressSaveToUserDefaults else { return ***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***UserDefaults.standard.set(self.toJSON(), forKey: jobsDefaultsKey)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Load any jobs that have been saved to User Defaults.
***REMOVED***private func loadJobsFromUserDefaults() {
***REMOVED******REMOVED******REMOVED***if let storedJobsJSON = UserDefaults.standard.dictionary(forKey: jobsDefaultsKey) {
***REMOVED******REMOVED******REMOVED******REMOVED***suppressSaveToUserDefaults = true
***REMOVED******REMOVED******REMOVED******REMOVED***keyedJobs = storedJobsJSON.compactMapValues { $0 is JSONDictionary ? (try? AGSJob.fromJSON($0)) as? AGSJob : nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***suppressSaveToUserDefaults = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
