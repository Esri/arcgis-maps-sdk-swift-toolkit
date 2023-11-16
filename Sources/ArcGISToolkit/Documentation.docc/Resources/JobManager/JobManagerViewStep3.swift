***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct JobManagerTutorialView: View {
***REMOVED******REMOVED***/ The job manager used by this view.
***REMOVED***@ObservedObject var jobManager = JobManager.shared
***REMOVED******REMOVED***/ The job that this view shows data for.
***REMOVED***@State private var job: Job?
***REMOVED******REMOVED***/ The job's error in case of failure.
***REMOVED***@State private var error: Error?
***REMOVED******REMOVED***/ A Boolean value indicating if we are currently adding an offline map job.
***REMOVED***@State private var isAddingOfflineMapJob = false
***REMOVED******REMOVED***/ The job's status.
***REMOVED***@State private var status: Job.Status = .notStarted

***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if let job {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView(job.progress)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.linear)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***jobManager.jobs.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.job = nil
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Start New Job")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(status == .started)
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(status == .started ? 0.0 : 1.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED***.task() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await jobStatus in job.$status {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***status = jobStatus
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(spacing: 10) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isAddingOfflineMapJob {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isAddingOfflineMapJob = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***jobManager.jobs.append(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await makeNapervilleOfflineMapJob()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Error creating offline map job: \(error)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***job = jobManager.jobs.first
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isAddingOfflineMapJob = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Take Map Offline")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(isAddingOfflineMapJob)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension JobManagerTutorialView {
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
