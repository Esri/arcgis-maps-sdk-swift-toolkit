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

@MainActor
@preconcurrency
struct PreplannedListItemView: View {
***REMOVED******REMOVED***/ The view model for the preplanned map.
***REMOVED***@ObservedObject var model: PreplannedMapModel
***REMOVED***
***REMOVED******REMOVED***/ The currently selected map.
***REMOVED***@Binding var selectedMap: Map?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the metadata view is presented.
***REMOVED***@State private var metadataViewIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The download state of the preplanned map model.
***REMOVED***fileprivate enum DownloadState {
***REMOVED******REMOVED***case notDownloaded, downloading, downloaded
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current download state of the preplanned map model.
***REMOVED***@State private var downloadState: DownloadState = .notDownloaded
***REMOVED***
***REMOVED******REMOVED***/ The previous download state of the preplanned map model.
***REMOVED***@State private var previousDownloadState: DownloadState = .notDownloaded
***REMOVED***
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss: DismissAction
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the selected map area is the same
***REMOVED******REMOVED***/ as the map area from this model.
***REMOVED******REMOVED***/ The title of a preplanned map area is guaranteed to be unique when it
***REMOVED******REMOVED***/ is created.
***REMOVED***var isSelected: Bool {
***REMOVED******REMOVED***selectedMap?.item?.title == model.preplannedMapArea.title
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack(alignment: .center, spacing: 10) {
***REMOVED******REMOVED******REMOVED***thumbnailView
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***titleView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***downloadButton
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***descriptionView
***REMOVED******REMOVED******REMOVED******REMOVED***if isSelected {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***openStatusView
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***statusView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.contentShape(.rect)
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***metadataViewIsPresented = true
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $metadataViewIsPresented) {
***REMOVED******REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED******REMOVED***PreplannedMetadataView(model: model, isSelected: isSelected)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***await model.load()
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***downloadState = .init(model.status)
***REMOVED******REMOVED******REMOVED***previousDownloadState = downloadState
***REMOVED***
***REMOVED******REMOVED***.onReceive(model.$status) { status in
***REMOVED******REMOVED******REMOVED***let downloadState = DownloadState(status)
***REMOVED******REMOVED******REMOVED***withAnimation(
***REMOVED******REMOVED******REMOVED******REMOVED***downloadState == .downloaded ? .easeInOut : nil
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***self.downloadState = downloadState
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
***REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var downloadButton: some View {
***REMOVED******REMOVED***switch downloadState {
***REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***if let map = model.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedMap = map
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Open")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.bold)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED***.buttonBorderShape(.capsule)
***REMOVED******REMOVED******REMOVED***.disabled(isSelected)
***REMOVED******REMOVED***case .downloading:
***REMOVED******REMOVED******REMOVED***if let job = model.job {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView(job.progress)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.gauge)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .notDownloaded:
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Download preplanned map area.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await model.downloadPreplannedMapArea()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.down.circle")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED***.disabled(!model.status.allowsDownload)
***REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.accentColor)
***REMOVED***
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
***REMOVED***private var openStatusView: some View {
***REMOVED******REMOVED***HStack(spacing: 4) {
***REMOVED******REMOVED******REMOVED***Text("Currently open")
***REMOVED***
***REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var statusView: some View {
***REMOVED******REMOVED***HStack(spacing: 4) {
***REMOVED******REMOVED******REMOVED***switch model.status {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .loading:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading")
***REMOVED******REMOVED******REMOVED***case .loadFailure, .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading failed")
***REMOVED******REMOVED******REMOVED***case .packaging:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "clock.badge.xmark")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Packaging")
***REMOVED******REMOVED******REMOVED***case .packaged:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Ready to download")
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

private extension PreplannedListItemView.DownloadState {
***REMOVED******REMOVED***/ Creates an instance.
***REMOVED******REMOVED***/ - Parameter state: The preplanned map model download state.
***REMOVED***init(_ state: PreplannedMapModel.Status) {
***REMOVED******REMOVED***self = switch state {
***REMOVED******REMOVED***case .downloaded: .downloaded
***REMOVED******REMOVED***case .downloading: .downloading
***REMOVED******REMOVED***default: .notDownloaded
***REMOVED***
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***struct MockPreplannedMapArea: PreplannedMapAreaProtocol {
***REMOVED******REMOVED***var packagingStatus: PreplannedMapArea.PackagingStatus? { .complete ***REMOVED***
***REMOVED******REMOVED***var title: String { "Mock Preplanned Map Area" ***REMOVED***
***REMOVED******REMOVED***var description: String { "This is the description text" ***REMOVED***
***REMOVED******REMOVED***var thumbnail: LoadableImage? { nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func retryLoad() async throws { ***REMOVED***
***REMOVED******REMOVED***func makeParameters(using offlineMapTask: OfflineMapTask) async throws -> DownloadPreplannedOfflineMapParameters {
***REMOVED******REMOVED******REMOVED***DownloadPreplannedOfflineMapParameters()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***return PreplannedListItemView(
***REMOVED******REMOVED***model: PreplannedMapModel(
***REMOVED******REMOVED******REMOVED***offlineMapTask: OfflineMapTask(onlineMap: Map()),
***REMOVED******REMOVED******REMOVED***mapArea: MockPreplannedMapArea(),
***REMOVED******REMOVED******REMOVED***portalItemID: .init("preview")!,
***REMOVED******REMOVED******REMOVED***preplannedMapAreaID: .init("preview")!,
***REMOVED******REMOVED******REMOVED***onRemoveDownload: {***REMOVED***
***REMOVED******REMOVED***),
***REMOVED******REMOVED***selectedMap: .constant(nil)
***REMOVED***)
***REMOVED***.padding()
***REMOVED***
