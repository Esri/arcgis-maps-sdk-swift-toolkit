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

public struct PreplannedListItemView: View {
***REMOVED******REMOVED***/ The view model for the preplanned map.
***REMOVED***@ObservedObject var preplannedMapModel: PreplannedMapModel
***REMOVED******REMOVED***/ A Boolean value indicating whether the preplanned map area can be downloaded.
***REMOVED***@State private var canDownload: Bool?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***let preplannedMapArea = preplannedMapModel.preplannedMapArea
***REMOVED******REMOVED******REMOVED******REMOVED***if let thumbnail = preplannedMapModel.preplannedMapArea.portalItem.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***LoadableImageView(loadableImage: thumbnail)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 64, height: 44)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 2) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(preplannedMapArea.portalItem.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.headline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !preplannedMapArea.portalItem.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(preplannedMapArea.portalItem.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***switch preplannedMapModel.result {
***REMOVED******REMOVED******REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED***case .failure:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let canDownload {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !canDownload {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Map is still packaging.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "clock.badge.xmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Map package is available for download.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onReceive(preplannedMapModel.preplannedMapArea.$loadStatus) { status in
***REMOVED******REMOVED******REMOVED******REMOVED***let packagingStatus = preplannedMapModel.preplannedMapArea.packagingStatus
***REMOVED******REMOVED******REMOVED******REMOVED***if status == .failed || packagingStatus == .processing {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If the preplanned map area fails to load, it may not be packaged.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***canDownload = false
***REMOVED******REMOVED******REMOVED*** else if packagingStatus == .complete || packagingStatus == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Otherwise, check the packaging status to determine if the map area is
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** available to download.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***canDownload = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await preplannedMapModel.preplannedMapArea.load()
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print(error)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
