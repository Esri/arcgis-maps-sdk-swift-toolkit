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
***REMOVED***

public extension OfflineMapAreasView {
***REMOVED******REMOVED***/ The model class for the offline map areas view.
***REMOVED***@MainActor
***REMOVED***class MapViewModel: ObservableObject {
***REMOVED******REMOVED******REMOVED***/ The online map.
***REMOVED******REMOVED***private let onlineMap: Map
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The portal item ID of the web map.
***REMOVED******REMOVED***private var portalItemID: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline map of the downloaded preplanned map area.
***REMOVED******REMOVED***private var offlineMap: Map?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The map used in the map view.
***REMOVED******REMOVED***var currentMap: Map { offlineMap ?? onlineMap ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline map task.
***REMOVED******REMOVED***let offlineMapTask: OfflineMapTask
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The url for the preplanned map areas directory.
***REMOVED******REMOVED***let preplannedDirectory: URL
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The mobile map packages created from mmpk files in the documents directory.
***REMOVED******REMOVED***@Published var mobileMapPackages = [MobileMapPackage]()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The preplanned offline map information.
***REMOVED******REMOVED***@Published private(set) var preplannedMapModels: Result<[PreplannedMapModel], Error>?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the map has preplanned map areas.
***REMOVED******REMOVED***@Published private(set) var hasPreplannedMapAreas = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The currently selected map.
***REMOVED******REMOVED***@Published var selectedMap: SelectedMap = .onlineWebMap {
***REMOVED******REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedMapDidChange(from: oldValue)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The job manager.
***REMOVED******REMOVED***var jobManager = JobManager.shared
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(map: Map) {
***REMOVED******REMOVED******REMOVED***onlineMap = map
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Sets the min scale to avoid requesting a huge download.
***REMOVED******REMOVED******REMOVED***onlineMap.minScale = 1e4
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: onlineMap)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let portalItemID = map.item?.id?.description {
***REMOVED******REMOVED******REMOVED******REMOVED***FileManager.default.createDirectories(for: portalItemID)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***preplannedDirectory = FileManager.default.preplannedDirectory(poratlItemID: portalItemID)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***preplannedDirectory = FileManager.default.documentsDirectory
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Gets the preplanned map areas from the offline map task and creates the
***REMOVED******REMOVED******REMOVED***/ offline map models.
***REMOVED******REMOVED***func makePreplannedOfflineMapModels() async {
***REMOVED******REMOVED******REMOVED***preplannedMapModels = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await offlineMapTask.preplannedMapAreas
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sorted(using: KeyPathComparator(\.portalItem.title))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.compactMap {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMapModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedMapArea: $0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapViewModel: self
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let models = try? preplannedMapModels!.get() {
***REMOVED******REMOVED******REMOVED******REMOVED***hasPreplannedMapAreas = !models.isEmpty
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Handles a selection of a map.
***REMOVED******REMOVED******REMOVED***/ If the selected map is an offline map and it has not yet been taken offline, then
***REMOVED******REMOVED******REMOVED***/ it will start downloading. Otherwise the selected map will be used as the displayed map.
***REMOVED******REMOVED***func selectedMapDidChange(from oldValue: SelectedMap) {
***REMOVED******REMOVED******REMOVED***switch selectedMap {
***REMOVED******REMOVED******REMOVED***case .onlineWebMap:
***REMOVED******REMOVED******REMOVED******REMOVED***offlineMap = nil
***REMOVED******REMOVED******REMOVED***case .preplannedMap(let info):
***REMOVED******REMOVED******REMOVED******REMOVED***if info.canDownload {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we have not yet downloaded or started downloading, then kick off a
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** download and reset selection to previous selection since we have to download
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** the offline map.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedMap = oldValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await info.downloadPreplannedMapArea()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else if case .success(let mmpk) = info.result {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we have already downloaded, then open the map in the mmpk.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMap = mmpk.maps.first
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we have a failure, then keep the online map selected.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedMap = oldValue
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Loads locally stored mobile map packages for the map's preplanned map areas.
***REMOVED******REMOVED***func loadPreplannedMobileMapPackages() {
***REMOVED******REMOVED******REMOVED******REMOVED*** Create mobile map packages with saved mmpk files.
***REMOVED******REMOVED******REMOVED***let mmpkFiles = searchFiles(in: preplannedDirectory, with: "mmpk")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***for fileURL in mmpkFiles {
***REMOVED******REMOVED******REMOVED******REMOVED***let mobileMapPackage = MobileMapPackage(fileURL: fileURL)
***REMOVED******REMOVED******REMOVED******REMOVED***self.mobileMapPackages.append(mobileMapPackage)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Searches for files with a specified file extension in a given directory and its subdirectories.
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - directory: The directory to search.
***REMOVED******REMOVED******REMOVED***/   - fileExtension: The file extension to search for.
***REMOVED******REMOVED******REMOVED***/ - Returns: An array of file paths.
***REMOVED******REMOVED***func searchFiles(in directory: URL, with fileExtension: String) -> [URL] {
***REMOVED******REMOVED******REMOVED***var files = [URL]()
***REMOVED******REMOVED******REMOVED***let keys: [URLResourceKey] = [.isDirectoryKey]
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let enumerator = FileManager.default.enumerator(
***REMOVED******REMOVED******REMOVED******REMOVED***at: directory,
***REMOVED******REMOVED******REMOVED******REMOVED***includingPropertiesForKeys: keys,
***REMOVED******REMOVED******REMOVED******REMOVED***options: [.skipsHiddenFiles]
***REMOVED******REMOVED******REMOVED***) else { return [] ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***for case let fileURL as URL in enumerator {
***REMOVED******REMOVED******REMOVED******REMOVED***if fileURL.pathExtension == fileExtension {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***files.append(fileURL)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return files
***REMOVED***
***REMOVED***
***REMOVED***

public extension OfflineMapAreasView.MapViewModel {
***REMOVED******REMOVED***/ A type that specifies the currently selected map.
***REMOVED***enum SelectedMap: Hashable {
***REMOVED******REMOVED******REMOVED***/ The online version of the map.
***REMOVED******REMOVED***case onlineWebMap
***REMOVED******REMOVED******REMOVED***/ One of the preplanned offline maps.
***REMOVED******REMOVED***case preplannedMap(PreplannedMapModel)
***REMOVED***
***REMOVED***

private extension FileManager {
***REMOVED******REMOVED***/ The path to the documents folder.
***REMOVED***var documentsDirectory: URL {
***REMOVED******REMOVED***URL(
***REMOVED******REMOVED******REMOVED***fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the offline map areas directory.
***REMOVED***private var offlineMapAreasDirectory: URL {
***REMOVED******REMOVED***documentsDirectory.appending(path: "OfflineMapAreas", directoryHint: .isDirectory)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the web map directory.
***REMOVED***private func webMapDirectory(poratlItemID: String) -> URL {
***REMOVED******REMOVED***offlineMapAreasDirectory.appending(path: poratlItemID, directoryHint: .isDirectory)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the preplanned map areas directory.
***REMOVED***func preplannedDirectory(poratlItemID: String) -> URL {
***REMOVED******REMOVED***webMapDirectory(poratlItemID: poratlItemID).appending(path: "Preplanned", directoryHint: .isDirectory)
***REMOVED***
***REMOVED***
***REMOVED***func createDirectories(for poratlItemID: String) {
***REMOVED******REMOVED***Task.detached {
***REMOVED******REMOVED******REMOVED******REMOVED*** Create directory for offline map areas.
***REMOVED******REMOVED******REMOVED***try FileManager.default.createDirectory(at: FileManager.default.offlineMapAreasDirectory, withIntermediateDirectories: true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Create directory for the webmap.
***REMOVED******REMOVED******REMOVED***try FileManager.default.createDirectory(at: FileManager.default.webMapDirectory(poratlItemID: poratlItemID), withIntermediateDirectories: true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Create directory for preplanned map areas.
***REMOVED******REMOVED******REMOVED***try FileManager.default.createDirectory(at: FileManager.default.preplannedDirectory(poratlItemID: poratlItemID), withIntermediateDirectories: true)
***REMOVED***
***REMOVED***
***REMOVED***
