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
import UserNotifications

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
***REMOVED******REMOVED***init(map: Map) {
***REMOVED******REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: map)
***REMOVED******REMOVED******REMOVED***portalItemID = map.item?.id
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Requests authorization to show notifications.
***REMOVED******REMOVED***nonisolated func requestUserNotificationAuthorization() async {
***REMOVED******REMOVED******REMOVED***_ = try? await UNUserNotificationCenter.current()
***REMOVED******REMOVED******REMOVED******REMOVED***.requestAuthorization(options: [.alert, .sound])
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and creates the map models.
***REMOVED******REMOVED***func makePreplannedMapModels() async {
***REMOVED******REMOVED******REMOVED***guard let portalItemID else { return ***REMOVED***
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
***REMOVED******REMOVED******REMOVED***/ Makes offline preplanned map models with infomation from the downloaded mobile map packages
***REMOVED******REMOVED******REMOVED***/ for the online map.
***REMOVED******REMOVED***func makeOfflinePreplannedMapModels() async {
***REMOVED******REMOVED******REMOVED***guard let portalItemID else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let preplannedDirectory = FileManager.default.preplannedDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let mapAreaIDs = try? FileManager.default.contentsOfDirectory(atPath: preplannedDirectory.path()) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var mapAreas: [OfflinePreplannedMapArea] = []
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***for mapAreaID in mapAreaIDs {
***REMOVED******REMOVED******REMOVED******REMOVED***if let preplannedMapAreaID = PortalItem.ID(mapAreaID),
***REMOVED******REMOVED******REMOVED******REMOVED***   let mapArea = await createMapArea(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED******REMOVED******REMOVED***   ) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapAreas.append(mapArea)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***offlinePreplannedMapModels = mapAreas.map { mapArea in
***REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapArea: mapArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: mapArea.id!
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.sorted(using: KeyPathComparator(\.preplannedMapArea.title))
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates the offline preplanned map areas by using the preplanned map area IDs found in the
***REMOVED******REMOVED******REMOVED***/ preplanned map areas directory to create preplanned map models.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ Creates a preplanned map area using a given portal item and map area ID to search for a corresponding
***REMOVED******REMOVED******REMOVED***/ downloaded mobile map package. If the mobile map package is not found then `nil` is returned.
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - portalItemID: The portal item ID.
***REMOVED******REMOVED******REMOVED***/   - preplannedMapAreaID: The preplanned map area ID.
***REMOVED******REMOVED******REMOVED***/ - Returns: The preplanned map area.
***REMOVED******REMOVED***private func createMapArea(
***REMOVED******REMOVED******REMOVED***for portalItemID: PortalItem.ID,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: PortalItem.ID
***REMOVED******REMOVED***) async -> OfflinePreplannedMapArea? {
***REMOVED******REMOVED******REMOVED***let fileURL = FileManager.default.preplannedDirectory(
***REMOVED******REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Make sure the directory is not empty because the directory will exist as soon as the
***REMOVED******REMOVED******REMOVED******REMOVED*** job starts, so if the job fails, it will look like the mmpk was downloaded.
***REMOVED******REMOVED******REMOVED***guard !FileManager.default.isDirectoryEmpty(atPath: fileURL) else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***let mmpk =  MobileMapPackage.init(fileURL: fileURL)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***try? await mmpk.load()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let item = mmpk.item else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return OfflinePreplannedMapArea(
***REMOVED******REMOVED******REMOVED******REMOVED***title: item.title,
***REMOVED******REMOVED******REMOVED******REMOVED***description: item.description,
***REMOVED******REMOVED******REMOVED******REMOVED***id: preplannedMapAreaID,
***REMOVED******REMOVED******REMOVED******REMOVED***thumbnail: item.thumbnail
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

private struct OfflinePreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus?
***REMOVED***
***REMOVED***var title: String
***REMOVED***
***REMOVED***var description: String
***REMOVED***
***REMOVED***var thumbnail: LoadableImage?
***REMOVED***
***REMOVED***var id: PortalItem.ID?
***REMOVED***
***REMOVED***func retryLoad() async throws {***REMOVED***
***REMOVED***
***REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
***REMOVED******REMOVED***DownloadPreplannedOfflineMapParameters()
***REMOVED***
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***title: String,
***REMOVED******REMOVED***description: String,
***REMOVED******REMOVED***id: PortalItem.ID,
***REMOVED******REMOVED***thumbnail: LoadableImage? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.title = title
***REMOVED******REMOVED***self.description = description
***REMOVED******REMOVED***self.id = id
***REMOVED******REMOVED***self.thumbnail = thumbnail
***REMOVED***
***REMOVED***
