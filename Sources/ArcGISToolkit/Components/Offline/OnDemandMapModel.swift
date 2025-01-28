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
***REMOVED******REMOVED***/ The on-demand map area.
***REMOVED***let onDemandMapArea: any OnDemandMapAreaProtocol
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
***REMOVED******REMOVED***mapArea: OnDemandMapAreaProtocol,
***REMOVED******REMOVED***portalItemID: PortalItem.ID
***REMOVED***) {
***REMOVED******REMOVED***self.onDemandMapArea = mapArea
***REMOVED******REMOVED***self.offlineMapTask = offlineMapTask
***REMOVED******REMOVED***self.portalItemID = portalItemID
***REMOVED******REMOVED***mmpkDirectoryURL = .onDemandDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onDemandMapAreaID: onDemandMapArea.id
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let foundJob = lookupDownloadJob() {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Found executing job for on-demand area \(mapArea.id.uuidString, privacy: .public)")
***REMOVED******REMOVED******REMOVED***observeJob(foundJob)
***REMOVED*** else if let mmpk = lookupMobileMapPackage() {
***REMOVED******REMOVED******REMOVED***Logger.offlineManager.debug("Found MMPK for area \(mapArea.id.uuidString, privacy: .public)")
***REMOVED******REMOVED******REMOVED***Task.detached { await self.loadAndUpdateMobileMapPackage(mmpk: mmpk) ***REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***status = .initialized
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
***REMOVED******REMOVED***/ Look up the job associated with this map model.
***REMOVED***private func lookupDownloadJob() -> GenerateOfflineMapJob? {
***REMOVED******REMOVED***OfflineManager.shared.jobs
***REMOVED******REMOVED******REMOVED***.lazy
***REMOVED******REMOVED******REMOVED***.compactMap { $0 as? GenerateOfflineMapJob ***REMOVED***
***REMOVED******REMOVED******REMOVED***.first {
***REMOVED******REMOVED******REMOVED******REMOVED***$0.downloadDirectoryURL.deletingPathExtension().lastPathComponent == onDemandMapArea.id.uuidString
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Looks up the mobile map package directory for downloaded package.
***REMOVED***private func lookupMobileMapPackage() -> MobileMapPackage? {
***REMOVED******REMOVED***let fileURL = URL.onDemandDirectory(
***REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED***onDemandMapAreaID: onDemandMapArea.id
***REMOVED******REMOVED***)
***REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED***return MobileMapPackage(fileURL: fileURL)
***REMOVED***
***REMOVED***
***REMOVED***func downloadOnDemandMapArea() async {
***REMOVED******REMOVED***precondition(status.allowsDownload)
***REMOVED******REMOVED***status = .downloading
***REMOVED******REMOVED***guard let onDemandMapArea = onDemandMapArea as? OnDemandMapArea else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let parameters = try await offlineMapTask.makeDefaultGenerateOfflineMapParameters(
***REMOVED******REMOVED******REMOVED******REMOVED***areaOfInterest: onDemandMapArea.areaOfInterest,
***REMOVED******REMOVED******REMOVED******REMOVED***minScale: onDemandMapArea.minScale,
***REMOVED******REMOVED******REMOVED******REMOVED***maxScale: onDemandMapArea.maxScale
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED*** Set the update mode to no updates as the offline map is display-only.
***REMOVED******REMOVED******REMOVED***parameters.updateMode = .noUpdates
***REMOVED******REMOVED******REMOVED***try FileManager.default.createDirectory(at: mmpkDirectoryURL, withIntermediateDirectories: true)
***REMOVED******REMOVED******REMOVED***guard let itemInfo = parameters.itemInfo else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***itemInfo.title = onDemandMapArea.title
***REMOVED******REMOVED******REMOVED***itemInfo.description = ""
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

***REMOVED***/ A type that acts as a preplanned map area.
protocol OnDemandMapAreaProtocol: Sendable {
***REMOVED***var id: UUID { get ***REMOVED***
***REMOVED***var title: String { get ***REMOVED***
***REMOVED***

***REMOVED*** This struct represents an on-demand area that hasn't been downloaded to disk.
struct OnDemandMapArea: OnDemandMapAreaProtocol {
***REMOVED***let id: UUID
***REMOVED***let title: String
***REMOVED***let minScale: Double
***REMOVED***let maxScale: Double
***REMOVED***let areaOfInterest: Geometry
***REMOVED***
