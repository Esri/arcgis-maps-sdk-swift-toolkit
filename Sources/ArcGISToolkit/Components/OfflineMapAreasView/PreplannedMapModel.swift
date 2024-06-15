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
***REMOVED******REMOVED***/ The ID of the web map.
***REMOVED***private let portalItemID: String
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
***REMOVED***init(
***REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED***mapArea: PreplannedMapAreaProtocol,
***REMOVED******REMOVED***portalItemID: String,
***REMOVED******REMOVED***preplannedMapAreaID: String
***REMOVED***) {
***REMOVED******REMOVED***self.offlineMapTask = offlineMapTask
***REMOVED******REMOVED***preplannedMapArea = mapArea
***REMOVED******REMOVED***self.portalItemID = portalItemID
***REMOVED******REMOVED***self.preplannedMapAreaID = preplannedMapAreaID
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let foundJob = lookupDownloadJob() {
***REMOVED******REMOVED******REMOVED***print("-- found job: \(job?.parameters.preplannedMapArea?.title ?? "unknown")")
***REMOVED******REMOVED******REMOVED***startAndObserveJob(foundJob)
***REMOVED*** else if let mmpk = lookupMobileMapPackage() {
***REMOVED******REMOVED******REMOVED***print("-- found mmpk: \(mmpk.fileURL)")
***REMOVED******REMOVED******REMOVED***self.mobileMapPackage = mmpk
***REMOVED******REMOVED******REMOVED***self.status = .downloaded
***REMOVED***
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
***REMOVED******REMOVED***/ Look up the job associated with this preplanned map model.
***REMOVED***private func lookupDownloadJob() -> DownloadPreplannedOfflineMapJob? {
***REMOVED******REMOVED***JobManager.shared.jobs
***REMOVED******REMOVED******REMOVED***.lazy
***REMOVED******REMOVED******REMOVED***.compactMap { $0 as? DownloadPreplannedOfflineMapJob ***REMOVED***
***REMOVED******REMOVED******REMOVED***.first {
***REMOVED******REMOVED******REMOVED******REMOVED***$0.downloadDirectoryURL.deletingPathExtension().lastPathComponent == preplannedMapAreaID
***REMOVED******REMOVED***
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
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the status based on the download result of the mobile map package.
***REMOVED***private func updateDownloadStatus(for downloadResult: Result<DownloadPreplannedOfflineMapResult, any Error>?) {
***REMOVED******REMOVED***switch downloadResult {
***REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED***status = .downloaded
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***status = .downloadFailure(error)
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Looks in the  mobile map package if downloaded locally.
***REMOVED***private func lookupMobileMapPackage() -> MobileMapPackage? {
***REMOVED******REMOVED***let fileURL = FileManager.default.mmpkDirectory(forPortalItemID: portalItemID, preplannedMapAreaID: preplannedMapAreaID)
***REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: fileURL.relativePath) else { return nil ***REMOVED***
***REMOVED******REMOVED***return MobileMapPackage.init(fileURL: fileURL)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Posts a local notification that the job completed with success or failure.
***REMOVED******REMOVED***/ - Precondition: `job.status == .succeeded || job.status == .failed`
***REMOVED***private static func notifyJobCompleted(job: DownloadPreplannedOfflineMapJob) {
***REMOVED******REMOVED***precondition(job.status == .succeeded || job.status == .failed)
***REMOVED******REMOVED***guard
***REMOVED******REMOVED******REMOVED***let preplannedMapArea = job.parameters.preplannedMapArea,
***REMOVED******REMOVED******REMOVED***let id = preplannedMapArea.id
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let content = UNMutableNotificationContent()
***REMOVED******REMOVED***content.sound = UNNotificationSound.default
***REMOVED******REMOVED***
***REMOVED******REMOVED***let jobStatus = job.status == .succeeded ? "Succeeded" : "Failed"
***REMOVED******REMOVED***
***REMOVED******REMOVED***content.title = "Download \(jobStatus)"
***REMOVED******REMOVED***content.body = "The job for \(preplannedMapArea.title) has \(jobStatus.lowercased())."
***REMOVED******REMOVED***
***REMOVED******REMOVED***let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
***REMOVED******REMOVED***let identifier = id.rawValue
***REMOVED******REMOVED***let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
***REMOVED******REMOVED***
***REMOVED******REMOVED***UNUserNotificationCenter.current().add(request)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Downloads the preplanned map area.
***REMOVED******REMOVED***/ - Precondition: `canDownload`
***REMOVED***func downloadPreplannedMapArea() async {
***REMOVED******REMOVED***precondition(canDownload)
***REMOVED******REMOVED***status = .downloading
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***guard let parameters = try await preplannedMapArea.makeParameters(using: offlineMapTask) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***let mmpkDirectory = FileManager.default.mmpkDirectory(forPortalItemID: portalItemID, preplannedMapAreaID: preplannedMapAreaID)
***REMOVED******REMOVED******REMOVED***try FileManager.default.createDirectory(at: mmpkDirectory, withIntermediateDirectories: true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Create the download preplanned offline map job.
***REMOVED******REMOVED******REMOVED***let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
***REMOVED******REMOVED******REMOVED******REMOVED***parameters: parameters,
***REMOVED******REMOVED******REMOVED******REMOVED***downloadDirectory: mmpkDirectory
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***JobManager.shared.jobs.append(job)
***REMOVED******REMOVED******REMOVED***startAndObserveJob(job)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***status = .downloadFailure(error)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the job property of this instance, starts the job, observes it, and
***REMOVED******REMOVED***/ when it's done, updates the status, removes the job from the job manager,
***REMOVED******REMOVED***/ and fires a user notification.
***REMOVED***private func startAndObserveJob(_ job: DownloadPreplannedOfflineMapJob) {
***REMOVED******REMOVED***print("-- starting job: \(job.parameters.preplannedMapArea?.title ?? "")")
***REMOVED******REMOVED***self.job = job
***REMOVED******REMOVED***job.start()
***REMOVED******REMOVED***status = .downloading
***REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED***print("-- job complete: \(job.parameters.preplannedMapArea?.title ?? ""), status: \(job.status)")
***REMOVED******REMOVED******REMOVED***let result = await job.result
***REMOVED******REMOVED******REMOVED***updateDownloadStatus(for: result)
***REMOVED******REMOVED******REMOVED***mobileMapPackage = try? result.map { $0.mobileMapPackage ***REMOVED***.get()
***REMOVED******REMOVED******REMOVED***JobManager.shared.jobs.removeAll { $0 === job ***REMOVED***
***REMOVED******REMOVED******REMOVED***if job.status == .succeeded || job.status == .failed {
***REMOVED******REMOVED******REMOVED******REMOVED***Self.notifyJobCompleted(job: job)
***REMOVED******REMOVED***
***REMOVED***
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
***REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters?
***REMOVED***
***REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? { get ***REMOVED***
***REMOVED***var title: String { get ***REMOVED***
***REMOVED***var description: String { get ***REMOVED***
***REMOVED***var thumbnail: LoadableImage? { get ***REMOVED***
***REMOVED***var id: PortalItem.ID? { get ***REMOVED***
***REMOVED***

***REMOVED***/ Extend `PreplannedMapArea` to conform to `PreplannedMapAreaProtocol`.
extension PreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters? {
***REMOVED******REMOVED******REMOVED*** Create the parameters for the download preplanned offline map job.
***REMOVED******REMOVED***let parameters = try await offlineMapTask.makeDefaultDownloadPreplannedOfflineMapParameters(
***REMOVED******REMOVED******REMOVED***preplannedMapArea: self
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** Set the update mode to no updates as the offline map is display-only.
***REMOVED******REMOVED***parameters.updateMode = .noUpdates
***REMOVED******REMOVED***
***REMOVED******REMOVED***return parameters
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

private extension FileManager {
***REMOVED***private static let mmpkPathExtension: String = "mmpk"
***REMOVED***private static let offlineMapAreasPath: String = "OfflineMapAreas"
***REMOVED***private static let packageDirectoryPath: String = "Package"
***REMOVED***private static let preplannedDirectoryPath: String = "Preplanned"
***REMOVED***
***REMOVED******REMOVED***/ The path to the documents folder.
***REMOVED***private var documentsDirectory: URL {
***REMOVED******REMOVED***URL.documentsDirectory
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the offline map areas directory within the documents directory.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas`
***REMOVED***private var offlineMapAreasDirectory: URL {
***REMOVED******REMOVED***documentsDirectory.appending(
***REMOVED******REMOVED******REMOVED***path: Self.offlineMapAreasPath,
***REMOVED******REMOVED******REMOVED***directoryHint: .isDirectory
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the web map directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>`
***REMOVED******REMOVED***/ - Parameter portalItemID: The ID of the web map portal item.
***REMOVED***private func portalItemDirectory(forPortalItemID portalItemID: String) -> URL {
***REMOVED******REMOVED***offlineMapAreasDirectory.appending(path: portalItemID, directoryHint: .isDirectory)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the preplanned map areas directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/<Preplanned Area ID>`
***REMOVED******REMOVED***/ - Parameter portalItemID: The ID of the web map portal item.
***REMOVED***private func preplannedDirectory(forPortalItemID portalItemID: String, preplannedMapAreaID: String) -> URL {
***REMOVED******REMOVED***portalItemDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***.appending(
***REMOVED******REMOVED******REMOVED******REMOVED***path: Self.preplannedDirectoryPath,
***REMOVED******REMOVED******REMOVED******REMOVED***directoryHint: .isDirectory
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.appending(
***REMOVED******REMOVED******REMOVED******REMOVED***path: preplannedMapAreaID,
***REMOVED******REMOVED******REMOVED******REMOVED***directoryHint: .isDirectory
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the mobile map package file for the preplanned map area mobile map package.
***REMOVED******REMOVED***/ Path structure
***REMOVED******REMOVED***/ Documents/OfflineMapAreas/<portal item id>/Preplanned/<preplanned area id>/<preplanned area id>.mmpk
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - portalItemID: The ID of the web map portal item.
***REMOVED******REMOVED***/   - preplannedMapAreaID: The ID of the preplanned map area.
***REMOVED***func mmpkDirectory(forPortalItemID portalItemID: String, preplannedMapAreaID: String) -> URL {
***REMOVED******REMOVED***preplannedDirectory(forPortalItemID: portalItemID, preplannedMapAreaID: preplannedMapAreaID)
***REMOVED******REMOVED******REMOVED***.appendingPathComponent(preplannedMapAreaID)
***REMOVED******REMOVED******REMOVED***.appendingPathExtension(Self.mmpkPathExtension)
***REMOVED***
***REMOVED***
