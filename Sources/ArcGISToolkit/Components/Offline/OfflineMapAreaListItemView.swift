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

***REMOVED***/ A view that shows information for an offline area for use in a List.
@MainActor
struct OfflineMapAreaListItemView<Model: OfflineMapAreaListItemInfo, TrailingContent: View>: View {
***REMOVED******REMOVED***/ Creates an `OfflineMapAreaItemView`.
***REMOVED***init(
***REMOVED******REMOVED***model: Model,
***REMOVED******REMOVED***isSelected: Bool,
***REMOVED******REMOVED***@ViewBuilder trailingContent: @escaping () -> TrailingContent)
***REMOVED***{
***REMOVED******REMOVED***self.model = model
***REMOVED******REMOVED***self.isSelected = isSelected
***REMOVED******REMOVED***self.trailingContent = trailingContent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***/ The view model for the item view.
***REMOVED***@ObservedObject var model: Model
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the map is currently selected.
***REMOVED***let isSelected: Bool
***REMOVED***
***REMOVED******REMOVED***/ The content to display in the card.
***REMOVED***let trailingContent: () -> TrailingContent
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the metadata view is presented.
***REMOVED***@State private var metadataViewIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The thumbnail image of the map area.
***REMOVED***@State private var thumbnailImage: UIImage?
***REMOVED***
***REMOVED******REMOVED***/ The size of the thumbnail.
***REMOVED***private let thumbnailSize: CGFloat = 64
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***metadataViewIsPresented = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .center, spacing: 12) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***titleView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***descriptionView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***statusView
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(.rect)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED***trailingContent()
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $metadataViewIsPresented) {
***REMOVED******REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED******REMOVED***OfflineMapAreaMetadataView(model: model, isSelected: isSelected)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task { thumbnailImage = await model.thumbnailImage ***REMOVED***
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
***REMOVED******REMOVED******REMOVED***.font(.callout)
***REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var descriptionView: some View {
***REMOVED******REMOVED***if !model.listItemDescription.isEmpty {
***REMOVED******REMOVED******REMOVED***Text(model.listItemDescription)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var statusView: some View {
***REMOVED******REMOVED***HStack(spacing: 4) {
***REMOVED******REMOVED******REMOVED***if isSelected {
***REMOVED******REMOVED******REMOVED******REMOVED***Text.init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Currently open",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "The status text for an opened map area."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***if !model.statusSystemImage.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: model.statusSystemImage)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Text(model.statusText)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED***
***REMOVED***

@MainActor
protocol OfflineMapAreaListItemInfo: ObservableObject, OfflineMapAreaMetadata {
***REMOVED***var listItemDescription: String { get ***REMOVED***
***REMOVED***var statusText: String { get ***REMOVED***
***REMOVED***var statusSystemImage: String { get ***REMOVED***
***REMOVED***var jobProgress: Progress? { get ***REMOVED***
***REMOVED***
***REMOVED***func cancelJob()
***REMOVED***

#Preview {
***REMOVED***OfflineMapAreaListItemView(model: MockMetadata(), isSelected: false) {
***REMOVED******REMOVED***Button {***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Have to apply a style or it won't be tappable
***REMOVED******REMOVED******REMOVED*** because of the button the parent view.
***REMOVED******REMOVED***.buttonStyle(.borderless)
***REMOVED***
***REMOVED***

private class MockMetadata: OfflineMapAreaListItemInfo {
***REMOVED***var title: String { "Redlands" ***REMOVED***
***REMOVED***var thumbnailImage: UIImage? { nil ***REMOVED***
***REMOVED***var listItemDescription: String { "123 MB" ***REMOVED***
***REMOVED***var description: String { "" ***REMOVED***
***REMOVED***var isDownloaded: Bool { true ***REMOVED***
***REMOVED***var allowsDownload: Bool { true ***REMOVED***
***REMOVED***var directorySize: Int { 1_000_000_000 ***REMOVED***
***REMOVED***var statusText: String { "Downloaded" ***REMOVED***
***REMOVED***var statusSystemImage: String { "exclamationmark.circle" ***REMOVED***
***REMOVED***var jobProgress: Progress? { nil ***REMOVED***
***REMOVED***var dismissMetadataViewOnDelete: Bool { false ***REMOVED***
***REMOVED***
***REMOVED***func removeDownloadedArea() {***REMOVED***
***REMOVED***func startDownload() {***REMOVED***
***REMOVED***func cancelJob() {***REMOVED***
***REMOVED***

***REMOVED***/ A Button for opening a map area.
struct OpenOfflineMapAreaButton: View {
***REMOVED******REMOVED***/ The currently selected map.
***REMOVED***@Binding var selectedMap: Map?

***REMOVED******REMOVED***/ The map to open.
***REMOVED***let map: Map?
***REMOVED***
***REMOVED******REMOVED***/ Whether or not the map is open.
***REMOVED***let isSelected: Bool
***REMOVED***
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED******REMOVED***/ Note: if this is not passed in to this view, and we use
***REMOVED******REMOVED***/ the environment here, it doesn't work.
***REMOVED***let dismiss: DismissAction
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***if let map {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedMap = map
***REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text.init(
***REMOVED******REMOVED******REMOVED******REMOVED***"Open",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "The label for a button to open a map area."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED***.buttonBorderShape(.capsule)
***REMOVED******REMOVED***.disabled(isSelected)
***REMOVED***
***REMOVED***

***REMOVED***/ A button for downloading a map area.
***REMOVED***/ This button is meant to be used in the `OfflineMapAreaItemView`.
struct DownloadOfflineMapAreaButton<Model: OfflineMapAreaListItemInfo>: View {
***REMOVED******REMOVED***/ The view model for the item view.
***REMOVED***@ObservedObject var model: Model
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***model.startDownload()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Have to apply a style or it won't be tappable
***REMOVED******REMOVED******REMOVED*** because of the button the parent view.
***REMOVED******REMOVED***.buttonStyle(.borderless)
***REMOVED******REMOVED***.disabled(!model.allowsDownload)
***REMOVED***
***REMOVED***

***REMOVED***/ A view for displaying the progress of an offline job.
***REMOVED***/ This button is meant to be used in the `OfflineMapAreaItemView`.
struct OfflineJobProgressView<Model: OfflineMapAreaListItemInfo>: View {
***REMOVED******REMOVED***/ The view model for the item view.
***REMOVED***@ObservedObject var model: Model
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if let progress = model.jobProgress {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***model.cancelJob()
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView(progress)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.cancelGauge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Have to apply a style or it won't be tappable
***REMOVED******REMOVED******REMOVED******REMOVED*** because of the button the parent view.
***REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED***
***REMOVED***
***REMOVED***
