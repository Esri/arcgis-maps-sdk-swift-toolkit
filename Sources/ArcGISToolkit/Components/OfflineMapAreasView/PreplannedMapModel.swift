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

***REMOVED***/ An object that encapsulates state about a preplanned map.
public class PreplannedMapModel: ObservableObject, Identifiable {
***REMOVED******REMOVED***/ The preplanned map area.
***REMOVED***let preplannedMapArea: PreplannedMapArea
***REMOVED***
***REMOVED******REMOVED***/ The task to use to take the area offline.
***REMOVED***let offlineMapTask: OfflineMapTask
***REMOVED***
***REMOVED******REMOVED***/ The directory where the mmpk will be stored.
***REMOVED***let mmpkDirectory: URL
***REMOVED***
***REMOVED******REMOVED***/ The currently running download job.
***REMOVED***@Published private(set) var job: DownloadPreplannedOfflineMapJob?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the map is being taken offline.
***REMOVED***var isDownloading: Bool {
***REMOVED******REMOVED***job != nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The result of the download job. When the result is `.success` the mobile map package is returned.
***REMOVED******REMOVED***/ If the result is `.failure` then the error is returned. The result will be `nil` when the preplanned
***REMOVED******REMOVED***/ map area is still packaging or loading.
***REMOVED***@Published private(set) var result: Result<MobileMapPackage, Error>?
***REMOVED***
***REMOVED***init?(
***REMOVED******REMOVED***offlineMapTask: OfflineMapTask,
***REMOVED******REMOVED***temporaryDirectory: URL,
***REMOVED******REMOVED***preplannedMapArea: PreplannedMapArea
***REMOVED***) {
***REMOVED******REMOVED***self.offlineMapTask = offlineMapTask
***REMOVED******REMOVED***self.preplannedMapArea = preplannedMapArea
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let itemID = preplannedMapArea.portalItem.id {
***REMOVED******REMOVED******REMOVED***self.mmpkDirectory = temporaryDirectory
***REMOVED******REMOVED******REMOVED******REMOVED***.appendingPathComponent(itemID.rawValue)
***REMOVED******REMOVED******REMOVED******REMOVED***.appendingPathExtension("mmpk")
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***

extension PreplannedMapModel {
***REMOVED******REMOVED***/ Downloads the given preplanned map area.
***REMOVED******REMOVED***/ - Parameter preplannedMapArea: The preplanned map area to be downloaded.
***REMOVED******REMOVED***/ - Precondition: `canDownload`
***REMOVED***@MainActor
***REMOVED***func downloadPreplannedMapArea() async {
***REMOVED******REMOVED***precondition(canDownload)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let parameters: DownloadPreplannedOfflineMapParameters
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED*** Creates the parameters for the download preplanned offline map job.
***REMOVED******REMOVED******REMOVED***parameters = try await makeParameters(preplannedMapArea: preplannedMapArea)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED*** If creating the parameters fails, set the failure.
***REMOVED******REMOVED******REMOVED***self.result = .failure(error)
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Creates the download preplanned offline map job.
***REMOVED******REMOVED***let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
***REMOVED******REMOVED******REMOVED***parameters: parameters,
***REMOVED******REMOVED******REMOVED***downloadDirectory: mmpkDirectory
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***   ***REMOVED*** jobManager.jobs.append(job)
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.job = job
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Starts the job.
***REMOVED******REMOVED***job.start()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Awaits the output of the job and assigns the result.
***REMOVED******REMOVED***result = await job.result.map { $0.mobileMapPackage ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Sets the job to nil
***REMOVED******REMOVED***self.job = nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the offline map can be downloaded.
***REMOVED******REMOVED***/ This returns `false` if the map was already downloaded successfully or is in the process
***REMOVED******REMOVED***/ of being downloaded.
***REMOVED***var canDownload: Bool {
***REMOVED******REMOVED***!(isDownloading || downloadDidSucceed)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the download succeeded.
***REMOVED***var downloadDidSucceed: Bool {
***REMOVED******REMOVED***if case .success = result {
***REMOVED******REMOVED******REMOVED***return true
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates the parameters for a download preplanned offline map job.
***REMOVED******REMOVED***/ - Parameter preplannedMapArea: The preplanned map area to create parameters for.
***REMOVED******REMOVED***/ - Returns: A `DownloadPreplannedOfflineMapParameters` if there are no errors.
***REMOVED***func makeParameters(preplannedMapArea: PreplannedMapArea) async throws -> DownloadPreplannedOfflineMapParameters {
***REMOVED******REMOVED******REMOVED*** Creates the default parameters.
***REMOVED******REMOVED***let parameters = try await offlineMapTask.makeDefaultDownloadPreplannedOfflineMapParameters(preplannedMapArea: preplannedMapArea)
***REMOVED******REMOVED******REMOVED*** Sets the update mode to no updates as the offline map is display-only.
***REMOVED******REMOVED***parameters.updateMode = .noUpdates
***REMOVED******REMOVED***return parameters
***REMOVED***
***REMOVED***

extension PreplannedMapModel: Hashable {
***REMOVED***public static func == (lhs: PreplannedMapModel, rhs: PreplannedMapModel) -> Bool {
***REMOVED******REMOVED***lhs === rhs
***REMOVED***
***REMOVED***
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(ObjectIdentifier(self))
***REMOVED***
***REMOVED***
