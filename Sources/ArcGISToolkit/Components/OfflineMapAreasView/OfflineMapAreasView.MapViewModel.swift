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
***REMOVED******REMOVED***private let portalItemID: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline map task.
***REMOVED******REMOVED***private let offlineMapTask: OfflineMapTask
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The url for the preplanned map areas directory.
***REMOVED******REMOVED***private var preplannedDirectory: URL?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The preplanned offline map information.
***REMOVED******REMOVED***@Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the map has preplanned map areas.
***REMOVED******REMOVED***@Published private(set) var hasPreplannedMapAreas = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the user has authorized notifications to be shown.
***REMOVED******REMOVED***@Published var canShowNotifications: Bool = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(map: Map) {
***REMOVED******REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: map)
***REMOVED******REMOVED******REMOVED***portalItemID = map.item?.id?.rawValue
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and creates the
***REMOVED******REMOVED******REMOVED***/ offline map models.
***REMOVED******REMOVED***func makePreplannedOfflineMapModels() async {
***REMOVED******REMOVED******REMOVED***guard let portalItemID else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***FileManager.default.createDirectories(for: portalItemID)
***REMOVED******REMOVED******REMOVED***preplannedDirectory = FileManager.default.preplannedDirectory(forItemID: portalItemID)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let preplannedDirectory else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***preplannedMapModels = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await offlineMapTask.preplannedMapAreas
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sorted(using: KeyPathComparator(\.portalItem.title))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.compactMap {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapArea: $0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***directory: preplannedDirectory
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let models = try? preplannedMapModels?.get() {
***REMOVED******REMOVED******REMOVED******REMOVED***hasPreplannedMapAreas = !models.isEmpty
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Sets locally stored mobile map packages for the map's preplanned map area models.
***REMOVED******REMOVED***func setPreplannedMobileMapPackages() {
***REMOVED******REMOVED******REMOVED***if let models = try? preplannedMapModels?.get() {
***REMOVED******REMOVED******REMOVED******REMOVED***for model in models {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.setMobileMapPackageFromDownloads()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

public extension OfflineMapAreasView {
***REMOVED******REMOVED***/ Recursively searches for files with a specified file extension in a given directory and its subdirectories.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - directory: The directory to search.
***REMOVED******REMOVED***/   - pathExtension: The path extension to search for.
***REMOVED******REMOVED***/ - Returns: An array of file paths.
***REMOVED***static func urls(in directory: URL, withPathExtension pathExtension: String) -> [URL] {
***REMOVED******REMOVED***guard let enumerator = FileManager.default.enumerator(
***REMOVED******REMOVED******REMOVED***at: directory,
***REMOVED******REMOVED******REMOVED***includingPropertiesForKeys: [.isDirectoryKey]
***REMOVED******REMOVED***) else { return [] ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return enumerator
***REMOVED******REMOVED******REMOVED***.compactMap { $0 as? URL ***REMOVED***
***REMOVED******REMOVED******REMOVED***.filter { $0.pathExtension == pathExtension ***REMOVED***
***REMOVED***
***REMOVED***

private extension OfflineMapAreasView.MapViewModel {
***REMOVED******REMOVED***/ The names of the folders used to save offline map areas.
***REMOVED***enum FolderNames: String {
***REMOVED******REMOVED***case preplanned = "Preplanned"
***REMOVED******REMOVED***case offlineMapAreas = "OfflineMapAreas"
***REMOVED***
***REMOVED***

private extension FileManager {
***REMOVED******REMOVED***/ The path to the documents folder.
***REMOVED***var documentsDirectory: URL {
***REMOVED******REMOVED***URL.documentsDirectory
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the offline map areas directory. The offline map areas directory is located in the documents directory.
***REMOVED***var offlineMapAreasDirectory: URL {
***REMOVED******REMOVED***documentsDirectory.appending(
***REMOVED******REMOVED******REMOVED***path: OfflineMapAreasView.MapViewModel.FolderNames.offlineMapAreas.rawValue,
***REMOVED******REMOVED******REMOVED***directoryHint: .isDirectory
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the web map directory for a specific portal item.
***REMOVED***func webMapDirectory(forItemID itemID: String) -> URL {
***REMOVED******REMOVED***offlineMapAreasDirectory.appending(path: itemID, directoryHint: .isDirectory)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the preplanned map areas directory for a specific portal item.
***REMOVED***func preplannedDirectory(forItemID itemID: String) -> URL {
***REMOVED******REMOVED***webMapDirectory(forItemID: itemID).appending(
***REMOVED******REMOVED******REMOVED***path: OfflineMapAreasView.MapViewModel.FolderNames.preplanned.rawValue,
***REMOVED******REMOVED******REMOVED***directoryHint: .isDirectory
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates the directories needed to save a preplanned map area mobile map package and metadata
***REMOVED******REMOVED***/ with a given portal item ID.
***REMOVED******REMOVED***/ - Parameter portalItemID: The portal item ID.
***REMOVED***func createDirectories(for portalItemID: String) {
***REMOVED******REMOVED******REMOVED*** Create directory for offline map areas.
***REMOVED******REMOVED***try? FileManager.default.createDirectory(at: FileManager.default.offlineMapAreasDirectory, withIntermediateDirectories: true)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create directory for the webmap.
***REMOVED******REMOVED***try? FileManager.default.createDirectory(at: FileManager.default.webMapDirectory(forItemID: portalItemID), withIntermediateDirectories: true)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create directory for preplanned map areas.
***REMOVED******REMOVED***try? FileManager.default.createDirectory(at: FileManager.default.preplannedDirectory(forItemID: portalItemID), withIntermediateDirectories: true)
***REMOVED***
***REMOVED***
