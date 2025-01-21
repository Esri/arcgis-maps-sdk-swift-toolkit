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

***REMOVED***/ The model class that represents information for an offline map.
@MainActor
class OfflineMapViewModel: ObservableObject {
***REMOVED******REMOVED***/ The portal item ID of the web map.
***REMOVED***private let portalItemID: Item.ID
***REMOVED***
***REMOVED******REMOVED***/ The offline map task.
***REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED***
***REMOVED******REMOVED***/ The preplanned map information.
***REMOVED***@Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if only offline models are being shown.
***REMOVED***@Published private(set) var isShowingOnlyOfflineModels = false
***REMOVED***
***REMOVED******REMOVED***/ The online map.
***REMOVED***private let onlineMap: Map
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the web map is offline disabled.
***REMOVED***var mapIsOfflineDisabled: Bool {
***REMOVED******REMOVED***onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an offline map areas view model for a given web map.
***REMOVED******REMOVED***/ - Parameter onlineMap: The web map.
***REMOVED******REMOVED***/ - Precondition: `onlineMap.item?.id` is not `nil`.
***REMOVED***init(onlineMap: Map) {
***REMOVED******REMOVED***precondition(onlineMap.item?.id != nil)
***REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: onlineMap)
***REMOVED******REMOVED***self.onlineMap = onlineMap
***REMOVED******REMOVED***portalItemID = onlineMap.item!.id!
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and loads the map models.
***REMOVED***func loadPreplannedMapModels() async {
***REMOVED******REMOVED***if offlineMapTask.loadStatus != .loaded {
***REMOVED******REMOVED******REMOVED***try? await offlineMapTask.retryLoad()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Reset flag.
***REMOVED******REMOVED***isShowingOnlyOfflineModels = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***preplannedMapModels = await Result { @MainActor in
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onRemoveDownload: onRemoveDownloadOfPreplannedArea(withID:)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If not connected to the internet, then return only the offline models.
***REMOVED******REMOVED******REMOVED******REMOVED***if let urlError = error as? URLError,
***REMOVED******REMOVED******REMOVED******REMOVED***   urlError.code == .notConnectedToInternet {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowingOnlyOfflineModels = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return await loadOfflinePreplannedMapModels()
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***throw error
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the offline preplanned map models with information from the downloaded mobile map
***REMOVED******REMOVED***/ packages for the online map.
***REMOVED***func loadOfflinePreplannedMapModels() async -> [PreplannedMapModel] {
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
***REMOVED******REMOVED******REMOVED******REMOVED***onRemoveDownload: onRemoveDownloadOfPreplannedArea(withID:)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***preplannedMapModels.append(model)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return preplannedMapModels
***REMOVED******REMOVED******REMOVED***.filter(\.status.isDownloaded)
***REMOVED******REMOVED******REMOVED***.sorted(by: { $0.preplannedMapArea.title < $1.preplannedMapArea.title ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The function called when a downloaded preplanned map area is removed.
***REMOVED***func onRemoveDownloadOfPreplannedArea(withID preplannedAreaID: Item.ID) {
***REMOVED******REMOVED******REMOVED*** Delete the saved map info if there are no more downloads for the
***REMOVED******REMOVED******REMOVED*** represented online map.
***REMOVED******REMOVED***guard case.success(let models) = preplannedMapModels,
***REMOVED******REMOVED******REMOVED***  models.filter(\.status.isDownloaded).isEmpty
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***OfflineManager.shared.removeMapInfo(for: portalItemID)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a preplanned map area using a given portal item and map area ID to search for a corresponding
***REMOVED******REMOVED***/ downloaded mobile map package. If the mobile map package is not found then `nil` is returned.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - portalItemID: The portal item ID.
***REMOVED******REMOVED***/   - preplannedMapAreaID: The preplanned map area ID.
***REMOVED******REMOVED***/ - Returns: The preplanned map area.
***REMOVED***private func makeMapArea(
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
