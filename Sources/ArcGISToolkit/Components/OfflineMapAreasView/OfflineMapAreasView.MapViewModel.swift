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
***REMOVED***
import UIKit

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
***REMOVED******REMOVED******REMOVED***/ The preplanned offline map information.
***REMOVED******REMOVED***@Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline preplanned map information.
***REMOVED******REMOVED***@Published private(set) var offlinePreplannedModels = [PreplannedMapModel]()
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(map: Map) {
***REMOVED******REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: map)
***REMOVED******REMOVED******REMOVED***portalItemID = map.item?.id
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and creates the
***REMOVED******REMOVED******REMOVED***/ preplanned map models.
***REMOVED******REMOVED***func makePreplannedMapModels() async {
***REMOVED******REMOVED******REMOVED***guard let portalItemID else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***preplannedMapModels = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await offlineMapTask.preplannedMapAreas
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.filter { $0.id != nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sorted(using: KeyPathComparator(\.portalItem.title))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapArea: $0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: $0.id!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Requests authorization to show notifications.
***REMOVED******REMOVED***func requestUserNotificationAuthorization() async {
***REMOVED******REMOVED******REMOVED***_ = try? await UNUserNotificationCenter.current()
***REMOVED******REMOVED******REMOVED******REMOVED***.requestAuthorization(options: [.alert, .sound])
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Gets the preplanned map areas from local metadata json files.
***REMOVED******REMOVED***func makeOfflinePreplannedMapModels() {
***REMOVED******REMOVED******REMOVED***guard let portalItemID else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let portalItemDirectory = FileManager.default.preplannedDirectory(forPortalItemID: portalItemID)
***REMOVED******REMOVED******REMOVED******REMOVED***let preplannedMapAreaDirectories = try FileManager.default.contentsOfDirectory(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: portalItemDirectory,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***includingPropertiesForKeys: nil
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let preplannedMapAreaIDs = preplannedMapAreaDirectories.map { Item.ID($0.lastPathComponent)! ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let mapAreas = preplannedMapAreaIDs.compactMap { mapAreaID in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***readMetadata(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: mapAreaID
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***offlinePreplannedModels = mapAreas.map { mapArea in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapAreaID: mapArea.id!,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapArea: mapArea
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Reads the metadata for a given preplanned map area from a portal item and returns a preplanned
***REMOVED******REMOVED******REMOVED***/ map area protocol constructed with the metadata.
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - portalItemID: The ID for the portal item.
***REMOVED******REMOVED******REMOVED***/   - preplannedMapAreaID: The ID for the preplanned map area.
***REMOVED******REMOVED******REMOVED***/ - Returns: A preplanned map area protocol.
***REMOVED******REMOVED***private func readMetadata(for portalItemID: Item.ID, preplannedMapAreaID: Item.ID) -> PreplannedMapAreaProtocol? {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let metadataPath = FileManager.default.metadataPath(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***let contentString = try String(contentsOf: metadataPath)
***REMOVED******REMOVED******REMOVED******REMOVED***let jsonData = Data(contentString.utf8)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let thumbnailURL = FileManager.default.thumbnailPath(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***forPortalItemID: portalItemID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapAreaID: preplannedMapAreaID
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***let thumbnailImage = UIImage(contentsOfFile: thumbnailURL.relativePath)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let title = json["title"] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let description = json["description"] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let id = json["id"] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let itemID = Item.ID(id) else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return OfflinePreplannedMapArea(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: description,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailImage: thumbnailImage,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id: itemID
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return nil
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
***REMOVED***var thumbnailImage: UIImage?
***REMOVED***
***REMOVED***var id: ArcGIS.Item.ID?
***REMOVED***
***REMOVED***func retryLoad() async throws {***REMOVED***
***REMOVED***
***REMOVED***func makeParameters(using offlineMapTask: ArcGIS.OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
***REMOVED******REMOVED***DownloadPreplannedOfflineMapParameters()
***REMOVED***
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***title: String,
***REMOVED******REMOVED***description: String,
***REMOVED******REMOVED***thumbnailImage: UIImage? = nil,
***REMOVED******REMOVED***id: ArcGIS.Item.ID? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.title = title
***REMOVED******REMOVED***self.description = description
***REMOVED******REMOVED***self.thumbnailImage = thumbnailImage
***REMOVED******REMOVED***self.id = id
***REMOVED***
***REMOVED***
