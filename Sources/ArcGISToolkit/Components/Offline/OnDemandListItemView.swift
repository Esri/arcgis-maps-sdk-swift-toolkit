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

struct OnDemandListItemView: View {
***REMOVED***@ObservedObject var model: OnDemandMapModel
***REMOVED***
***REMOVED******REMOVED***/ The currently selected map.
***REMOVED***@Binding var selectedMap: Map?
***REMOVED***
***REMOVED******REMOVED***/ The download state of the preplanned map model.
***REMOVED***fileprivate enum DownloadState {
***REMOVED******REMOVED***case initialized, downloading, downloaded
***REMOVED***
***REMOVED***
***REMOVED***@State private var downloadState: DownloadState = .initialized
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the metadata view is presented.
***REMOVED***@State private var metadataViewIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss: DismissAction
***REMOVED***
***REMOVED***var isSelected: Bool {
***REMOVED******REMOVED***selectedMap?.item?.title == model.title
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
***REMOVED******REMOVED******REMOVED***if model.status.isDownloaded {
***REMOVED******REMOVED******REMOVED******REMOVED***metadataViewIsPresented = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $metadataViewIsPresented) {
***REMOVED******REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED******REMOVED***OnDemandMetadataView(model: model, isSelected: isSelected)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***downloadState = .init(model.status)
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
***REMOVED******REMOVED*** What should we do with the thumbnail? Save our own or use the default one?
***REMOVED***@ViewBuilder private var thumbnailView: some View {
***REMOVED******REMOVED***if downloadState == .downloaded,
***REMOVED******REMOVED***   let thumbnail = model.thumbnail {
***REMOVED******REMOVED******REMOVED***LoadableImageView(loadableImage: thumbnail)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 64, height: 44)
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 2))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Image(systemName: "photo.badge.arrow.down")
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 64, height: 44)
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 2))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var titleView: some View {
***REMOVED******REMOVED***Text(model.title)
***REMOVED******REMOVED******REMOVED***.font(.body)
***REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var descriptionView: some View {
***REMOVED******REMOVED***if !model.description.isEmpty {
***REMOVED******REMOVED******REMOVED***Text(model.description)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var downloadButton: some View {
***REMOVED******REMOVED***switch downloadState {
***REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let map = model.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedMap = map
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED***case .initialized:
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await model.downloadOnDemandMapArea()
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
***REMOVED***private var openStatusView: some View {
***REMOVED******REMOVED***Text("Currently open")
***REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED***.foregroundStyle(.tertiary)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var statusView: some View {
***REMOVED******REMOVED***HStack(spacing: 4) {
***REMOVED******REMOVED******REMOVED***switch model.status {
***REMOVED******REMOVED******REMOVED***case .initialized:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading")
***REMOVED******REMOVED******REMOVED***case .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading failed")
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

private extension OnDemandListItemView.DownloadState {
***REMOVED******REMOVED***/ Creates an instance.
***REMOVED******REMOVED***/ - Parameter state: The preplanned map model download state.
***REMOVED***init(_ state: OnDemandMapModel.Status) {
***REMOVED******REMOVED***self = switch state {
***REMOVED******REMOVED***case .downloaded: .downloaded
***REMOVED******REMOVED***case .downloading: .downloading
***REMOVED******REMOVED***default: .initialized
***REMOVED***
***REMOVED***
***REMOVED***
