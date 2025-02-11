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
***REMOVED******REMOVED***/ The model for this view.
***REMOVED***@ObservedObject var model: OnDemandMapModel
***REMOVED***
***REMOVED******REMOVED***/ The currently selected map.
***REMOVED***@Binding var selectedMap: Map?
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
***REMOVED******REMOVED***OfflineMapAreaListItemView(model: model, isSelected: isSelected) {
***REMOVED******REMOVED******REMOVED***trailingButton
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var trailingButton: some View {
***REMOVED******REMOVED***switch model.status {
***REMOVED******REMOVED***case .downloading:
***REMOVED******REMOVED******REMOVED***OfflineJobProgressView(model: model)
***REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED***OpenOfflineMapAreaButton(
***REMOVED******REMOVED******REMOVED******REMOVED***selectedMap: $selectedMap,
***REMOVED******REMOVED******REMOVED******REMOVED***map: model.map,
***REMOVED******REMOVED******REMOVED******REMOVED***isSelected: isSelected,
***REMOVED******REMOVED******REMOVED******REMOVED***dismiss: dismiss
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .initialized:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED***case .downloadCancelled, .downloadFailure, .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED***removeDownloadButton
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private var removeDownloadButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***model.removeDownloadedArea()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Have to apply a style or it won't be tappable
***REMOVED******REMOVED******REMOVED*** because of the onTapGesture modifier in the parent view.
***REMOVED******REMOVED***.buttonStyle(.borderless)
***REMOVED***
***REMOVED***

extension OnDemandMapModel: OfflineMapAreaMetadata {
***REMOVED***var description: String { "" ***REMOVED***
***REMOVED***var isDownloaded: Bool { status.isDownloaded ***REMOVED***
***REMOVED***var thumbnailImage: UIImage? { thumbnail ***REMOVED***
***REMOVED***var allowsDownload: Bool { false ***REMOVED***
***REMOVED***var dismissMetadataViewOnDelete: Bool { true ***REMOVED***
***REMOVED***func startDownload() { fatalError() ***REMOVED***
***REMOVED***

extension OnDemandMapModel: OfflineMapAreaListItemInfo {
***REMOVED***var listItemDescription: String {
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED***directorySizeText
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***""
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var statusText: String {
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case .initialized:
***REMOVED******REMOVED******REMOVED***"Loading"
***REMOVED******REMOVED***case .mmpkLoadFailure:
***REMOVED******REMOVED******REMOVED***"Loading failed"
***REMOVED******REMOVED***case .downloading:
***REMOVED******REMOVED******REMOVED***"Downloading"
***REMOVED******REMOVED***case .downloaded:
***REMOVED******REMOVED******REMOVED***"Downloaded"
***REMOVED******REMOVED***case .downloadFailure:
***REMOVED******REMOVED******REMOVED***"Download failed"
***REMOVED******REMOVED***case .downloadCancelled:
***REMOVED******REMOVED******REMOVED***"Cancelled"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The system image for the current status.
***REMOVED***var statusSystemImage: String {
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case .initialized, .downloading, .downloaded, .downloadCancelled:
***REMOVED******REMOVED******REMOVED***""
***REMOVED******REMOVED***case .mmpkLoadFailure, .downloadFailure:
***REMOVED******REMOVED******REMOVED***"exclamationmark.circle"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var jobProgress: Progress? { job?.progress ***REMOVED***
***REMOVED***
