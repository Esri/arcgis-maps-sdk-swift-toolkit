***REMOVED*** Copyright 2025 Esri
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

@MainActor
@preconcurrency
struct OfflineMapAreaItemView<Model: OfflineMapAreaItem>: View {
***REMOVED******REMOVED***/ The view model for the item view.
***REMOVED***@ObservedObject var model: Model
***REMOVED***
***REMOVED***let isSelected: Bool
***REMOVED***
***REMOVED***@State private var metadataViewIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The thumbnail image of the map area.
***REMOVED***@State private var thumbnailImage: UIImage?
***REMOVED***
***REMOVED***private let thumbnailSize: CGFloat = 64
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack(alignment: .center, spacing: 10) {
***REMOVED******REMOVED******REMOVED***thumbnailView
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED***titleView
***REMOVED******REMOVED******REMOVED******REMOVED***descriptionView
***REMOVED******REMOVED******REMOVED******REMOVED***statusView
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***trailingButton
***REMOVED***
***REMOVED******REMOVED***.contentShape(.rect)
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***metadataViewIsPresented = true
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $metadataViewIsPresented) {
***REMOVED******REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED******REMOVED***OfflineMapAreaMetadataView(model: model, isSelected: isSelected)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task { thumbnailImage = await model.thumbnailImage ***REMOVED***
***REMOVED******REMOVED******REMOVED***.task { await model.load() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var thumbnailView: some View {
***REMOVED******REMOVED***if let thumbnail = thumbnailImage {
***REMOVED******REMOVED******REMOVED***Image(uiImage: thumbnail)
***REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fill)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: thumbnailSize, height: thumbnailSize)
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 10))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Image(systemName: "map")
***REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: thumbnailSize, height: thumbnailSize)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(Color(uiColor: UIColor.systemGroupedBackground))
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 10))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var titleView: some View {
***REMOVED******REMOVED***Text(model.title)
***REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var descriptionView: some View {
***REMOVED******REMOVED***if !model.description.isEmpty {
***REMOVED******REMOVED******REMOVED***Text(model.description)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Text("No description available.")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var trailingButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED*** Download map area.
***REMOVED******REMOVED******REMOVED***model.startDownload()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Have to apply a style or it won't be tappable
***REMOVED******REMOVED******REMOVED*** because of the onTapGesture modifier in the parent view.
***REMOVED******REMOVED***.buttonStyle(.borderless)
***REMOVED******REMOVED***.disabled(!model.allowsDownload)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch downloadState {
***REMOVED******REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let map = model.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedMap = map
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Open")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonBorderShape(.capsule)
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(isSelected)
***REMOVED******REMOVED******REMOVED***case .downloading:
***REMOVED******REMOVED******REMOVED******REMOVED***if let job = model.job {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView(job.progress)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.gauge)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .notDownloaded:
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Download preplanned map area.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await model.downloadPreplannedMapArea()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Have to apply a style or it won't be tappable
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** because of the onTapGesture modifier in the parent view.
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderless)
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!model.status.allowsDownload)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var statusView: some View {
***REMOVED******REMOVED***HStack(spacing: 4) {
***REMOVED******REMOVED******REMOVED***Text("Placeholder")
***REMOVED******REMOVED******REMOVED******REMOVED***switch model.status {
***REMOVED******REMOVED******REMOVED******REMOVED***case .notLoaded, .loading:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading")
***REMOVED******REMOVED******REMOVED******REMOVED***case .loadFailure, .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading failed")
***REMOVED******REMOVED******REMOVED******REMOVED***case .packaging:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "clock.badge.xmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Packaging")
***REMOVED******REMOVED******REMOVED******REMOVED***case .packaged:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Ready to download")
***REMOVED******REMOVED******REMOVED******REMOVED***case .packageFailure:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Packaging failed")
***REMOVED******REMOVED******REMOVED******REMOVED***case .downloading:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Downloading")
***REMOVED******REMOVED******REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Downloaded")
***REMOVED******REMOVED******REMOVED******REMOVED***case .downloadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Download failed")
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED***
***REMOVED***

@MainActor
protocol OfflineMapAreaItem: ObservableObject, OfflineMapAreaMetadata {
***REMOVED***

#Preview {
***REMOVED***OfflineMapAreaItemView(model: MockMetadata(), isSelected: false)
***REMOVED***

private class MockMetadata: OfflineMapAreaItem {
***REMOVED***var title: String { "Redlands" ***REMOVED***
***REMOVED***var thumbnailImage: UIImage? { nil ***REMOVED***
***REMOVED***var description: String { "" ***REMOVED***
***REMOVED***var isDownloaded: Bool { true ***REMOVED***
***REMOVED***var allowsDownload: Bool { true ***REMOVED***
***REMOVED***var directorySize: Int { 1_000_000_000 ***REMOVED***
***REMOVED***
***REMOVED***func removeDownloadedArea() {***REMOVED***
***REMOVED***func startDownload() {***REMOVED***
***REMOVED***
