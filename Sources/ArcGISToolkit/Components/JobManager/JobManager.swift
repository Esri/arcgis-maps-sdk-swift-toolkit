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

public typealias JobID = String

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
***REMOVED******REMOVED***print("App moved to background!")
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
***REMOVED******REMOVED******REMOVED***removeAllJobs()
***REMOVED***
***REMOVED***
***REMOVED***private var isSavingSuppressed = false
***REMOVED***
***REMOVED******REMOVED*** TODO: is this needed?
***REMOVED***private func withSavingSuppressed<T>(body: @Sendable @MainActor () throws -> T) rethrows -> T {
***REMOVED******REMOVED***isSavingSuppressed = true
***REMOVED******REMOVED***defer { isSavingSuppressed = false ***REMOVED***
***REMOVED******REMOVED***return try body()
***REMOVED***
***REMOVED***
***REMOVED***private var _jobs: [JobID: any JobProtocol] = [:] {
***REMOVED******REMOVED***willSet {
***REMOVED******REMOVED******REMOVED***objectWillChange.send()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var jobs: [any JobProtocol] {
***REMOVED******REMOVED***Array(_jobs.values)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Registers a job with the job manager.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameter job: The job to register.
***REMOVED******REMOVED***/ - Returns: A unique ID for the job's registration which can be used to unregister the job.
***REMOVED***@discardableResult
***REMOVED***public func add(job: any JobProtocol) -> JobID {
***REMOVED******REMOVED***let id = UUID().uuidString
***REMOVED******REMOVED***_jobs[id] = job
***REMOVED******REMOVED***return id
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Unregisters a job from the job manager.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameter id: The job's ID, returned from calling `register()`.
***REMOVED******REMOVED***/ - Returns: `true` if the Job was found, `false` otherwise.
***REMOVED***@discardableResult
***REMOVED***public func remove(jobWithID id: JobID) -> Bool {
***REMOVED******REMOVED***let removed = _jobs.removeValue(forKey: id) != nil
***REMOVED******REMOVED***return removed
***REMOVED***

***REMOVED******REMOVED***/ Unregisters a job from the job manager.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameter job: The job to unregister.
***REMOVED******REMOVED***/ - Returns: `true` if the Job was found, `false` otherwise.
***REMOVED***@discardableResult
***REMOVED***public func remove(job: any JobProtocol) -> Bool {
***REMOVED******REMOVED***guard let keyValue = _jobs.first(where: { $0.value === job ***REMOVED***) else {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return remove(jobWithID: keyValue.key)
***REMOVED***
***REMOVED***
***REMOVED***public func removeAllJobs() {
***REMOVED******REMOVED***_jobs.removeAll()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Saves all managed jobs to User Defaults.
***REMOVED***private func saveJobs() {
***REMOVED******REMOVED***guard !isSavingSuppressed else { return ***REMOVED***
***REMOVED******REMOVED***let dictionary = _jobs.mapValues { $0.toJSON() ***REMOVED***
***REMOVED******REMOVED***UserDefaults.standard.setValue(dictionary, forKey: defaultsKey)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Load any jobs that have been saved to User Defaults.
***REMOVED***private func loadJobs() {
***REMOVED******REMOVED***guard let dictionary = UserDefaults.standard.dictionary(forKey: defaultsKey) as? [JobID: String] else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***withSavingSuppressed {
***REMOVED******REMOVED******REMOVED***_jobs = dictionary.compactMapValues {
***REMOVED******REMOVED******REMOVED******REMOVED***try? Job.fromJSON($0) as? any JobProtocol
***REMOVED******REMOVED***
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
