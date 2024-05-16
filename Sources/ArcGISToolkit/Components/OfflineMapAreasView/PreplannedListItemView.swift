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
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the preplanned map area can be downloaded. This is `true`
***REMOVED******REMOVED***/ when the preplanned map area is loaded and the packaging status is `.complete`, and `false`
***REMOVED******REMOVED***/ when the packaging status is `.processing`. If the preplanned map area has not yet loaded then
***REMOVED******REMOVED***/ this is `nil`,
***REMOVED***@State private var canDownload: Bool?
***REMOVED***
***REMOVED******REMOVED***/ The error for the preplanned map.
***REMOVED***@State var error: Error?
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color(uiColor: .secondaryLabel))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("The area has no description.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color(uiColor: .tertiaryLabel))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let error {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(error.localizedDescription)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.red)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***switch preplannedMapModel.result {
***REMOVED******REMOVED******REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.error = error
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let canDownload {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !canDownload {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Map is still packaging.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "clock.badge.xmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("packaging")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Map package is available for download.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Map is still loading.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .trailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: 20)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.controlSize(.mini)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onReceive(preplannedMapModel.preplannedMapArea.$loadStatus) { status in
***REMOVED******REMOVED******REMOVED******REMOVED***let packagingStatus = preplannedMapModel.preplannedMapArea.packagingStatus
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***switch status {
***REMOVED******REMOVED******REMOVED******REMOVED***case .loaded:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Allow downloading the map area when packaging is complete.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.easeIn) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***canDownload = (packagingStatus == .complete || packagingStatus == nil) ? true : false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***case .loading:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Disable downloading the map area when packaging. Otherwise,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** do not set `canDownload` since the map area is still loading.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if packagingStatus == .processing {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Disable downloding map area when still packaging.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***canDownload = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***case .notLoaded:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Do not set `canDownload` until map has loaded.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Disable downloading when the map fails to load.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***canDownload = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Load preplanned map area to load packaging status.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await preplannedMapModel.preplannedMapArea.load()
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Present the error if the map area has been packaged. Otherwise,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** ignore the error when the map area is still packaging since the map
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** area cannot load while packaging.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if preplannedMapModel.preplannedMapArea.packagingStatus == .complete {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.error = error
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
