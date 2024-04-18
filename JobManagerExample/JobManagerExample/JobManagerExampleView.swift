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
import UserNotifications

@MainActor
struct JobManagerExampleView: View {
***REMOVED******REMOVED***/ The job manager used by this view.
***REMOVED***@ObservedObject var jobManager = JobManager.shared
***REMOVED******REMOVED***/ A Boolean value indicating if we are currently adding a geodatabase job.
***REMOVED***@State private var isAddingGeodatabaseJob = false
***REMOVED******REMOVED***/ A Boolean value indicating if we are currently adding an offline map job.
***REMOVED***@State private var isAddingOfflineMapJob = false
***REMOVED***
***REMOVED***init() {
***REMOVED******REMOVED******REMOVED*** Ask the job manager to schedule background status checks for every 30 seconds.
***REMOVED******REMOVED***jobManager.preferredBackgroundStatusCheckSchedule = .regularInterval(interval: 30)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***HStack(spacing: 10) {
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***if isAddingGeodatabaseJob || isAddingOfflineMapJob {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***menu
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***List(jobManager.jobs, id: \.id) { job in
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***JobView(job: job)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***jobManager.jobs.removeAll(where: { $0 === job ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "trash")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderless)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
***REMOVED******REMOVED******REMOVED******REMOVED***if let error {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The jobs menu.
***REMOVED***var menu: some View {
***REMOVED******REMOVED***Menu {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***isAddingGeodatabaseJob = true
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***jobManager.jobs.append(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await makeWildfiresGeodatabaseJob()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Logger.jobManagerExample.error("Error creating generate geodatabase job: \(error, privacy: .public)")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isAddingGeodatabaseJob = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label("Generate Geodatabase", systemImage: "plus")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.disabled(isAddingGeodatabaseJob)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***isAddingOfflineMapJob = true
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***jobManager.jobs.append(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await makeNapervilleOfflineMapJob()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Logger.jobManagerExample.error("Error creating offline map job: \(error, privacy: .public)")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isAddingOfflineMapJob = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label("Take Map Offline", systemImage: "plus")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.disabled(isAddingOfflineMapJob)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***jobManager.jobs.removeAll()
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label("Remove All Jobs", systemImage: "trash")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***jobManager.jobs.removeAll {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0.status == .failed || $0.status == .succeeded
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label("Remove All Completed Jobs", systemImage: "trash")
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text("Jobs")
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view that displays data for a job.
private struct JobView: View {
***REMOVED******REMOVED***/ The job that this view shows data for.
***REMOVED***var job: Job
***REMOVED******REMOVED***/ The job's error in case of failure.
***REMOVED***@State private var error: Error?
***REMOVED******REMOVED***/ The job's status.
***REMOVED***@State private var status: Job.Status
***REMOVED******REMOVED***/ The latest job message.
***REMOVED***@State private var message: JobMessage?
***REMOVED***
***REMOVED******REMOVED***/ Initializer that takes a job for which to show the data for.
***REMOVED***init(job: Job) {
***REMOVED******REMOVED***self.job = job
***REMOVED******REMOVED***status = job.status
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the progress is showing.
***REMOVED***var isShowingProgress: Bool {
***REMOVED******REMOVED***job.status == .started || (job.status == .paused && job.progress.fractionCompleted > 0)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the cancel button is showing.
***REMOVED***var isShowingCancel: Bool {
***REMOVED******REMOVED***job.status == .started || job.status == .paused
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A string for the job's type.
***REMOVED***var jobType: String {
***REMOVED******REMOVED***"\(type(of: job))"
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading, spacing: 5) {
***REMOVED******REMOVED******REMOVED***Text(jobType)
***REMOVED******REMOVED******REMOVED***Text(status.displayText)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED***if let error {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(error.localizedDescription)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***if let message {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(message.text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if isShowingProgress {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView(job.progress)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.linear)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if status == .started {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Pause", action: job.pause)
***REMOVED******REMOVED******REMOVED******REMOVED*** else if status == .paused {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Resume", action: job.start)
***REMOVED******REMOVED******REMOVED******REMOVED*** else if status == .notStarted {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Start", action: job.start)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isShowingCancel {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { await job.cancel() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderless)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.top, 2)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***.onReceive(job.$status) {
***REMOVED******REMOVED******REMOVED***status = $0
***REMOVED******REMOVED******REMOVED***if status == .failed || status == .succeeded {
***REMOVED******REMOVED******REMOVED******REMOVED***notifyJobCompleted()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onReceive(job.messages) {
***REMOVED******REMOVED******REMOVED***Logger.jobManagerExample.debug("Job Message: \($0.text, privacy: .public)")
***REMOVED******REMOVED******REMOVED***message = $0
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Posts a local notification that the job completed.
***REMOVED***func notifyJobCompleted() {
***REMOVED******REMOVED***Logger.jobManagerExample.debug("Posting local notification that job completed: \(status.displayText, privacy: .public)")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let content = UNMutableNotificationContent()
***REMOVED******REMOVED***content.sound = UNNotificationSound.default
***REMOVED******REMOVED***content.title = "Job Completed"
***REMOVED******REMOVED***content.subtitle = jobType
***REMOVED******REMOVED***content.body = status.displayText
***REMOVED******REMOVED***content.categoryIdentifier = "Job Completion"
***REMOVED******REMOVED***
***REMOVED******REMOVED***let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
***REMOVED******REMOVED***let identifier = "My Local Notification"
***REMOVED******REMOVED***let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
***REMOVED******REMOVED***
***REMOVED******REMOVED***UNUserNotificationCenter.current().add(request)
***REMOVED***
***REMOVED***

extension Job.Status {
***REMOVED******REMOVED***/ Display text for the status.
***REMOVED***var displayText: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .notStarted:
***REMOVED******REMOVED******REMOVED***return "Not Started"
***REMOVED******REMOVED***case .started:
***REMOVED******REMOVED******REMOVED***return "Started"
***REMOVED******REMOVED***case .paused:
***REMOVED******REMOVED******REMOVED***return "Paused"
***REMOVED******REMOVED***case .succeeded:
***REMOVED******REMOVED******REMOVED***return "Succeeded"
***REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED***return "Failed"
***REMOVED******REMOVED***case .canceling:
***REMOVED******REMOVED******REMOVED***return "Canceling"
***REMOVED***
***REMOVED***
***REMOVED***

extension JobManagerExampleView {
***REMOVED******REMOVED***/ Creates a job that generates a geodatabase for a wildfire service.
***REMOVED***func makeWildfiresGeodatabaseJob() async throws -> GenerateGeodatabaseJob {
***REMOVED******REMOVED***let url = URL(string: "https:***REMOVED***sampleserver6.arcgisonline.com/arcgis/rest/services/Sync/WildfireSync/FeatureServer")!
***REMOVED******REMOVED***return try await makeGenerateGeodatabaseJob(url: url, syncModel: .layer)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a job that generates an offline map for Naperville.
***REMOVED***func makeNapervilleOfflineMapJob() async throws -> GenerateOfflineMapJob {
***REMOVED******REMOVED***let portalItem = PortalItem(url: URL(string: "https:***REMOVED***www.arcgis.com/home/item.html?id=acc027394bc84c2fb04d1ed317aac674")!)!
***REMOVED******REMOVED***let map = Map(item: portalItem)
***REMOVED******REMOVED***let naperville = Envelope(
***REMOVED******REMOVED******REMOVED***xMin: -9813416.487598,
***REMOVED******REMOVED******REMOVED***yMin: 5126112.596989,
***REMOVED******REMOVED******REMOVED***xMax: -9812775.435463,
***REMOVED******REMOVED******REMOVED***yMax: 5127101.526749,
***REMOVED******REMOVED******REMOVED***spatialReference: SpatialReference.webMercator
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return try await makeOfflineMapJob(map: map, extent: naperville)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a generate geodatabase job.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - url: The URL to the task.
***REMOVED******REMOVED***/   - syncModel: The sync model for the geodatabase.
***REMOVED******REMOVED***/   - extent: The extent of the generated geodatabase.
***REMOVED***func makeGenerateGeodatabaseJob(url: URL, syncModel: Geodatabase.SyncModel, extent: Envelope? = nil) async throws -> GenerateGeodatabaseJob {
***REMOVED******REMOVED***let task = GeodatabaseSyncTask(url: url)
***REMOVED******REMOVED***try await task.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let params = GenerateGeodatabaseParameters()
***REMOVED******REMOVED***params.extent = extent ?? task.featureServiceInfo?.fullExtent
***REMOVED******REMOVED***params.outSpatialReference = extent?.spatialReference ?? SpatialReference.webMercator
***REMOVED******REMOVED***params.syncModel = syncModel
***REMOVED******REMOVED***
***REMOVED******REMOVED***if syncModel == .layer, let featureServiceInfo = task.featureServiceInfo {
***REMOVED******REMOVED******REMOVED***let layerOptions = featureServiceInfo.layerInfos
***REMOVED******REMOVED******REMOVED******REMOVED***.compactMap({ $0 as? FeatureServiceLayerIDInfo ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.compactMap(\.id)
***REMOVED******REMOVED******REMOVED******REMOVED***.map(GenerateLayerOption.init(layerID:))
***REMOVED******REMOVED******REMOVED***params.addLayerOptions(layerOptions)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let downloadURL = FileManager.default.documentsPath.appendingPathComponent(UUID().uuidString).appendingPathExtension("geodatabase")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let job = task.makeGenerateGeodatabaseJob(
***REMOVED******REMOVED******REMOVED***parameters: params,
***REMOVED******REMOVED******REMOVED***downloadFileURL: downloadURL
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return job
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an offline map job.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - map: The map to take offline.
***REMOVED******REMOVED***/   - extent: The extent of the offline area.
***REMOVED***func makeOfflineMapJob(map: Map, extent: Envelope) async throws -> GenerateOfflineMapJob {
***REMOVED******REMOVED***let task = OfflineMapTask(onlineMap: map)
***REMOVED******REMOVED***let params = try await task.makeDefaultGenerateOfflineMapParameters(areaOfInterest: extent)
***REMOVED******REMOVED***let downloadURL = FileManager.default.documentsPath.appendingPathComponent(UUID().uuidString)
***REMOVED******REMOVED***return task.makeGenerateOfflineMapJob(parameters: params, downloadDirectory: downloadURL)
***REMOVED***
***REMOVED***

extension FileManager {
***REMOVED******REMOVED***/ The path to the documents folder.
***REMOVED***var documentsPath: URL {
***REMOVED******REMOVED***URL(
***REMOVED******REMOVED******REMOVED***fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

public extension JobProtocol {
***REMOVED******REMOVED***/ The id of the job.
***REMOVED***var id: ObjectIdentifier {
***REMOVED******REMOVED***ObjectIdentifier(self)
***REMOVED***
***REMOVED***
