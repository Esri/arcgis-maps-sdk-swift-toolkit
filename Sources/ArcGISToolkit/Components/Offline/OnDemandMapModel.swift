***REMOVED*** Copyright 2025 Esri
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
import UIKit
internal import os

@MainActor
class OnDemandMapModel: ObservableObject, Identifiable {
***REMOVED***let configuration: OnDemandMapAreaConfiguration?
***REMOVED***
***REMOVED******REMOVED***/ The mobile map package directory URL.
***REMOVED***let mmpkDirectoryURL: URL
***REMOVED***
***REMOVED******REMOVED***/ The task to use to take the area offline.
***REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED***
***REMOVED******REMOVED***/ The ID of the online map.
***REMOVED***private let portalItemID: Item.ID
***REMOVED***
***REMOVED***let title: String
***REMOVED***
***REMOVED***let areaID: UUID
***REMOVED***
***REMOVED***@Published private(set) var description: String = ""
***REMOVED***
***REMOVED***@Published private(set) var thumbnail: LoadableImage?
***REMOVED***
***REMOVED******REMOVED***/ The on-demand map area.
***REMOVED******REMOVED***@Published private(set) var mapArea: OfflineOnDemandMapArea?
***REMOVED***
***REMOVED******REMOVED***/ The mobile map package for the preplanned map area.
***REMOVED***@Published private(set) var mobileMapPackage: MobileMapPackage?
***REMOVED***
***REMOVED******REMOVED***/ The file size of the on-demand map area.
***REMOVED***@Published private(set) var directorySize = 0
***REMOVED***
***REMOVED******REMOVED***/ The currently running offline map job.
***REMOVED***@Published private(set) var job: GenerateOfflineMapJob?
***REMOVED***
***REMOVED******REMOVED***/ The combined status of the on-demand map area.
***REMOVED***@Published private(set) var status: Status = .initialized
***REMOVED***
***REMOVED******REMOVED***/ The first map from the mobile map package.
***REMOVED***@Published private(set) var map: Map?
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED***configuration: OnDemandMapAreaConfiguration,
***REMOVED******REMOVED***portalItemID: PortalItem.ID
***REMOVED***) {
***REMOVED******REMOVED***self.configuration = configuration
***REMOVED******REMOVED***self.offlineMapTask = offlineMapTask
***REMOVED******REMOVED***self.portalItemID = portalItemID
***REMOVED******REMOVED***self.title = configuration.title
***REMOVED******REMOVED***self.areaID = configuration.id
***REMOVED******REMOVED***mmpkDirectoryURL = .onDemandDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onDemandMapAreaID: configuration.id
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***init(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED******REMOVED***mapArea: OfflineOnDemandMapArea,
***REMOVED******REMOVED******REMOVED***portalItemID: PortalItem.ID
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***self.configuration = nil
***REMOVED******REMOVED******REMOVED***self.mapArea = mapArea
***REMOVED******REMOVED******REMOVED***self.offlineMapTask = offlineMapTask
***REMOVED******REMOVED******REMOVED***self.portalItemID = portalItemID
***REMOVED******REMOVED******REMOVED***mmpkDirectoryURL = .onDemandDirectory(
***REMOVED******REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapAreaID: onDemandMapArea.id
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let foundJob = lookupDownloadJob() {
***REMOVED******REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Found executing job for on-demand area \(mapArea.id.uuidString, privacy: .public)")
***REMOVED******REMOVED******REMOVED******REMOVED***observeJob(foundJob)
***REMOVED******REMOVED*** else if let mmpk = lookupMobileMapPackage() {
***REMOVED******REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Found MMPK for area \(mapArea.id.uuidString, privacy: .public)")
***REMOVED******REMOVED******REMOVED******REMOVED***Task.detached { await self.loadAndUpdateMobileMapPackage(mmpk: mmpk) ***REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***status = .initialized
***REMOVED******REMOVED***
***REMOVED******REMOVED***
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
***REMOVED******REMOVED*** TODO:
***REMOVED******REMOVED******REMOVED***/ Look up the job associated with this map model.
***REMOVED******REMOVED***private func lookupDownloadJob() -> GenerateOfflineMapJob? {
***REMOVED******REMOVED******REMOVED***OfflineManager.shared.jobs
***REMOVED******REMOVED******REMOVED******REMOVED***.lazy
***REMOVED******REMOVED******REMOVED******REMOVED***.compactMap { $0 as? GenerateOfflineMapJob ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0.downloadDirectoryURL.deletingPathExtension().lastPathComponent == onDemandMapArea.id.uuidString
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***/ Looks up the mobile map package directory for downloaded package.
***REMOVED******REMOVED***private func lookupMobileMapPackage() -> MobileMapPackage? {
***REMOVED******REMOVED******REMOVED***let fileURL = URL.onDemandDirectory(
***REMOVED******REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapAreaID: onDemandMapArea.id
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***return MobileMapPackage(fileURL: fileURL)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Downloads the on-demand map area.
***REMOVED******REMOVED***/ - Precondition: `allowsDownload == true`
***REMOVED******REMOVED***/ - Precondition: `configuration != nil`
***REMOVED***func downloadOnDemandMapArea() async {
***REMOVED******REMOVED***precondition(status.allowsDownload)
***REMOVED******REMOVED***guard let configuration else { preconditionFailure() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***status = .downloading
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let parameters = try await offlineMapTask.makeDefaultGenerateOfflineMapParameters(
***REMOVED******REMOVED******REMOVED******REMOVED***areaOfInterest: configuration.areaOfInterest,
***REMOVED******REMOVED******REMOVED******REMOVED***minScale: configuration.minScale,
***REMOVED******REMOVED******REMOVED******REMOVED***maxScale: configuration.maxScale
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Set the update mode to no updates as the offline map is display-only.
***REMOVED******REMOVED******REMOVED***parameters.updateMode = .noUpdates
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Update item info on parameters
***REMOVED******REMOVED******REMOVED***if let itemInfo = parameters.itemInfo {
***REMOVED******REMOVED******REMOVED******REMOVED***itemInfo.title = configuration.title
***REMOVED******REMOVED******REMOVED******REMOVED***itemInfo.description = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Make sure the directory exists.
***REMOVED******REMOVED******REMOVED***try FileManager.default.createDirectory(at: mmpkDirectoryURL, withIntermediateDirectories: true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let job = offlineMapTask.makeGenerateOfflineMapJob(
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
***REMOVED******REMOVED***/ Removes the downloaded map area from disk and resets the status.
***REMOVED***func removeDownloadedOnDemandMapArea() {
***REMOVED******REMOVED***try? FileManager.default.removeItem(at: mmpkDirectoryURL)
***REMOVED******REMOVED***status = .initialized
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the job property of this instance, starts the job, observes it, and
***REMOVED******REMOVED***/ when it's done, updates the status, removes the job from the job manager,
***REMOVED******REMOVED***/ and fires a user notification.
***REMOVED***private func observeJob(_ job: GenerateOfflineMapJob) {
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
***REMOVED***private func updateDownloadStatus(for downloadResult: Result<GenerateOfflineMapResult, any Error>) {
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

extension OnDemandMapModel {
***REMOVED***
***REMOVED******REMOVED***private static func makeOnDemandMapArea(
***REMOVED******REMOVED******REMOVED***portalItemID: PortalItem.ID,
***REMOVED******REMOVED******REMOVED***onDemandMapAreaID: UUID
***REMOVED******REMOVED***) async -> OfflineOnDemandMapArea? {
***REMOVED******REMOVED******REMOVED***let fileURL = URL.onDemandDirectory(
***REMOVED******REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapAreaID: onDemandMapAreaID
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***let mmpk = MobileMapPackage(fileURL: fileURL)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***try? await mmpk.load()
***REMOVED******REMOVED******REMOVED***guard let item = mmpk.item else { return nil ***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***return .init(
***REMOVED******REMOVED******REMOVED******REMOVED***id: onDemandMapAreaID,
***REMOVED******REMOVED******REMOVED******REMOVED***title: item.title,
***REMOVED******REMOVED******REMOVED******REMOVED***description: item.description,
***REMOVED******REMOVED******REMOVED******REMOVED***thumbnail: item.thumbnail
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***static func loadModels(portalItemID: Item.ID) async -> [OnDemandMapModel] {
***REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED******REMOVED***let onDemandDirectory = URL.onDemandDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: onDemandDirectory.path()) else {
***REMOVED******REMOVED******REMOVED******REMOVED***return []
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var onDemandMapModels: [OnDemandMapModel] = []
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** TODO: this is happening here and also in OnDemandMapModel - that's not good.
***REMOVED******REMOVED******REMOVED******REMOVED*** Look up the ongoing jobs for on-demand map models.
***REMOVED******REMOVED******REMOVED***let ongoingJobs = OfflineManager.shared.jobs
***REMOVED******REMOVED******REMOVED******REMOVED***.lazy
***REMOVED******REMOVED******REMOVED******REMOVED***.compactMap { $0 as? GenerateOfflineMapJob ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.filter {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UUID(uuidString: $0.downloadDirectoryURL.deletingPathExtension().lastPathComponent) != nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***for job in ongoingJobs {
***REMOVED******REMOVED******REMOVED******REMOVED***let id = UUID(uuidString: job.downloadDirectoryURL.deletingPathExtension().lastPathComponent)!
***REMOVED******REMOVED******REMOVED******REMOVED***let parameters = job.parameters
***REMOVED******REMOVED******REMOVED******REMOVED***guard let info = parameters.itemInfo, let minScale = parameters.minScale, let maxScale = parameters.maxScale, let aoi = parameters.areaOfInterest else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continue
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let mapArea = OnDemandMapAreaConfiguration(id: id, title: info.title, minScale: minScale, maxScale: maxScale, areaOfInterest: aoi)
***REMOVED******REMOVED******REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapArea: mapArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapModels.append(model)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Look up the downloaded on-demand map models.
***REMOVED******REMOVED******REMOVED***for mapAreaID in mapAreaIDs {
***REMOVED******REMOVED******REMOVED******REMOVED***guard let onDemandMapAreaID = UUID(uuidString: mapAreaID),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let mapArea = await makeOnDemandMapArea(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapAreaID: onDemandMapAreaID
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  ) else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continue
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapArea: mapArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapModels.append(model)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.onDemandMapModels = onDemandMapModels
***REMOVED******REMOVED******REMOVED******REMOVED***.sorted(by: { $0.onDemandMapArea.title < $1.onDemandMapArea.title ***REMOVED***)
***REMOVED***
***REMOVED***

extension OnDemandMapModel {
***REMOVED******REMOVED***/ The status of the map area model.
***REMOVED***enum Status {
***REMOVED******REMOVED******REMOVED***/ The model is initialized but a job hasn't been started and the area has not been downloaded.
***REMOVED******REMOVED***case initialized
***REMOVED******REMOVED******REMOVED***/ Map area is being downloaded.
***REMOVED******REMOVED***case downloading
***REMOVED******REMOVED******REMOVED***/ Map area is downloaded.
***REMOVED******REMOVED***case downloaded
***REMOVED******REMOVED******REMOVED***/ Map area failed to download.
***REMOVED******REMOVED***case downloadFailure(Error)
***REMOVED******REMOVED******REMOVED***/ Downloaded mobile map package failed to load.
***REMOVED******REMOVED***case mmpkLoadFailure(Error)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the model is in a state
***REMOVED******REMOVED******REMOVED***/ where it needs to be loaded or reloaded.
***REMOVED******REMOVED***var needsToBeLoaded: Bool {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .downloading, .downloaded, .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating if download is allowed for this status.
***REMOVED******REMOVED***var allowsDownload: Bool {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .downloading, .downloaded, .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED******REMOVED***case .initialized, .downloadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the map area is downloaded.
***REMOVED******REMOVED***var isDownloaded: Bool {
***REMOVED******REMOVED******REMOVED***if case .downloaded = self { true ***REMOVED*** else { false ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension OnDemandMapModel: Equatable {
***REMOVED***nonisolated static func == (lhs: OnDemandMapModel, rhs: OnDemandMapModel) -> Bool {
***REMOVED******REMOVED***return lhs === rhs
***REMOVED***
***REMOVED***

extension OnDemandMapModel: Hashable {
***REMOVED***nonisolated func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(ObjectIdentifier(self))
***REMOVED***
***REMOVED***

***REMOVED*** A value that carries configuration for an on-demand map area.
struct OnDemandMapAreaConfiguration {
***REMOVED******REMOVED***/ A unique ID for the on-demand map area.
***REMOVED******REMOVED***/ TODO: what is this for?
***REMOVED***let id: UUID = UUID()
***REMOVED******REMOVED***/ A title for the offline area.
***REMOVED***let title: String
***REMOVED******REMOVED***/ The min-scale to take offline.
***REMOVED***let minScale: Double
***REMOVED******REMOVED***/ The max-scale to take offline.
***REMOVED***let maxScale: Double
***REMOVED******REMOVED***/ The area of interest to take offline.
***REMOVED***let areaOfInterest: Geometry
***REMOVED***
