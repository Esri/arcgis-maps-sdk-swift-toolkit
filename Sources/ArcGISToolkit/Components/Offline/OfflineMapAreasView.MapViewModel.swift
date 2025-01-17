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

extension OfflineMapAreasView {
***REMOVED******REMOVED***/ The model class for the offline map areas view.
***REMOVED***@MainActor
***REMOVED***class MapViewModel: ObservableObject {
***REMOVED******REMOVED******REMOVED***/ The portal item ID of the web map.
***REMOVED******REMOVED***private let portalItemID: PortalItem.ID?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline map task.
***REMOVED******REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The preplanned map information.
***REMOVED******REMOVED***@Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline preplanned map information sourced from downloaded mobile map packages.
***REMOVED******REMOVED***@Published private(set) var offlinePreplannedMapModels: [PreplannedMapModel]?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The on-demand map information.
***REMOVED******REMOVED***@Published private(set) var onDemandMapModels: [OnDemandMapModel]?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates an offline map areas view model for a given web map.
***REMOVED******REMOVED******REMOVED***/ - Parameter map: The web map.
***REMOVED******REMOVED***init(map: Map) {
***REMOVED******REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: map)
***REMOVED******REMOVED******REMOVED***portalItemID = map.item?.id
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and loads the map models.
***REMOVED******REMOVED***func loadPreplannedMapModels() async {
***REMOVED******REMOVED******REMOVED***guard let portalItemID else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if offlineMapTask.loadStatus != .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED***try? await offlineMapTask.retryLoad()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***preplannedMapModels = await Result { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED***try await offlineMapTask.preplannedMapAreas
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.filter { $0.portalItem.id != nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sorted(using: KeyPathComparator(\.portalItem.title))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapArea: $0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: $0.portalItem.id!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Loads the offline preplanned map models with information from the downloaded mobile map
***REMOVED******REMOVED******REMOVED***/ packages for the online map.
***REMOVED******REMOVED***func loadOfflinePreplannedMapModels() async {
***REMOVED******REMOVED******REMOVED***guard let portalItemID else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let preplannedDirectory = URL.preplannedDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: preplannedDirectory.path()) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var preplannedMapModels: [PreplannedMapModel] = []
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***for mapAreaID in mapAreaIDs {
***REMOVED******REMOVED******REMOVED******REMOVED***guard let preplannedMapAreaID = PortalItem.ID(mapAreaID),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let mapArea = await makePreplannedMapArea(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  ) else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continue
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let model = PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapArea: mapArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: mapArea.id!
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapModels.append(model)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***offlinePreplannedMapModels = preplannedMapModels
***REMOVED******REMOVED******REMOVED******REMOVED***.filter(\.status.isDownloaded)
***REMOVED******REMOVED******REMOVED******REMOVED***.sorted(by: { $0.preplannedMapArea.title < $1.preplannedMapArea.title ***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates a preplanned map area using a given portal item and map area ID to search for a corresponding
***REMOVED******REMOVED******REMOVED***/ downloaded mobile map package. If the mobile map package is not found then `nil` is returned.
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - portalItemID: The portal item ID.
***REMOVED******REMOVED******REMOVED***/   - preplannedMapAreaID: The preplanned map area ID.
***REMOVED******REMOVED******REMOVED***/ - Returns: The preplanned map area.
***REMOVED******REMOVED***private func makePreplannedMapArea(
***REMOVED******REMOVED******REMOVED***portalItemID: PortalItem.ID,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: PortalItem.ID
***REMOVED******REMOVED***) async -> OfflinePreplannedMapArea? {
***REMOVED******REMOVED******REMOVED***let fileURL = URL.preplannedDirectory(
***REMOVED******REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***let mmpk = MobileMapPackage(fileURL: fileURL)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***try? await mmpk.load()
***REMOVED******REMOVED******REMOVED***guard let item = mmpk.item else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return .init(
***REMOVED******REMOVED******REMOVED******REMOVED***title: item.title,
***REMOVED******REMOVED******REMOVED******REMOVED***description: item.description,
***REMOVED******REMOVED******REMOVED******REMOVED***id: preplannedMapAreaID,
***REMOVED******REMOVED******REMOVED******REMOVED***thumbnail: item.thumbnail
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***private func makeOnDemandMapArea(
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

***REMOVED******REMOVED******REMOVED***return .init(
***REMOVED******REMOVED******REMOVED******REMOVED***id: onDemandMapAreaID,
***REMOVED******REMOVED******REMOVED******REMOVED***title: item.title,
***REMOVED******REMOVED******REMOVED******REMOVED***description: item.description,
***REMOVED******REMOVED******REMOVED******REMOVED***thumbnail: item.thumbnail
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func loadOnDemandMapModels() async {
***REMOVED******REMOVED******REMOVED***guard let portalItemID else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let onDemandDirectory = URL.onDemandDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: onDemandDirectory.path()) else {
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapModels = []
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var onDemandMapModels: [OnDemandMapModel] = []
***REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED***let mapArea = OnDemandMapArea(id: id, title: info.title, minScale: minScale, maxScale: maxScale, areaOfInterest: aoi)
***REMOVED******REMOVED******REMOVED******REMOVED***let model = OnDemandMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapArea: mapArea,
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapArea: mapArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapModels.append(model)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.onDemandMapModels = onDemandMapModels
***REMOVED******REMOVED******REMOVED******REMOVED***.sorted(by: { $0.onDemandMapArea.title < $1.onDemandMapArea.title ***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func addOnDemandMapArea(_ onDemandMapArea: OnDemandMapArea) {
***REMOVED******REMOVED******REMOVED***guard let portalItemID else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let model = OnDemandMapModel(offlineMapTask: offlineMapTask, onDemandMapArea: onDemandMapArea, portalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***if onDemandMapModels != nil {
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapModels!.append(model)
***REMOVED******REMOVED******REMOVED******REMOVED***onDemandMapModels!.sort(by: { $0.onDemandMapArea.title < $1.onDemandMapArea.title ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Download map area.
***REMOVED******REMOVED******REMOVED******REMOVED***await model.downloadOnDemandMapArea()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private struct OfflinePreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED***var title: String
***REMOVED***var description: String
***REMOVED***var id: PortalItem.ID?
***REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus?
***REMOVED***var thumbnail: LoadableImage?
***REMOVED***
***REMOVED***func retryLoad() async throws {***REMOVED***
***REMOVED***
***REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
***REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***

***REMOVED*** This struct represents an on-demand area that is downloaded.
struct OfflineOnDemandMapArea: OnDemandMapAreaProtocol {
***REMOVED***var id: UUID
***REMOVED***var title: String
***REMOVED***var description: String
***REMOVED***var thumbnail: LoadableImage?
***REMOVED***
