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
***REMOVED***@ObservedObject var model: PreplannedMapModel
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***HStack(alignment: .center, spacing: 10) {
***REMOVED******REMOVED******REMOVED***thumbnailView
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***titleView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***downloadButton
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***descriptionView
***REMOVED******REMOVED******REMOVED******REMOVED***statusView
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var thumbnailView: some View {
***REMOVED******REMOVED***if let thumbnail = model.preplannedMapArea.thumbnail {
***REMOVED******REMOVED******REMOVED***LoadableImageView(loadableImage: thumbnail)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 64, height: 44)
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 2))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var titleView: some View {
***REMOVED******REMOVED***Text(model.preplannedMapArea.title)
***REMOVED******REMOVED******REMOVED***.font(.body)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var downloadButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED***
***REMOVED******REMOVED***.disabled(!model.canDownload)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var descriptionView: some View {
***REMOVED******REMOVED***if !model.preplannedMapArea.description.isEmpty {
***REMOVED******REMOVED******REMOVED***Text(model.preplannedMapArea.description)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Text("This area has no description.")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var statusView: some View {
***REMOVED******REMOVED***HStack(spacing: 4) {
***REMOVED******REMOVED******REMOVED***switch model.status {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .loading:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading")
***REMOVED******REMOVED******REMOVED***case .loadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading failed")
***REMOVED******REMOVED******REMOVED***case .packaging:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "clock.badge.xmark")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Packaging")
***REMOVED******REMOVED******REMOVED***case .packaged:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Package ready for download")
***REMOVED******REMOVED******REMOVED***case .packageFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Packaging failed")
***REMOVED******REMOVED******REMOVED***case .downloading:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Downloading")
***REMOVED******REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Downloaded")
***REMOVED******REMOVED******REMOVED***case .downloadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Download failed")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***PreplannedListItemView(
***REMOVED******REMOVED***model: PreplannedMapModel(preplannedMapArea: MockPreplanneddMapArea())
***REMOVED***)
***REMOVED***.padding()
***REMOVED***

private struct MockPreplanneddMapArea: PreplannedMapAreaProtocol {
***REMOVED***var packagingStatus: ArcGIS.PreplannedMapArea.PackagingStatus? = .complete
***REMOVED***var title: String = "Mock Preaplanned Map Area"
***REMOVED***var description: String = "This is the description text"
***REMOVED***var thumbnail: ArcGIS.LoadableImage? = nil
***REMOVED***
***REMOVED***func retryLoad() async throws { ***REMOVED***
***REMOVED***
