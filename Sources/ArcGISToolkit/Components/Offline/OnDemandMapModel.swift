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
***REMOVED******REMOVED***/ The configuration for taking the map area offline.
***REMOVED***let configuration: OnDemandMapAreaConfiguration?
***REMOVED***
***REMOVED******REMOVED***/ The mobile map package directory URL.
***REMOVED***let mmpkDirectoryURL: URL
***REMOVED***
***REMOVED******REMOVED***/ The task to use to take the area offline.
***REMOVED***private let offlineMapTask: OfflineMapTask?
***REMOVED***
***REMOVED******REMOVED***/ The ID of the online map.
***REMOVED***private let portalItemID: Item.ID
***REMOVED***
***REMOVED******REMOVED***/ The unique ID of the map area.
***REMOVED***let areaID: String
***REMOVED***
***REMOVED******REMOVED***/ The title of the map area.
***REMOVED***let title: String
***REMOVED***
***REMOVED******REMOVED***/ The description of the map area.
***REMOVED***@Published private(set) var description: String = ""
***REMOVED***
***REMOVED******REMOVED***/ A thumbnail for the map area.
***REMOVED***@Published private(set) var thumbnail: LoadableImage?
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
***REMOVED******REMOVED***/ Creates an on-demand map area model with a configuration
***REMOVED******REMOVED***/ for taking the area offline.
***REMOVED***init(
***REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED***configuration: OnDemandMapAreaConfiguration,
***REMOVED******REMOVED***portalItemID: PortalItem.ID
***REMOVED***) {
***REMOVED******REMOVED***self.configuration = configuration
***REMOVED******REMOVED***self.offlineMapTask = offlineMapTask
***REMOVED******REMOVED***self.portalItemID = portalItemID
***REMOVED******REMOVED***self.title = configuration.title
***REMOVED******REMOVED***self.areaID = configuration.areaID
***REMOVED******REMOVED***mmpkDirectoryURL = .onDemandDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onDemandMapAreaID: configuration.areaID
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an on-demand map area model for a job that
***REMOVED******REMOVED***/ is currently running.
***REMOVED***init(
***REMOVED******REMOVED***job: GenerateOfflineMapJob,
***REMOVED******REMOVED***areaID: String,
***REMOVED******REMOVED***portalItemID: PortalItem.ID
***REMOVED***) {
***REMOVED******REMOVED***self.configuration = nil
***REMOVED******REMOVED***self.job = job
***REMOVED******REMOVED***self.areaID = areaID
***REMOVED******REMOVED***self.title = job.parameters.itemInfo?.title ?? "Unknown"
***REMOVED******REMOVED***self.portalItemID = portalItemID
***REMOVED******REMOVED***self.offlineMapTask = nil
***REMOVED******REMOVED***mmpkDirectoryURL = .onDemandDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onDemandMapAreaID: areaID
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Logger.offlineManager.debug("Found executing job for on-demand area \(areaID, privacy: .public)")
***REMOVED******REMOVED***observeJob(job)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ An error that signifies that the mmpk has no item.
***REMOVED***private struct NoItemError: Error {***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an on-demand map area model for a map area that has already been downloaded.
***REMOVED***init(
***REMOVED******REMOVED***mmpkURL: URL,
***REMOVED******REMOVED***portalItemID: PortalItem.ID
***REMOVED***) async throws {
***REMOVED******REMOVED***let mmpk = MobileMapPackage(fileURL: mmpkURL)
***REMOVED******REMOVED***try await mmpk.load()
***REMOVED******REMOVED***guard let item = mmpk.item else { throw NoItemError() ***REMOVED***
***REMOVED******REMOVED***self.portalItemID = portalItemID
***REMOVED******REMOVED***configuration = nil
***REMOVED******REMOVED***title = item.title
***REMOVED******REMOVED***description = item.description
***REMOVED******REMOVED***mmpkDirectoryURL = mmpkURL
***REMOVED******REMOVED***areaID = mmpkURL.deletingPathExtension().lastPathComponent
***REMOVED******REMOVED***offlineMapTask = nil
***REMOVED******REMOVED***await loadAndUpdateMobileMapPackage(mmpk: mmpk)
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
***REMOVED******REMOVED******REMOVED***thumbnail = mmpk.item?.thumbnail
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***status = .mmpkLoadFailure(error)
***REMOVED******REMOVED******REMOVED***mobileMapPackage = nil
***REMOVED******REMOVED******REMOVED***directorySize = 0
***REMOVED******REMOVED******REMOVED***thumbnail = nil
***REMOVED******REMOVED******REMOVED***map = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Downloads the on-demand map area.
***REMOVED******REMOVED***/ - Precondition: `allowsDownload == true`
***REMOVED******REMOVED***/ - Precondition: `configuration != nil`
***REMOVED******REMOVED***/ - Precondition: `configurofflineMapTaskation != nil`
***REMOVED***func downloadOnDemandMapArea() async {
***REMOVED******REMOVED***precondition(status.allowsDownload)
***REMOVED******REMOVED***guard let configuration, let offlineMapTask else { preconditionFailure() ***REMOVED***
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
***REMOVED***static func loadOnDemandMapModels(portalItemID: Item.ID) async -> [OnDemandMapModel] {
***REMOVED******REMOVED***var onDemandMapModels: [OnDemandMapModel] = []
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Look up the ongoing jobs for on-demand map models.
***REMOVED******REMOVED***let ongoingJobs = OfflineManager.shared.jobs
***REMOVED******REMOVED******REMOVED***.lazy
***REMOVED******REMOVED******REMOVED***.compactMap { $0 as? GenerateOfflineMapJob ***REMOVED***
***REMOVED******REMOVED******REMOVED***.map {
***REMOVED******REMOVED******REMOVED******REMOVED***let areaID = $0.downloadDirectoryURL.deletingPathExtension().lastPathComponent
***REMOVED******REMOVED******REMOVED******REMOVED***return OnDemandMapModel(job: $0, areaID: areaID, portalItemID: portalItemID)
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***onDemandMapModels.append(contentsOf: ongoingJobs)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Look up the already downloaded on-demand map models.
***REMOVED******REMOVED***let onDemandDirectory = URL.onDemandDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED***if let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: onDemandDirectory.path()) {
***REMOVED******REMOVED******REMOVED***for url in mapAreaIDs.map({ onDemandDirectory.appending(component: $0) ***REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***guard let mapArea = try? await OnDemandMapModel.init(mmpkURL: url, portalItemID: portalItemID) else { continue ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapModels.append(mapArea)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return onDemandMapModels
***REMOVED******REMOVED******REMOVED***.sorted(by: { $0.title < $1.title ***REMOVED***)
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
***REMOVED***let areaID = UUID().uuidString
***REMOVED******REMOVED***/ A title for the offline area.
***REMOVED***let title: String
***REMOVED******REMOVED***/ The min-scale to take offline.
***REMOVED***let minScale: Double
***REMOVED******REMOVED***/ The max-scale to take offline.
***REMOVED***let maxScale: Double
***REMOVED******REMOVED***/ The area of interest to take offline.
***REMOVED***let areaOfInterest: Geometry
***REMOVED***
