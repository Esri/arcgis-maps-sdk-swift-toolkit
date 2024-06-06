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

public extension OfflineMapAreasView {
***REMOVED******REMOVED***/ The model class for the offline map areas view.
***REMOVED***@MainActor
***REMOVED***class MapViewModel: ObservableObject {
***REMOVED******REMOVED******REMOVED***/ The portal item ID of the web map.
***REMOVED******REMOVED***private var portalItemID: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline map of the downloaded preplanned map area.
***REMOVED******REMOVED***private var offlineMap: Map?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The offline map task.
***REMOVED******REMOVED***let offlineMapTask: OfflineMapTask
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The url for the preplanned map areas directory.
***REMOVED******REMOVED***let preplannedDirectory: URL
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The mobile map packages created from mmpk files in the documents directory.
***REMOVED******REMOVED***@Published private(set) var mobileMapPackages = [MobileMapPackage]()
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
***REMOVED******REMOVED******REMOVED***/ The job manager.
***REMOVED******REMOVED***let jobManager = JobManager.shared
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(map: Map) {
***REMOVED******REMOVED******REMOVED***offlineMapTask = OfflineMapTask(onlineMap: map)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let portalItemID = map.item?.id?.rawValue {
***REMOVED******REMOVED******REMOVED******REMOVED***FileManager.default.createDirectories(for: portalItemID)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***preplannedDirectory = FileManager.default.preplannedDirectory(portalItemID: portalItemID)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offlineMapTask: self.offlineMapTask,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preplannedDirectory: self.preplannedDirectory
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let models = try? preplannedMapModels?.get() {
***REMOVED******REMOVED******REMOVED******REMOVED***hasPreplannedMapAreas = !models.isEmpty
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Loads locally stored mobile map packages for the map's preplanned map areas.
***REMOVED******REMOVED***func loadPreplannedMobileMapPackages() {
***REMOVED******REMOVED******REMOVED******REMOVED*** Create mobile map packages with saved mmpk files.
***REMOVED******REMOVED******REMOVED***let mmpkFiles = searchFiles(in: preplannedDirectory, with: "mmpk")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.mobileMapPackages = mmpkFiles.map(MobileMapPackage.init(fileURL:))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Pass mobile map packages to preplanned map models.
***REMOVED******REMOVED******REMOVED***if let models = try? preplannedMapModels?.get() {
***REMOVED******REMOVED******REMOVED******REMOVED***models.forEach { model in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let mobileMapPackage = mobileMapPackages.first(where: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0.fileURL.deletingPathExtension().lastPathComponent == model.preplannedMapArea.id?.rawValue
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.setMobileMapPackage(mobileMapPackage)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
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
***REMOVED***
***REMOVED***

private extension FileManager {
***REMOVED******REMOVED***/ The path to the documents folder.
***REMOVED***var documentsDirectory: URL {
***REMOVED******REMOVED***URL.documentsDirectory
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the offline map areas directory.
***REMOVED***private var offlineMapAreasDirectory: URL {
***REMOVED******REMOVED***documentsDirectory.appending(
***REMOVED******REMOVED******REMOVED***path: OfflineMapAreasView.FolderNames.offlineMapAreas.rawValue,
***REMOVED******REMOVED******REMOVED***directoryHint: .isDirectory
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the web map directory.
***REMOVED***private func webMapDirectory(portalItemID: String) -> URL {
***REMOVED******REMOVED***offlineMapAreasDirectory.appending(path: portalItemID, directoryHint: .isDirectory)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The path to the preplanned map areas directory.
***REMOVED***func preplannedDirectory(portalItemID: String) -> URL {
***REMOVED******REMOVED***webMapDirectory(portalItemID: portalItemID).appending(
***REMOVED******REMOVED******REMOVED***path: OfflineMapAreasView.FolderNames.preplanned.rawValue,
***REMOVED******REMOVED******REMOVED***directoryHint: .isDirectory
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func createDirectories(for portalItemID: String) {
***REMOVED******REMOVED******REMOVED*** Create directory for offline map areas.
***REMOVED******REMOVED***try? FileManager.default.createDirectory(at: FileManager.default.offlineMapAreasDirectory, withIntermediateDirectories: true)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create directory for the webmap.
***REMOVED******REMOVED***try? FileManager.default.createDirectory(at: FileManager.default.webMapDirectory(portalItemID: portalItemID), withIntermediateDirectories: true)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create directory for preplanned map areas.
***REMOVED******REMOVED***try? FileManager.default.createDirectory(at: FileManager.default.preplannedDirectory(portalItemID: portalItemID), withIntermediateDirectories: true)
***REMOVED***
***REMOVED***

private extension OfflineMapAreasView {
***REMOVED***enum FolderNames: String {
***REMOVED******REMOVED***case preplanned = "Preplanned"
***REMOVED******REMOVED***case offlineMapAreas = "OfflineMapAreas"
***REMOVED***
***REMOVED***
