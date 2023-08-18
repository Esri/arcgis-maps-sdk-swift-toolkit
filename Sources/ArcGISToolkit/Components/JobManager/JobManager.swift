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

@MainActor
public class JobManager: ObservableObject {
***REMOVED***public struct ID: RawRepresentable {
***REMOVED******REMOVED***public var rawValue: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***public init(rawValue: String) {
***REMOVED******REMOVED******REMOVED***self.rawValue = rawValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public static let `default` = JobManager(id: .init(rawValue: "default"))
***REMOVED***
***REMOVED***private let id: ID
***REMOVED***
***REMOVED***private var defaultsKey: String {
***REMOVED******REMOVED***return "com.esri.ArcGISToolkit.jobManager.\(id.rawValue).jobs"
***REMOVED***
***REMOVED***
***REMOVED***@objc func appMovedToBackground() {
***REMOVED******REMOVED***saveJobs()
***REMOVED***
***REMOVED***
***REMOVED***public init(id: ID) {
***REMOVED******REMOVED***self.id = id
***REMOVED******REMOVED***
***REMOVED******REMOVED***let notificationCenter = NotificationCenter.default
***REMOVED******REMOVED***notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED***loadJobs()
***REMOVED***
***REMOVED***
***REMOVED***@Published
***REMOVED***public var jobs: [any JobProtocol] = []
***REMOVED***
***REMOVED******REMOVED***/ Adds a job to the job manager.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameter job: The job to register.
***REMOVED***public func add(job: any JobProtocol) {
***REMOVED******REMOVED***jobs.append(job)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Removes a job from the job manager.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameter job: The job to unregister.
***REMOVED***public func remove(job: any JobProtocol) {
***REMOVED******REMOVED***guard let index = jobs.firstIndex(where: { $0 === job ***REMOVED***) else { return ***REMOVED***
***REMOVED******REMOVED***jobs.remove(at: index)
***REMOVED***
***REMOVED***
***REMOVED***public func removeAllJobs() {
***REMOVED******REMOVED***jobs.removeAll()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Saves all managed jobs to User Defaults.
***REMOVED***private func saveJobs() {
***REMOVED******REMOVED***let array = jobs.map { $0.toJSON() ***REMOVED***
***REMOVED******REMOVED***UserDefaults.standard.setValue(array, forKey: defaultsKey)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Load any jobs that have been saved to User Defaults.
***REMOVED***private func loadJobs() {
***REMOVED******REMOVED***guard let strings = UserDefaults.standard.array(forKey: defaultsKey) as? [String] else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***jobs = strings.compactMap {
***REMOVED******REMOVED******REMOVED***try? Job.fromJSON($0) as? any JobProtocol
***REMOVED***
***REMOVED***
***REMOVED***
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
