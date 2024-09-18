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
import OSLog
***REMOVED***

***REMOVED***/ An object that encapsulates state about a preplanned map.
@MainActor
class PreplannedMapModel: ObservableObject, Identifiable {
***REMOVED******REMOVED***/ The preplanned map area.
***REMOVED***let preplannedMapArea: any PreplannedMapAreaProtocol
***REMOVED***
***REMOVED******REMOVED***/ The ID of the preplanned map area.
***REMOVED***let preplannedMapAreaID: PortalItem.ID
***REMOVED***
***REMOVED******REMOVED***/ The mobile map package directory URL.
***REMOVED***private let mmpkDirectoryURL: URL
***REMOVED***
***REMOVED******REMOVED***/ The task to use to take the area offline.
***REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED***
***REMOVED******REMOVED***/ The ID of the web map.
***REMOVED***private let portalItemID: PortalItem.ID
***REMOVED***
***REMOVED******REMOVED***/ The mobile map package for the preplanned map area.
***REMOVED***private var mobileMapPackage: MobileMapPackage?
***REMOVED***
***REMOVED******REMOVED***/ The file size of the preplanned map area.
***REMOVED***private(set) var directorySize = 0
***REMOVED***
***REMOVED******REMOVED***/ The currently running download job.
***REMOVED***@Published private(set) var job: DownloadPreplannedOfflineMapJob?
***REMOVED***
***REMOVED******REMOVED***/ The combined status of the preplanned map area.
***REMOVED***@Published private(set) var status: Status = .notLoaded
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if a user notification should be shown when a job completes.
***REMOVED***let showsUserNotificationOnCompletion: Bool
***REMOVED***
***REMOVED******REMOVED***/ The first map from the mobile map package.
***REMOVED***var map: Map? { 
***REMOVED******REMOVED***get async {
***REMOVED******REMOVED******REMOVED***if let mobileMapPackage {
***REMOVED******REMOVED******REMOVED******REMOVED***if mobileMapPackage.loadStatus != .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await mobileMapPackage.load()
***REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***status = .mmpkLoadFailure(error)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***return mobileMapPackage.maps.first
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED***mapArea: PreplannedMapAreaProtocol,
***REMOVED******REMOVED***portalItemID: PortalItem.ID,
***REMOVED******REMOVED***preplannedMapAreaID: PortalItem.ID,
***REMOVED******REMOVED***showsUserNotificationOnCompletion: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***self.offlineMapTask = offlineMapTask
***REMOVED******REMOVED***preplannedMapArea = mapArea
***REMOVED******REMOVED***self.portalItemID = portalItemID
***REMOVED******REMOVED***self.preplannedMapAreaID = preplannedMapAreaID
***REMOVED******REMOVED***mmpkDirectoryURL = FileManager.default.preplannedDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.showsUserNotificationOnCompletion = showsUserNotificationOnCompletion
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let foundJob = lookupDownloadJob() {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Found executing job for area \(preplannedMapAreaID.rawValue, privacy: .public)")
***REMOVED******REMOVED******REMOVED***observeJob(foundJob)
***REMOVED*** else if let mmpk = lookupMobileMapPackage() {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Found MMPK for area \(preplannedMapAreaID.rawValue, privacy: .public)")
***REMOVED******REMOVED******REMOVED***mobileMapPackage = mmpk
***REMOVED******REMOVED******REMOVED***directorySize = FileManager.default.sizeOfDirectory(at: mmpkDirectoryURL)
***REMOVED******REMOVED******REMOVED***status = .downloaded
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
***REMOVED******REMOVED******REMOVED***status = preplannedMapArea.packagingStatus.map(Status.init) ?? .packaged
***REMOVED*** catch MappingError.packagingNotComplete {
***REMOVED******REMOVED******REMOVED******REMOVED*** Load will throw an `MappingError.packagingNotComplete` error if not complete,
***REMOVED******REMOVED******REMOVED******REMOVED*** this case is not a normal load failure.
***REMOVED******REMOVED******REMOVED***status = preplannedMapArea.packagingStatus.map(Status.init) ?? .packageFailure
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED*** Normal load failure.
***REMOVED******REMOVED******REMOVED***status = .loadFailure(error)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Look up the job associated with this preplanned map model.
***REMOVED***private func lookupDownloadJob() -> DownloadPreplannedOfflineMapJob? {
***REMOVED******REMOVED***OfflineManager.shared.jobs
***REMOVED******REMOVED******REMOVED***.lazy
***REMOVED******REMOVED******REMOVED***.compactMap { $0 as? DownloadPreplannedOfflineMapJob ***REMOVED***
***REMOVED******REMOVED******REMOVED***.first {
***REMOVED******REMOVED******REMOVED******REMOVED***$0.downloadDirectoryURL.deletingPathExtension().lastPathComponent == preplannedMapAreaID.rawValue
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the status based on the download result of the mobile map package.
***REMOVED***func updateDownloadStatus(for downloadResult: Result<DownloadPreplannedOfflineMapResult, any Error>) {
***REMOVED******REMOVED***switch downloadResult {
***REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED***status = .downloaded
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***status = .downloadFailure(error)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Looks up the mobile map package directory for locally downloaded package.
***REMOVED***private func lookupMobileMapPackage() -> MobileMapPackage? {
***REMOVED******REMOVED***let fileURL = FileManager.default.preplannedDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED***)
***REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure the directory is not empty because the directory will exist as soon as the
***REMOVED******REMOVED******REMOVED*** job starts, so if the job fails, it will look like the mmpk was downloaded.
***REMOVED******REMOVED***guard !FileManager.default.isDirectoryEmpty(atPath: fileURL) else { return nil ***REMOVED***
***REMOVED******REMOVED***return MobileMapPackage(fileURL: fileURL)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Downloads the preplanned map area.
***REMOVED******REMOVED***/ - Precondition: `canDownload`
***REMOVED***func downloadPreplannedMapArea() async {
***REMOVED******REMOVED***precondition(status.allowsDownload)
***REMOVED******REMOVED***status = .downloading
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let parameters = try await preplannedMapArea.makeParameters(using: offlineMapTask)
***REMOVED******REMOVED******REMOVED***try FileManager.default.createDirectory(at: mmpkDirectoryURL, withIntermediateDirectories: true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Create the download preplanned offline map job.
***REMOVED******REMOVED******REMOVED***let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
***REMOVED******REMOVED******REMOVED******REMOVED***parameters: parameters,
***REMOVED******REMOVED******REMOVED******REMOVED***downloadDirectory: mmpkDirectoryURL
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.start(job: job)
***REMOVED******REMOVED******REMOVED***observeJob(job)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***status = .downloadFailure(error)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Removes the downloaded preplanned map area from disk and resets the status.
***REMOVED***func removeDownloadedPreplannedMapArea() {
***REMOVED******REMOVED***try? FileManager.default.removeItem(at: mmpkDirectoryURL)
***REMOVED******REMOVED******REMOVED*** Reload the model after local files removal.
***REMOVED******REMOVED***status = .notLoaded
***REMOVED******REMOVED***Task { await load() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the job property of this instance, starts the job, observes it, and
***REMOVED******REMOVED***/ when it's done, updates the status, removes the job from the job manager,
***REMOVED******REMOVED***/ and fires a user notification.
***REMOVED***private func observeJob(_ job: DownloadPreplannedOfflineMapJob) {
***REMOVED******REMOVED***self.job = job
***REMOVED******REMOVED***status = .downloading
***REMOVED******REMOVED***Task { [weak self, job] in
***REMOVED******REMOVED******REMOVED***let result = await job.result
***REMOVED******REMOVED******REMOVED***guard let self else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***self.updateDownloadStatus(for: result)
***REMOVED******REMOVED******REMOVED***if status.isDownloaded {
***REMOVED******REMOVED******REMOVED******REMOVED***self.mobileMapPackage = try? result.get().mobileMapPackage
***REMOVED******REMOVED******REMOVED******REMOVED***self.directorySize = FileManager.default.sizeOfDirectory(at: mmpkDirectoryURL)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.job = nil
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
***REMOVED******REMOVED******REMOVED***/ Downloaded mobile map package failed to load.
***REMOVED******REMOVED***case mmpkLoadFailure(Error)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the model is in a state
***REMOVED******REMOVED******REMOVED***/ where it needs to be loaded or reloaded.
***REMOVED******REMOVED***var needsToBeLoaded: Bool {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .loading, .packaging, .packaged, .downloading, .downloaded, .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating if download is allowed for this status.
***REMOVED******REMOVED***var allowsDownload: Bool {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .loading, .loadFailure, .packaging, .packageFailure,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.downloading, .downloaded, .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED******REMOVED***case .packaged, .downloadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the local files can be removed.
***REMOVED******REMOVED***var allowsRemoval: Bool {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .downloaded, .mmpkLoadFailure, .downloadFailure, .loadFailure, .packageFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the preplanned map area is downloaded.
***REMOVED******REMOVED***var isDownloaded: Bool {
***REMOVED******REMOVED******REMOVED***if case .downloaded = self { true ***REMOVED*** else { false ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension PreplannedMapModel.Status {
***REMOVED***init(packagingStatus: PreplannedMapArea.PackagingStatus) {
***REMOVED******REMOVED***self = switch packagingStatus {
***REMOVED******REMOVED***case .processing: .packaging
***REMOVED******REMOVED***case .failed: .packageFailure
***REMOVED******REMOVED***case .complete: .packaged
***REMOVED******REMOVED***@unknown default: fatalError("Unknown case")
***REMOVED***
***REMOVED***
***REMOVED***

extension PreplannedMapModel: Equatable {
***REMOVED***nonisolated static func == (lhs: PreplannedMapModel, rhs: PreplannedMapModel) -> Bool {
***REMOVED******REMOVED***return lhs === rhs
***REMOVED***
***REMOVED***

extension PreplannedMapModel: Hashable {
***REMOVED***nonisolated func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(ObjectIdentifier(self))
***REMOVED***
***REMOVED***

***REMOVED***/ A type that acts as a preplanned map area.
protocol PreplannedMapAreaProtocol: Sendable {
***REMOVED***func retryLoad() async throws
***REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters
***REMOVED***
***REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? { get ***REMOVED***
***REMOVED***var title: String { get ***REMOVED***
***REMOVED***var description: String { get ***REMOVED***
***REMOVED***var thumbnail: LoadableImage? { get ***REMOVED***
***REMOVED***

***REMOVED***/ Extend `PreplannedMapArea` to conform to `PreplannedMapAreaProtocol`.
extension PreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
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

package extension FileManager {
***REMOVED******REMOVED***/ The path to the documents folder.
***REMOVED***private var documentsDirectory: URL {
***REMOVED******REMOVED***URL.documentsDirectory
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the offline map areas directory within the documents directory.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/`
***REMOVED***private var offlineMapAreasDirectory: URL {
***REMOVED******REMOVED***documentsDirectory.appending(component: "OfflineMapAreas/")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the web map directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>/`
***REMOVED******REMOVED***/ - Parameter portalItemID: The ID of the web map portal item.
***REMOVED***private func portalItemDirectory(forPortalItemID portalItemID: PortalItem.ID) -> URL {
***REMOVED******REMOVED***offlineMapAreasDirectory.appending(component: "\(portalItemID)/")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Calculates the size of a directory and all its contents.
***REMOVED******REMOVED***/ - Parameter url: The directory's URL.
***REMOVED******REMOVED***/ - Returns: The total size in bytes.
***REMOVED***func sizeOfDirectory(at url: URL) -> Int {
***REMOVED******REMOVED***guard let enumerator = enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 ***REMOVED***
***REMOVED******REMOVED***var accumulatedSize = 0
***REMOVED******REMOVED***for case let fileURL as URL in enumerator {
***REMOVED******REMOVED******REMOVED***guard let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
***REMOVED******REMOVED******REMOVED******REMOVED***continue
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***accumulatedSize += size
***REMOVED***
***REMOVED******REMOVED***return accumulatedSize
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the preplanned map areas directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/`
***REMOVED******REMOVED***/ - Parameter portalItemID: The ID of the web map portal item.
***REMOVED***func preplannedDirectory(
***REMOVED******REMOVED***forPortalItemID portalItemID: PortalItem.ID
***REMOVED***) -> URL {
***REMOVED******REMOVED***portalItemDirectory(forPortalItemID: portalItemID).appending(component: "Preplanned/")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the directory for a specific map area from the preplanned map areas directory for a specific portal item.
***REMOVED******REMOVED***/ `Documents/OfflineMapAreas/<Portal Item ID>/Preplanned/<Preplanned Area ID>/`
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - portalItemID: The ID of the web map portal item.
***REMOVED******REMOVED***/   - preplannedMapAreaID: The ID of the preplanned map area portal item.
***REMOVED******REMOVED***/ - Returns: A URL to the preplanned map area directory.
***REMOVED***func preplannedDirectory(
***REMOVED******REMOVED***forPortalItemID portalItemID: PortalItem.ID,
***REMOVED******REMOVED***preplannedMapAreaID: PortalItem.ID
***REMOVED***) -> URL {
***REMOVED******REMOVED***portalItemDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***.appending(components: "Preplanned", "\(preplannedMapAreaID)/")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a Boolean value indicating if the specified directory is empty.
***REMOVED******REMOVED***/ - Parameter path: The path to check.
***REMOVED***func isDirectoryEmpty(atPath path: URL) -> Bool {
***REMOVED******REMOVED***(try? FileManager.default.contentsOfDirectory(atPath: path.path()).isEmpty) ?? true
***REMOVED***
***REMOVED***
