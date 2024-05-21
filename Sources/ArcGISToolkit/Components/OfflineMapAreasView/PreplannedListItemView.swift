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
***REMOVED******REMOVED***/ The packaging status for the preplanned map area.
***REMOVED***@State private var areaStatus: AreaStatus = .notLoaded
***REMOVED***
***REMOVED******REMOVED***/ The error for the preplanned map.
***REMOVED***@State var error: Error?
***REMOVED***
***REMOVED******REMOVED***/ The packaging status of the preplanned map area.
***REMOVED***private enum AreaStatus {
***REMOVED******REMOVED******REMOVED***/ The map area has not yet loaded.
***REMOVED******REMOVED***case notLoaded
***REMOVED******REMOVED******REMOVED***/ The map area is still packaging.
***REMOVED******REMOVED***case packaging
***REMOVED******REMOVED******REMOVED***/ The map area packaging is complete.
***REMOVED******REMOVED***case complete
***REMOVED******REMOVED******REMOVED***/ The map area packaging failed.
***REMOVED******REMOVED***case failed
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***HStack(alignment: .center, spacing: 10) {
***REMOVED******REMOVED******REMOVED***let preplannedMapArea = preplannedMapModel.preplannedMapArea
***REMOVED******REMOVED******REMOVED***if let thumbnail = preplannedMapModel.preplannedMapArea.portalItem.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED***LoadableImageView(loadableImage: thumbnail)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 64, height: 44)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 2))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(preplannedMapArea.portalItem.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!downloadButtonEnabled)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if !preplannedMapArea.portalItem.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(preplannedMapArea.portalItem.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("This area has no description.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***statusView
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onReceive(preplannedMapModel.preplannedMapArea.$loadStatus) { loadStatus in
***REMOVED******REMOVED******REMOVED***let packagingStatus = preplannedMapModel.preplannedMapArea.packagingStatus
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch loadStatus {
***REMOVED******REMOVED******REMOVED***case .loaded:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Allow downloading the map area when packaging is complete,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** or when the packaging status is `nil` for compatibility with
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** legacy webmaps that have incomplete metadata.
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.easeIn) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***areaStatus = (packagingStatus == .complete || packagingStatus == nil) ? .complete : .packaging
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .loading:
***REMOVED******REMOVED******REMOVED******REMOVED***if packagingStatus == .processing {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Disable downloading map area when still packaging.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***areaStatus = .packaging
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***areaStatus = .notLoaded
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .notLoaded:
***REMOVED******REMOVED******REMOVED******REMOVED***areaStatus = .notLoaded
***REMOVED******REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED******REMOVED***areaStatus = .failed
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Load preplanned map area to load packaging status.
***REMOVED******REMOVED******REMOVED******REMOVED***try await preplannedMapModel.preplannedMapArea.load()
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Present the error if the map area has been packaged. Otherwise,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** ignore the error when the map area is still packaging since the map
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** area cannot load while packaging.
***REMOVED******REMOVED******REMOVED******REMOVED***if preplannedMapModel.preplannedMapArea.packagingStatus == .complete {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.error = error
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var downloadButtonEnabled: Bool {
***REMOVED******REMOVED***return switch preplannedMapModel.result {
***REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED***case .failure:
***REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***switch areaStatus {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .packaging, .failed:
***REMOVED******REMOVED******REMOVED******REMOVED***false
***REMOVED******REMOVED******REMOVED***case .complete:
***REMOVED******REMOVED******REMOVED******REMOVED***true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder var statusView: some View {
***REMOVED******REMOVED***HStack(spacing: 4) {
***REMOVED******REMOVED******REMOVED***switch preplannedMapModel.result {
***REMOVED******REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Downloaded")
***REMOVED******REMOVED******REMOVED***case .failure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Download Failed")
***REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED***switch areaStatus {
***REMOVED******REMOVED******REMOVED******REMOVED***case .notLoaded:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Preplanned map area is still loading.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading")
***REMOVED******REMOVED******REMOVED******REMOVED***case .packaging:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Preplanned map area is still packaging.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "clock.badge.xmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Packaging")
***REMOVED******REMOVED******REMOVED******REMOVED***case .complete:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Package ready for download")
***REMOVED******REMOVED******REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if preplannedMapModel.preplannedMapArea.loadStatus == .failed {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading failed")
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Packaging failed")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED***
***REMOVED***
