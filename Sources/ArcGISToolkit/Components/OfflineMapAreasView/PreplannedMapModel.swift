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
@MainActor
class PreplannedMapModel: ObservableObject, Identifiable {
***REMOVED******REMOVED***/ The preplanned map area.
***REMOVED***let preplannedMapArea: any PreplannedMapAreaProtocol
***REMOVED***
***REMOVED******REMOVED***/ The combined status of the preplanned map area.
***REMOVED***@Published private(set) var status: Status = .notLoaded
***REMOVED***
***REMOVED***init(preplannedMapArea: PreplannedMapAreaProtocol) {
***REMOVED******REMOVED***self.preplannedMapArea = preplannedMapArea
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the preplanned map area and updates the status.
***REMOVED***func load() async {
***REMOVED******REMOVED***guard status.needsToBeLoaded else { return ***REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED*** Load preplanned map area to obtain packaging status.
***REMOVED******REMOVED******REMOVED***status = .loading
***REMOVED******REMOVED******REMOVED***try await preplannedMapArea.retryLoad()
***REMOVED******REMOVED******REMOVED******REMOVED*** Note: Packaging status is `nil` for compatibility with
***REMOVED******REMOVED******REMOVED******REMOVED*** legacy webmaps that have incomplete metadata.
***REMOVED******REMOVED******REMOVED******REMOVED*** If the area loads, then you know for certain the status is complete.
***REMOVED******REMOVED******REMOVED***updateStatus(for: preplannedMapArea.packagingStatus ?? .complete)
***REMOVED*** catch MappingError.packagingNotComplete {
***REMOVED******REMOVED******REMOVED******REMOVED*** Load will throw an `MappingError.packagingNotComplete` error if not complete,
***REMOVED******REMOVED******REMOVED******REMOVED*** this case is not a normal load failure.
***REMOVED******REMOVED******REMOVED***updateStatus(for: preplannedMapArea.packagingStatus ?? .failed)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED*** Normal load failure.
***REMOVED******REMOVED******REMOVED***status = .loadFailure(error)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the status for a given packaging status.
***REMOVED***private func updateStatus(for packagingStatus: PreplannedMapArea.PackagingStatus) {
***REMOVED******REMOVED******REMOVED*** Update area status for a given packaging status.
***REMOVED******REMOVED***switch packagingStatus {
***REMOVED******REMOVED***case .processing:
***REMOVED******REMOVED******REMOVED***status = .packaging
***REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED***status = .packageFailure
***REMOVED******REMOVED***case .complete:
***REMOVED******REMOVED******REMOVED***status = .packaged
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***fatalError("Unknown packaging status")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if download can be called.
***REMOVED***var canDownload: Bool {
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case .notLoaded, .loading, .loadFailure, .packaging, .packageFailure,
***REMOVED******REMOVED******REMOVED******REMOVED***.downloading, .downloaded:
***REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED***case .packaged, .downloadFailure:
***REMOVED******REMOVED******REMOVED***true
***REMOVED***
***REMOVED***
***REMOVED***

extension PreplannedMapModel {
***REMOVED******REMOVED***/ The status of the preplanned map area model.
***REMOVED***enum Status {
***REMOVED******REMOVED******REMOVED***/ Preplanned map area not loaded.
***REMOVED******REMOVED***case notLoaded
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is loading.
***REMOVED******REMOVED***case loading
***REMOVED******REMOVED******REMOVED***/ Preplanned map area failed to load.
***REMOVED******REMOVED***case loadFailure(Error)
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is packaging.
***REMOVED******REMOVED***case packaging
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is packaged and ready for download.
***REMOVED******REMOVED***case packaged
***REMOVED******REMOVED******REMOVED***/ Preplanned map area packaging failed.
***REMOVED******REMOVED***case packageFailure
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is being downloaded.
***REMOVED******REMOVED***case downloading
***REMOVED******REMOVED******REMOVED***/ Preplanned map area is downloaded.
***REMOVED******REMOVED***case downloaded
***REMOVED******REMOVED******REMOVED***/ Preplanned map area failed to download.
***REMOVED******REMOVED***case downloadFailure(Error)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the model is in a state
***REMOVED******REMOVED******REMOVED***/ where it needs to be loaded or reloaded.
***REMOVED******REMOVED***var needsToBeLoaded: Bool {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .loading, .packaging, .packaged, .downloading, .downloaded:
***REMOVED******REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A type that acts as a preplanned map area.
protocol PreplannedMapAreaProtocol {
***REMOVED***func retryLoad() async throws
***REMOVED***
***REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? { get ***REMOVED***
***REMOVED***var title: String { get ***REMOVED***
***REMOVED***var description: String { get ***REMOVED***
***REMOVED***var thumbnail: LoadableImage? { get ***REMOVED***
***REMOVED***

***REMOVED***/ Extend `PreplannedMapArea` to conform to `PreplannedMapAreaProtocol`.
extension PreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED***var title: String {
***REMOVED******REMOVED***portalItem.title
***REMOVED***
***REMOVED***
***REMOVED***var thumbnail: LoadableImage? {
***REMOVED******REMOVED***portalItem.thumbnail
***REMOVED***
***REMOVED***
***REMOVED***var description: String {
***REMOVED******REMOVED***portalItem.description
***REMOVED***
***REMOVED***
