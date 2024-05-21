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
***REMOVED***let preplannedMapArea: PreplannedMapArea
***REMOVED***
***REMOVED******REMOVED***/ The result of the download job. When the result is `.success` the mobile map package is returned.
***REMOVED******REMOVED***/ If the result is `.failure` then the error is returned. The result will be `nil` when the preplanned
***REMOVED******REMOVED***/ map area is still packaging or loading.
***REMOVED***@Published private(set) var result: Result<MobileMapPackage, Error>?
***REMOVED***
***REMOVED******REMOVED***/ The combined status of the preplanned map area.
***REMOVED***@Published private(set) var status: PreplannedMapAreaStatus = .notLoaded
***REMOVED***
***REMOVED***init(preplannedMapArea: PreplannedMapArea) {
***REMOVED******REMOVED***self.preplannedMapArea = preplannedMapArea
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Kick off a load of the map area.
***REMOVED******REMOVED***Task.detached { await self.load() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func load() async {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED*** Load preplanned map area to obtain packaging status.
***REMOVED******REMOVED******REMOVED***status = .loading
***REMOVED******REMOVED******REMOVED***try await preplannedMapArea.load()
***REMOVED******REMOVED******REMOVED******REMOVED*** Note: Packaging status is `nil` for compatibility with
***REMOVED******REMOVED******REMOVED******REMOVED*** legacy webmaps that have incomplete metadata.
***REMOVED******REMOVED******REMOVED***updateAreaStatus(for: preplannedMapArea.packagingStatus ?? .complete)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***status = .loadFailure(error)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func updateAreaStatus(for packagingStatus: PreplannedMapArea.PackagingStatus) {
***REMOVED******REMOVED******REMOVED*** Update area status for a given packaging status.
***REMOVED******REMOVED***switch packagingStatus {
***REMOVED******REMOVED***case .processing:
***REMOVED******REMOVED******REMOVED***status = .packaging
***REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED***status = .packageFailure
***REMOVED******REMOVED***case .complete:
***REMOVED******REMOVED******REMOVED***status = .packaged
***REMOVED***
***REMOVED***
***REMOVED***

enum PreplannedMapAreaStatus {
***REMOVED***case notLoaded
***REMOVED***case loading
***REMOVED***case loadFailure(Error)
***REMOVED***case packaging
***REMOVED***case packaged
***REMOVED***case packageFailure
***REMOVED***case downloading
***REMOVED***case downloaded
***REMOVED***case downloadFailure
***REMOVED***
