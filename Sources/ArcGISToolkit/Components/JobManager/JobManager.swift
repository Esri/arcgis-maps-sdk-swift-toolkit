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

***REMOVED***/ An object that manages saving jobs when the app is backgrounded and can reload them later.
@MainActor
public class JobManager: ObservableObject {
***REMOVED******REMOVED***/ An identifier for the job manager.
***REMOVED***public struct ID: RawRepresentable {
***REMOVED******REMOVED***public var rawValue: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***public init(rawValue: String) {
***REMOVED******REMOVED******REMOVED***self.rawValue = rawValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The default job manager.
***REMOVED***public static let `default` = JobManager(id: .init(rawValue: "default"))
***REMOVED***
***REMOVED******REMOVED***/ The unique id of the job manager.
***REMOVED***private let id: ID
***REMOVED***
***REMOVED******REMOVED***/ The jobs being managed by the job manager.
***REMOVED***@Published
***REMOVED***public var jobs: [any JobProtocol] = []
***REMOVED***
***REMOVED******REMOVED***/ The key for which state will be serialized under the user defaults.
***REMOVED***private var defaultsKey: String {
***REMOVED******REMOVED***return "com.esri.ArcGISToolkit.jobManager.\(id.rawValue).jobs"
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ An initializer that takes an ID for the job manager.
***REMOVED******REMOVED***/ It is the callers responsibility to make sure the ID is unique.
***REMOVED***public init(id: ID) {
***REMOVED******REMOVED***self.id = id
***REMOVED******REMOVED***
***REMOVED******REMOVED***let notificationCenter = NotificationCenter.default
***REMOVED******REMOVED***notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Load jobs from the saved state.
***REMOVED******REMOVED***loadState()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Called when the app moves to the background.
***REMOVED***@objc private func appMovedToBackground() {
***REMOVED******REMOVED******REMOVED*** Save the jobs to the user defaults when the app moves to the background.
***REMOVED******REMOVED***saveState()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Check the status of all managed jobs.
***REMOVED***public func performStatusChecks() async {
***REMOVED******REMOVED***await withTaskGroup(of: Void.self) { group in
***REMOVED******REMOVED******REMOVED***for job in jobs {
***REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await job.checkStatus()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Saves all managed jobs to User Defaults.
***REMOVED***private func saveState() {
***REMOVED******REMOVED***let array = jobs.map { $0.toJSON() ***REMOVED***
***REMOVED******REMOVED***UserDefaults.standard.setValue(array, forKey: defaultsKey)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Load any jobs that have been saved to User Defaults.
***REMOVED***private func loadState() {
***REMOVED******REMOVED***guard let strings = UserDefaults.standard.array(forKey: defaultsKey) as? [String] else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***jobs = strings.compactMap {
***REMOVED******REMOVED******REMOVED***try? Job.fromJSON($0) as? any JobProtocol
***REMOVED***
***REMOVED***
***REMOVED***
