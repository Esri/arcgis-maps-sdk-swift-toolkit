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
struct PreplannedListItemView: View {
***REMOVED******REMOVED***/ The view model for the preplanned map.
***REMOVED***@ObservedObject var model: PreplannedMapModel
***REMOVED***
***REMOVED******REMOVED***/ The currently selected map.
***REMOVED***@Binding var selectedMap: Map?
***REMOVED***
***REMOVED******REMOVED***/ The action to dismiss the view.
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the selected map area is the same
***REMOVED******REMOVED***/ as the map area from this model.
***REMOVED******REMOVED***/ The title of a preplanned map area is guaranteed to be unique when it
***REMOVED******REMOVED***/ is created.
***REMOVED***var isSelected: Bool {
***REMOVED******REMOVED***selectedMap?.item?.title == model.preplannedMapArea.title
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the view should dismiss.
***REMOVED***let shouldDismiss: Bool
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***OfflineMapAreaListItemView(model: model, isSelected: isSelected) {
***REMOVED******REMOVED******REMOVED***trailingButton
***REMOVED***
***REMOVED******REMOVED***.task { await model.load() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var trailingButton: some View {
***REMOVED******REMOVED***switch model.status {
***REMOVED******REMOVED***case .notLoaded, .loadFailure, .packaging, .packageFailure, .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED***case .loading:
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED***case .packaged, .downloadFailure, .downloadCancelled:
***REMOVED******REMOVED******REMOVED***DownloadOfflineMapAreaButton(model: model)
***REMOVED******REMOVED***case .downloading:
***REMOVED******REMOVED******REMOVED***OfflineJobProgressView(model: model)
***REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED***OpenOfflineMapAreaButton(
***REMOVED******REMOVED******REMOVED******REMOVED***selectedMap: $selectedMap,
***REMOVED******REMOVED******REMOVED******REMOVED***map: model.map,
***REMOVED******REMOVED******REMOVED******REMOVED***isSelected: isSelected,
***REMOVED******REMOVED******REMOVED******REMOVED***dismiss: shouldDismiss ? dismiss : nil
***REMOVED******REMOVED******REMOVED***)
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
***REMOVED******REMOVED***selectedMap: .constant(nil),
***REMOVED******REMOVED***shouldDismiss: true
***REMOVED***)
***REMOVED***.padding()
***REMOVED***

extension PreplannedMapModel: OfflineMapAreaMetadata {
***REMOVED***var thumbnailImage: UIImage? {
***REMOVED******REMOVED***get async {
***REMOVED******REMOVED******REMOVED***try? await preplannedMapArea.thumbnail?.load()
***REMOVED******REMOVED******REMOVED***return preplannedMapArea.thumbnail?.image
***REMOVED***
***REMOVED***
***REMOVED***var title: String { preplannedMapArea.title ***REMOVED***
***REMOVED***var description: String { preplannedMapArea.description ***REMOVED***
***REMOVED***var isDownloaded: Bool { status.isDownloaded ***REMOVED***
***REMOVED***var allowsDownload: Bool { status.allowsDownload ***REMOVED***
***REMOVED***var dismissMetadataViewOnDelete: Bool { false ***REMOVED***
***REMOVED***
***REMOVED***func startDownload() {
***REMOVED******REMOVED***Task { await downloadPreplannedMapArea() ***REMOVED***
***REMOVED***
***REMOVED***

extension PreplannedMapModel: OfflineMapAreaListItemInfo {
***REMOVED***var listItemDescription: String { description ***REMOVED***
***REMOVED***
***REMOVED***var statusText: LocalizedStringResource {
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case .notLoaded, .loading: .loading
***REMOVED******REMOVED***case .loadFailure, .mmpkLoadFailure: .loadingFailed
***REMOVED******REMOVED***case .packaging: .packaging
***REMOVED******REMOVED***case .packaged: .readyToDownload
***REMOVED******REMOVED***case .packageFailure: .packagingFailed
***REMOVED******REMOVED***case .downloading: .downloading
***REMOVED******REMOVED***case .downloaded: .downloaded
***REMOVED******REMOVED***case .downloadFailure: .downloadFailed
***REMOVED******REMOVED***case .downloadCancelled: .cancelled
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var statusSystemImage: String {
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case .notLoaded, .loading, .packaged, .downloaded, .downloading, .downloadCancelled:
***REMOVED******REMOVED******REMOVED***""
***REMOVED******REMOVED***case .loadFailure, .mmpkLoadFailure, .downloadFailure:
***REMOVED******REMOVED******REMOVED***"exclamationmark.circle"
***REMOVED******REMOVED***case .packaging:
***REMOVED******REMOVED******REMOVED***"clock.badge.xmark"
***REMOVED******REMOVED***case .packageFailure:
***REMOVED******REMOVED******REMOVED***"exclamationmark.circle"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var jobProgress: Progress? { job?.progress ***REMOVED***
***REMOVED***

private extension LocalizedStringResource {
***REMOVED***static var packaging: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Packaging",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "The status text when a map area is packaging."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var readyToDownload: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Ready to download",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "The status text when a map area is ready to download."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var packagingFailed: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Packaging failed",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "The status text when a map area packaging failed."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var cancelled: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Cancelled",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "The status text when a map area download is cancelled."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
