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
***REMOVED***

***REMOVED***/ An object that encapsulates state about a preplanned map.
@MainActor
public class PreplannedMapModel: ObservableObject, Identifiable {
***REMOVED******REMOVED***/ The preplanned map area.
***REMOVED***let preplannedMapArea: any PreplannedMapAreaProtocol
***REMOVED***
***REMOVED******REMOVED***/ The task to use to take the area offline.
***REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED***
***REMOVED******REMOVED***/ The download directory for the preplanned map areas.
***REMOVED***private let preplannedDirectory: URL
***REMOVED***
***REMOVED******REMOVED***/ The ID of the preplanned map area.
***REMOVED***private let preplannedMapAreaID: String
***REMOVED***
***REMOVED******REMOVED***/ The mobile map package for the preplanned map area.
***REMOVED***private(set) var mobileMapPackage: MobileMapPackage?
***REMOVED***
***REMOVED******REMOVED***/ The currently running download job.
***REMOVED***@Published private(set) var job: DownloadPreplannedOfflineMapJob?
***REMOVED***
***REMOVED******REMOVED***/ The combined status of the preplanned map area.
***REMOVED***@Published private(set) var status: Status = .notLoaded

***REMOVED******REMOVED***/ The result of the download job. When the result is `.success` the mobile map package is returned.
***REMOVED******REMOVED***/ If the result is `.failure` then the error is returned. The result will be `nil` when the preplanned
***REMOVED******REMOVED***/ map area is still packaging or loading.
***REMOVED***@Published private(set) var result: Result<MobileMapPackage, Error>?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if download can be called.
***REMOVED***var canDownload: Bool {
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case .notLoaded, .loading, .loadFailure, .packaging, .packageFailure,
***REMOVED******REMOVED******REMOVED******REMOVED***.downloading, .downloaded:
***REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED***case .packaged, .downloadFailure:
***REMOVED******REMOVED******REMOVED***true
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***init?(
***REMOVED******REMOVED***preplannedMapArea: PreplannedMapAreaProtocol,
***REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED***preplannedDirectory: URL,
***REMOVED******REMOVED***mobileMapPackage: MobileMapPackage? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.offlineMapTask = offlineMapTask
***REMOVED******REMOVED***self.preplannedMapArea = preplannedMapArea
***REMOVED******REMOVED***self.mobileMapPackage = mobileMapPackage
***REMOVED******REMOVED***self.preplannedDirectory = preplannedDirectory
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let itemID = preplannedMapArea.id {
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID = itemID.rawValue
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***setDownloadJob()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the preplanned map area and updates the status.
***REMOVED***func load() async {
***REMOVED******REMOVED***guard status.needsToBeLoaded else { return ***REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED*** Load preplanned map area to obtain packaging status.
***REMOVED******REMOVED******REMOVED***status = .loading
***REMOVED******REMOVED******REMOVED***try await preplannedMapArea.retryLoad()
***REMOVED******REMOVED******REMOVED******REMOVED*** Note: Packaging status is `nil` for compatibility with
***REMOVED******REMOVED******REMOVED******REMOVED*** legacy webmaps that have incomplete metadata.
***REMOVED******REMOVED******REMOVED******REMOVED*** If the area loads, then you know for certain the status is complete.
***REMOVED******REMOVED******REMOVED***updateStatus(for: preplannedMapArea.packagingStatus ?? .complete)
***REMOVED*** catch MappingError.packagingNotComplete {
***REMOVED******REMOVED******REMOVED******REMOVED*** Load will throw an `MappingError.packagingNotComplete` error if not complete,
***REMOVED******REMOVED******REMOVED******REMOVED*** this case is not a normal load failure.
***REMOVED******REMOVED******REMOVED***updateStatus(for: preplannedMapArea.packagingStatus ?? .failed)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED*** Normal load failure.
***REMOVED******REMOVED******REMOVED***status = .loadFailure(error)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the model download preplanned offline map job if the job is in progress.
***REMOVED***private func setDownloadJob() {
***REMOVED******REMOVED***for job in JobManager.shared.jobs {
***REMOVED******REMOVED******REMOVED***if let preplannedJob = job as? DownloadPreplannedOfflineMapJob {
***REMOVED******REMOVED******REMOVED******REMOVED***if preplannedJob.downloadDirectoryURL.deletingPathExtension().lastPathComponent == preplannedMapAreaID {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.job = preplannedJob
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***status = .downloading
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the status for a given packaging status.
***REMOVED***private func updateStatus(for packagingStatus: PreplannedMapArea.PackagingStatus) {
***REMOVED******REMOVED******REMOVED*** Update area status for a given packaging status.
***REMOVED******REMOVED***switch packagingStatus {
***REMOVED******REMOVED***case .processing:
***REMOVED******REMOVED******REMOVED***status = .packaging
***REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED***status = .packageFailure
***REMOVED******REMOVED***case .complete:
***REMOVED******REMOVED******REMOVED***status = .packaged
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***fatalError("Unknown packaging status")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the status based on the download result of the mobile map package.
***REMOVED***func updateDownloadStatus(for downloadResult: Optional<Result<MobileMapPackage, any Error>>) {
***REMOVED******REMOVED***switch downloadResult {
***REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED***status = .downloaded
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***status = .downloadFailure(error)
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***if let mobileMapPackage = try? downloadResult?.get() {
***REMOVED******REMOVED******REMOVED******REMOVED***setMobileMapPackage(mobileMapPackage)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the mobile map pacakge if downloaded locally.
***REMOVED***func setMobileMapPackage(_ mobileMapPackage: MobileMapPackage) {
***REMOVED******REMOVED******REMOVED*** Set the mobile map package if already downloaded or the download job succeeded.
***REMOVED******REMOVED***if job == nil || job?.status == .succeeded {
***REMOVED******REMOVED******REMOVED******REMOVED*** Set the mobile map package if it downloaded.
***REMOVED******REMOVED******REMOVED***self.mobileMapPackage = mobileMapPackage
***REMOVED******REMOVED******REMOVED***status = .downloaded
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Posts a local notification that the job completed.
***REMOVED***func notifyJobCompleted(_ jobStatus: Job.Status) {
***REMOVED******REMOVED***let content = UNMutableNotificationContent()
***REMOVED******REMOVED***content.sound = UNNotificationSound.default
***REMOVED******REMOVED***
***REMOVED******REMOVED***if jobStatus == .succeeded {
***REMOVED******REMOVED******REMOVED***content.title = "Download Succeeded"
***REMOVED******REMOVED******REMOVED***content.body = "The job for City Hall Area has completed successfully."
***REMOVED*** else if jobStatus == .failed {
***REMOVED******REMOVED******REMOVED***content.title = "Download Failed"
***REMOVED******REMOVED******REMOVED***content.body = "The job for City Hall Area failed."
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
***REMOVED******REMOVED***let identifier = "My Local Notification"
***REMOVED******REMOVED***let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
***REMOVED******REMOVED***
***REMOVED******REMOVED***UNUserNotificationCenter.current().add(request)
***REMOVED***
***REMOVED***

extension PreplannedMapModel {
***REMOVED******REMOVED***/ Downloads the preplanned map area.
***REMOVED******REMOVED***/ - Precondition: `canDownload`
***REMOVED***func downloadPreplannedMapArea() async {
***REMOVED******REMOVED***precondition(canDownload)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mmpkDirectory = createDownloadDirectories()
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let parameters = await createParameters() else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***await runDownloadTask(for: parameters, in: mmpkDirectory)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates download directories for the preplanned map area and its mobile map package.
***REMOVED******REMOVED***/ - Returns: The URL for the mobile map package directory.
***REMOVED***private func createDownloadDirectories() -> URL {
***REMOVED******REMOVED***let downloadDirectory = preplannedDirectory
***REMOVED******REMOVED******REMOVED***.appending(path: preplannedMapAreaID, directoryHint: .isDirectory)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let packageDirectory = downloadDirectory
***REMOVED******REMOVED******REMOVED***.appending(component: "package", directoryHint: .isDirectory)
***REMOVED******REMOVED***
***REMOVED******REMOVED***try? FileManager.default.createDirectory(atPath: downloadDirectory.relativePath, withIntermediateDirectories: true)
***REMOVED******REMOVED***
***REMOVED******REMOVED***try? FileManager.default.createDirectory(atPath: packageDirectory.relativePath, withIntermediateDirectories: true)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mmpkDirectory = packageDirectory
***REMOVED******REMOVED******REMOVED***.appendingPathComponent(preplannedMapAreaID)
***REMOVED******REMOVED******REMOVED***.appendingPathExtension("mmpk")
***REMOVED******REMOVED***
***REMOVED******REMOVED***return mmpkDirectory
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates the parameters to download a preplanned offline map.
***REMOVED******REMOVED***/ - Returns: The parameters to download a preplanned offline map.
***REMOVED***private func createParameters() async -> DownloadPreplannedOfflineMapParameters? {
***REMOVED******REMOVED***guard let preplannedMapArea = preplannedMapArea.mapArea else { return nil ***REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED*** Creates the parameters for the download preplanned offline map job.
***REMOVED******REMOVED******REMOVED***let parameters = try await offlineMapTask.makeDefaultDownloadPreplannedOfflineMapParameters(
***REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapArea: preplannedMapArea
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED*** Sets the update mode to no updates as the offline map is display-only.
***REMOVED******REMOVED******REMOVED***parameters.updateMode = .noUpdates
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return parameters
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED*** If creating the parameters fails, set the failure.
***REMOVED******REMOVED******REMOVED***self.result = .failure(error)
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Runs the download task to download the preplanned offline map.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - parameters: The parameters used to download the offline map.
***REMOVED******REMOVED***/   - mmpkDirectory: The directory used to place the mobile map package result.
***REMOVED***private func runDownloadTask(
***REMOVED******REMOVED***for parameters: DownloadPreplannedOfflineMapParameters,
***REMOVED******REMOVED***in mmpkDirectory: URL
***REMOVED***) async {
***REMOVED******REMOVED******REMOVED*** Creates the download preplanned offline map job.
***REMOVED******REMOVED***let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
***REMOVED******REMOVED******REMOVED***parameters: parameters,
***REMOVED******REMOVED******REMOVED***downloadDirectory: mmpkDirectory
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***JobManager.shared.jobs.append(job)
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.job = job
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Starts the job.
***REMOVED******REMOVED***job.start()
***REMOVED******REMOVED***
***REMOVED******REMOVED***if canDownload {
***REMOVED******REMOVED******REMOVED***status = .downloading
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Awaits the output of the job and assigns the result.
***REMOVED******REMOVED***result = await job.result.map { $0.mobileMapPackage ***REMOVED***
***REMOVED***
***REMOVED***

extension PreplannedMapModel {
***REMOVED******REMOVED***/ The status of the preplanned map area model.
***REMOVED***enum Status {
***REMOVED******REMOVED******REMOVED***/ Preplanned map area not loaded.
***REMOVED******REMOVED***case notLoaded
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is loading.
***REMOVED******REMOVED***case loading
***REMOVED******REMOVED******REMOVED***/ Preplanned map area failed to load.
***REMOVED******REMOVED***case loadFailure(Error)
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is packaging.
***REMOVED******REMOVED***case packaging
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is packaged and ready for download.
***REMOVED******REMOVED***case packaged
***REMOVED******REMOVED******REMOVED***/ Preplanned map area packaging failed.
***REMOVED******REMOVED***case packageFailure
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is being downloaded.
***REMOVED******REMOVED***case downloading
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is downloaded.
***REMOVED******REMOVED***case downloaded
***REMOVED******REMOVED******REMOVED***/ Preplanned map area failed to download.
***REMOVED******REMOVED***case downloadFailure(Error)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the model is in a state
***REMOVED******REMOVED******REMOVED***/ where it needs to be loaded or reloaded.
***REMOVED******REMOVED***var needsToBeLoaded: Bool {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .loading, .packaging, .packaged, .downloading, .downloaded:
***REMOVED******REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension PreplannedMapModel: Hashable {
***REMOVED***nonisolated public static func == (lhs: PreplannedMapModel, rhs: PreplannedMapModel) -> Bool {
***REMOVED******REMOVED***lhs === rhs
***REMOVED***
***REMOVED***
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(ObjectIdentifier(self))
***REMOVED***
***REMOVED***

***REMOVED***/ A type that acts as a preplanned map area.
protocol PreplannedMapAreaProtocol {
***REMOVED***func retryLoad() async throws
***REMOVED***
***REMOVED***var mapArea: PreplannedMapArea? { get ***REMOVED***
***REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? { get ***REMOVED***
***REMOVED***var title: String { get ***REMOVED***
***REMOVED***var description: String { get ***REMOVED***
***REMOVED***var thumbnail: LoadableImage? { get ***REMOVED***
***REMOVED***var id: PortalItem.ID? { get ***REMOVED***
***REMOVED***

***REMOVED***/ Extend `PreplannedMapArea` to conform to `PreplannedMapAreaProtocol`.
extension PreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED***var mapArea: PreplannedMapArea? {
***REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***var title: String {
***REMOVED******REMOVED***portalItem.title
***REMOVED***
***REMOVED***
***REMOVED***var thumbnail: LoadableImage? {
***REMOVED******REMOVED***portalItem.thumbnail
***REMOVED***
***REMOVED***
***REMOVED***var description: String {
***REMOVED******REMOVED***portalItem.description
***REMOVED***
***REMOVED***
***REMOVED***var id: PortalItem.ID? {
***REMOVED******REMOVED***portalItem.id
***REMOVED***
***REMOVED***
