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
import Combine
import Foundation

internal import os

***REMOVED***/ An object that encapsulates state about a preplanned map.
@MainActor
class PreplannedMapModel: ObservableObject, Identifiable {
***REMOVED******REMOVED***/ The preplanned map area.
***REMOVED***let preplannedMapArea: any PreplannedMapAreaProtocol
***REMOVED***
***REMOVED******REMOVED***/ The ID of the preplanned map area.
***REMOVED***let preplannedMapAreaID: Item.ID
***REMOVED***
***REMOVED******REMOVED***/ The mobile map package directory URL.
***REMOVED***private let mmpkDirectoryURL: URL
***REMOVED***
***REMOVED******REMOVED***/ The task to use to take the area offline.
***REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED***
***REMOVED******REMOVED***/ The ID of the online map.
***REMOVED***private let portalItemID: Item.ID
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when a preplanned map area is deleted.
***REMOVED***private let onRemoveDownloadAction: () -> Void
***REMOVED***
***REMOVED******REMOVED***/ The mobile map package for the preplanned map area.
***REMOVED***@Published private(set) var mobileMapPackage: MobileMapPackage?
***REMOVED***
***REMOVED******REMOVED***/ The file size of the preplanned map area.
***REMOVED***@Published private(set) var directorySize = 0
***REMOVED***
***REMOVED******REMOVED***/ The currently running download job.
***REMOVED***@Published private(set) var job: DownloadPreplannedOfflineMapJob?
***REMOVED***
***REMOVED******REMOVED***/ The combined status of the preplanned map area.
***REMOVED***@Published private(set) var status: Status = .notLoaded {
***REMOVED******REMOVED***willSet {
***REMOVED******REMOVED******REMOVED***let statusString = "\(newValue)"
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Setting status to \(statusString) for area \(self.preplannedMapAreaID.rawValue)")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The first map from the mobile map package.
***REMOVED***@Published private(set) var map: Map?
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED***mapArea: PreplannedMapAreaProtocol,
***REMOVED******REMOVED***portalItemID: Item.ID,
***REMOVED******REMOVED***preplannedMapAreaID: Item.ID,
***REMOVED******REMOVED***onRemoveDownload: @escaping () -> Void
***REMOVED***) {
***REMOVED******REMOVED***self.offlineMapTask = offlineMapTask
***REMOVED******REMOVED***preplannedMapArea = mapArea
***REMOVED******REMOVED***self.portalItemID = portalItemID
***REMOVED******REMOVED***self.preplannedMapAreaID = preplannedMapAreaID
***REMOVED******REMOVED***self.onRemoveDownloadAction = onRemoveDownload
***REMOVED******REMOVED***
***REMOVED******REMOVED***mmpkDirectoryURL = .preplannedDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Depending on the state, this either:
***REMOVED******REMOVED***/ - observes an in-flight job
***REMOVED******REMOVED***/ - looks up the mobile map package if it exists on disk
***REMOVED******REMOVED***/ - loads the pre-planned map area
***REMOVED***func load() async {
***REMOVED******REMOVED***if job == nil, let foundJob = lookupDownloadJob() {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Found executing job for preplanned area \(self.preplannedMapAreaID.rawValue)")
***REMOVED******REMOVED******REMOVED***observeJob(foundJob)
***REMOVED*** else if mobileMapPackage == nil, let mmpk = lookupMobileMapPackage() {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Found MMPK for area \(self.preplannedMapAreaID.rawValue)")
***REMOVED******REMOVED******REMOVED***await self.loadAndUpdateMobileMapPackage(mmpk: mmpk)
***REMOVED*** else if status.canLoadPreplannedMapArea {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Loading preplanned map area for \(self.preplannedMapAreaID.rawValue)")
***REMOVED******REMOVED******REMOVED***await loadPreplannedMapArea()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Already loaded for preplanned map area \(self.preplannedMapAreaID.rawValue)")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the preplanned map area.
***REMOVED***private func loadPreplannedMapArea() async {
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
***REMOVED******REMOVED***/ Tries to load a mobile map package and if successful, then updates state
***REMOVED******REMOVED***/ associated with it.
***REMOVED***private func loadAndUpdateMobileMapPackage(mmpk: MobileMapPackage) async {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await mmpk.load()
***REMOVED******REMOVED******REMOVED***status = .downloaded
***REMOVED******REMOVED******REMOVED***mobileMapPackage = mmpk
***REMOVED******REMOVED******REMOVED***directorySize = FileManager.default.sizeOfDirectory(at: mmpkDirectoryURL)
***REMOVED******REMOVED******REMOVED***map = mmpk.maps.first
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***status = .mmpkLoadFailure(error)
***REMOVED******REMOVED******REMOVED***mobileMapPackage = nil
***REMOVED******REMOVED******REMOVED***directorySize = 0
***REMOVED******REMOVED******REMOVED***map = nil
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
***REMOVED******REMOVED***/ Looks up the mobile map package directory for locally downloaded package.
***REMOVED***private func lookupMobileMapPackage() -> MobileMapPackage? {
***REMOVED******REMOVED***let fileURL = URL.preplannedDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED***)
***REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED***return MobileMapPackage(fileURL: fileURL)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Downloads the preplanned map area.
***REMOVED******REMOVED***/ - Precondition: `allowsDownload == true`
***REMOVED***func downloadPreplannedMapArea() async {
***REMOVED******REMOVED***precondition(status.allowsDownload)
***REMOVED******REMOVED***
***REMOVED******REMOVED***status = .downloading
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
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.start(job: job, portalItem: offlineMapTask.portalItem!)
***REMOVED******REMOVED******REMOVED***observeJob(job)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***status = .downloadFailure(error)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Removes the downloaded preplanned map area from disk and resets the status.
***REMOVED***func removeDownloadedPreplannedMapArea() {
***REMOVED******REMOVED***try? FileManager.default.removeItem(at: mmpkDirectoryURL)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Reload the model after local files removal.
***REMOVED******REMOVED***status = .notLoaded
***REMOVED******REMOVED***Task { await load() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Call the closure for the remove download action.
***REMOVED******REMOVED***onRemoveDownloadAction()
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
***REMOVED******REMOVED******REMOVED***if let mmpk = try? result.get().mobileMapPackage {
***REMOVED******REMOVED******REMOVED******REMOVED***await loadAndUpdateMobileMapPackage(mmpk: mmpk)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.job = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the status based on the download result of the mobile map package.
***REMOVED***private func updateDownloadStatus(for downloadResult: Result<DownloadPreplannedOfflineMapResult, any Error>) {
***REMOVED******REMOVED***switch downloadResult {
***REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED***status = .downloaded
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***status = .downloadFailure(error)
***REMOVED******REMOVED******REMOVED******REMOVED*** Remove contents of mmpk directory when download fails.
***REMOVED******REMOVED******REMOVED***try? FileManager.default.removeItem(at: mmpkDirectoryURL)
***REMOVED***
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
***REMOVED******REMOVED******REMOVED***/ where it can load the preplanned map area.
***REMOVED******REMOVED***var canLoadPreplannedMapArea: Bool {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .loadFailure, .packageFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED******REMOVED***case .loading, .packaging, .packaged, .downloading, .downloaded, .mmpkLoadFailure, .downloadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***false
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
***REMOVED******REMOVED******REMOVED*** Remove HTML tags from description.
***REMOVED******REMOVED***portalItem.description.replacing(/<[^>]+>/, with: "")
***REMOVED***
***REMOVED***

***REMOVED***/ A value that contains the result of loading the preplanned map models for
***REMOVED***/ a given online map.
struct PreplannedModels {
***REMOVED******REMOVED***/ The result of loading the preplanned models.
***REMOVED***let result: Result<[PreplannedMapModel], Error>
***REMOVED******REMOVED***/ A Boolean value indicating if only offline models are available.
***REMOVED***let onlyOfflineModelsAreAvailable: Bool
***REMOVED***

extension PreplannedMapModel {
***REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and loads the map models.
***REMOVED***static func loadPreplannedMapModels(
***REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED***portalItemID: Item.ID,
***REMOVED******REMOVED***onRemoveDownload: @escaping () -> Void
***REMOVED***) async -> PreplannedModels {
***REMOVED******REMOVED***if offlineMapTask.loadStatus != .loaded {
***REMOVED******REMOVED******REMOVED***try? await offlineMapTask.retryLoad()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var onlyOfflineModelsAreAvailable = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***let result = await Result { @MainActor in
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***return try await offlineMapTask.preplannedMapAreas
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.filter { $0.portalItem.id != nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sorted(using: KeyPathComparator(\.portalItem.title))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapArea: $0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: $0.portalItem.id!,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onRemoveDownload: onRemoveDownload
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If not connected to the internet, then return only the offline models.
***REMOVED******REMOVED******REMOVED******REMOVED***if let urlError = error as? URLError,
***REMOVED******REMOVED******REMOVED******REMOVED***   urlError.code == .notConnectedToInternet {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onlyOfflineModelsAreAvailable = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return await loadOfflinePreplannedMapModels(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onRemoveDownload: onRemoveDownload
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***throw error
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return .init(result: result, onlyOfflineModelsAreAvailable: onlyOfflineModelsAreAvailable)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the offline preplanned map models with information from the downloaded mobile map
***REMOVED******REMOVED***/ packages for the online map.
***REMOVED***private static func loadOfflinePreplannedMapModels(
***REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED***portalItemID: Item.ID,
***REMOVED******REMOVED***onRemoveDownload: @escaping () -> Void
***REMOVED***) async -> [PreplannedMapModel] {
***REMOVED******REMOVED***let preplannedDirectory = URL.preplannedDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: preplannedDirectory.path()) else { return [] ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var preplannedMapModels: [PreplannedMapModel] = []
***REMOVED******REMOVED***
***REMOVED******REMOVED***for mapAreaID in mapAreaIDs {
***REMOVED******REMOVED******REMOVED***guard let preplannedMapAreaID = Item.ID(mapAreaID),
***REMOVED******REMOVED******REMOVED******REMOVED***  let mapArea = await makeMapArea(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED******REMOVED******REMOVED***  ) else {
***REMOVED******REMOVED******REMOVED******REMOVED***continue
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED***mapArea: mapArea,
***REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: mapArea.id!,
***REMOVED******REMOVED******REMOVED******REMOVED***onRemoveDownload: onRemoveDownload
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***preplannedMapModels.append(model)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return preplannedMapModels
***REMOVED******REMOVED******REMOVED***.sorted(by: { $0.preplannedMapArea.title < $1.preplannedMapArea.title ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a preplanned map area using a given portal item and map area ID to search for a corresponding
***REMOVED******REMOVED***/ downloaded mobile map package. If the mobile map package is not found then `nil` is returned.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - portalItemID: The portal item ID.
***REMOVED******REMOVED***/   - preplannedMapAreaID: The preplanned map area ID.
***REMOVED******REMOVED***/ - Returns: The preplanned map area.
***REMOVED***private static func makeMapArea(
***REMOVED******REMOVED***portalItemID: Item.ID,
***REMOVED******REMOVED***preplannedMapAreaID: Item.ID
***REMOVED***) async -> OfflinePreplannedMapArea? {
***REMOVED******REMOVED***let fileURL = URL.preplannedDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED***)
***REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED***let mmpk = MobileMapPackage(fileURL: fileURL)
***REMOVED******REMOVED***
***REMOVED******REMOVED***try? await mmpk.load()
***REMOVED******REMOVED***guard let item = mmpk.item else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return .init(
***REMOVED******REMOVED******REMOVED***title: item.title,
***REMOVED******REMOVED******REMOVED***description: item.description,
***REMOVED******REMOVED******REMOVED***id: preplannedMapAreaID,
***REMOVED******REMOVED******REMOVED***thumbnail: item.thumbnail
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private struct OfflinePreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED***var title: String
***REMOVED***var description: String
***REMOVED***var id: Item.ID?
***REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus?
***REMOVED***var thumbnail: LoadableImage?
***REMOVED***
***REMOVED***func retryLoad() async throws {***REMOVED***
***REMOVED***
***REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
***REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
