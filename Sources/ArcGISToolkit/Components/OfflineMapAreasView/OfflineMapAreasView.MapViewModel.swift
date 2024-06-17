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
***REMOVED******REMOVED***private let portalItemID: Item.ID?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline map task.
***REMOVED******REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The preplanned offline map information.
***REMOVED******REMOVED***@Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(map: Map) {
***REMOVED******REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: map)
***REMOVED******REMOVED******REMOVED***portalItemID = map.item?.id
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and creates the
***REMOVED******REMOVED******REMOVED***/ offline map models.
***REMOVED******REMOVED***func makePreplannedOfflineMapModels() async {
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
***REMOVED******REMOVED******REMOVED***/ Request authorization to show notifications.
***REMOVED******REMOVED***func requestUserNotificationAuthorization() async {
***REMOVED******REMOVED******REMOVED***_ = try? await UNUserNotificationCenter.current()
***REMOVED******REMOVED******REMOVED******REMOVED***.requestAuthorization(options: [.alert, .sound])
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Loads the offline preplanned map models using metadata json files.
***REMOVED******REMOVED***func loadOfflinePreplannedMapModels() {
***REMOVED******REMOVED******REMOVED***offlinePreplannedModels.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let jsonFiles = searchFiles(in: preplannedDirectory, with: "json")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***for fileURL in jsonFiles {
***REMOVED******REMOVED******REMOVED******REMOVED***if let (offlinePreplannedMapArea, mobileMapPackage) = parseJSONFile(for: fileURL),
***REMOVED******REMOVED******REMOVED******REMOVED***   let offlinePreplannedMapArea,
***REMOVED******REMOVED******REMOVED******REMOVED***   let mobileMapPackage {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlinePreplannedModels.append(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapArea: offlinePreplannedMapArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mobileMapPackage: mobileMapPackage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Parses the json from a metadata file for the preplanned map area.
***REMOVED******REMOVED******REMOVED***/ - Parameter fileURL: The file URL of the metadata json file.
***REMOVED******REMOVED******REMOVED***/ - Returns: An `OfflinePreplannedMapArea` instantiated using the metadata json
***REMOVED******REMOVED******REMOVED***/ and the mobile map package for the preplanned map area.
***REMOVED******REMOVED***func parseJSONFile(for fileURL: URL) -> (OfflinePreplannedMapArea?, MobileMapPackage?)? {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let contentString = try String(contentsOf: fileURL)
***REMOVED******REMOVED******REMOVED******REMOVED***let jsonData = Data(contentString.utf8)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let thumbnailURL = fileURL
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.deletingPathExtension()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.deletingLastPathComponent()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.appending(path: "thumbnail")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.appendingPathExtension("png")

***REMOVED******REMOVED******REMOVED******REMOVED***let thumbnailImage = UIImage(contentsOfFile: thumbnailURL.relativePath)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let title = json["title"] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let description = json["description"] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let id = json["id"] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let itemID = Item.ID(id),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let path = json["mmpkURL"] as? String else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let fileURL = URL(filePath: path)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let mobileMapPackage = MobileMapPackage(fileURL: fileURL)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return (
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OfflinePreplannedMapArea(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***packagingStatus: .complete,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: description, 
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailImage: thumbnailImage,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id: itemID
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mobileMapPackage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Searches for files with a specified file extension in a given directory and its subdirectories.
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - directory: The directory to search.
***REMOVED******REMOVED******REMOVED***/   - fileExtension: The file extension to search for.
***REMOVED******REMOVED******REMOVED***/ - Returns: An array of file paths.
***REMOVED******REMOVED***func searchFiles(in directory: URL, with fileExtension: String) -> [URL] {
***REMOVED******REMOVED******REMOVED***guard let enumerator = FileManager.default.enumerator(
***REMOVED******REMOVED******REMOVED******REMOVED***at: directory,
***REMOVED******REMOVED******REMOVED******REMOVED***includingPropertiesForKeys: [.isDirectoryKey],
***REMOVED******REMOVED******REMOVED******REMOVED***options: [.skipsHiddenFiles]
***REMOVED******REMOVED******REMOVED***) else { return [] ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var files: [URL] = []
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***for case let fileURL as URL in enumerator {
***REMOVED******REMOVED******REMOVED******REMOVED***if fileURL.pathExtension == fileExtension {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***files.append(fileURL)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return files
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func addOfflinePreplannedModel(
***REMOVED******REMOVED******REMOVED***for preplannedMap: PreplannedMapAreaProtocol,
***REMOVED******REMOVED******REMOVED***mobileMapPackage: MobileMapPackage?
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***offlinePreplannedModels.append(
***REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapArea: preplannedMap,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mobileMapPackage: mobileMapPackage
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
