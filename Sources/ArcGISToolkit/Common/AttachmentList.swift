***REMOVED*** Copyright 2022 Esri
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

***REMOVED***/ A view displaying a list of attachments, with a thumbnail, title, and download button.
struct AttachmentList: View {
***REMOVED******REMOVED***/ The attachment models displayed in the list.
***REMOVED***var attachmentModels: [AttachmentModel]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ForEach(attachmentModels) { attachmentModel in
***REMOVED******REMOVED******REMOVED***AttachmentRow(attachmentModel: attachmentModel)
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view representing a single row in an `AttachmentList`.
struct AttachmentRow: View  {
***REMOVED******REMOVED***/ The model representing the attachment to display.
***REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED***
***REMOVED******REMOVED***/ The url of the the attachment, used to display the attachment via `QuickLook`.
***REMOVED***@State private var url: URL?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ThumbnailView(attachmentModel: attachmentModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(2)
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachmentModel.attachment.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.truncationMode(.middle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachmentModel.attachment.measuredSize, format: .byteCount(style: .file))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.loadStatus == .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Set the url to trigger `.quickLookPreview`.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url = attachmentModel.attachment.fileURL
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if attachmentModel.loadStatus != .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED***AttachmentLoadButton(attachmentModel: attachmentModel)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.quickLookPreview($url)
***REMOVED***
***REMOVED***

***REMOVED***/ View displaying a button used to load an attachment.
struct AttachmentLoadButton: View  {
***REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the download alert is presented.
***REMOVED***@State private var downloadAlertIsPresented = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***if attachmentModel.attachment.measuredSize.value.isZero {
***REMOVED******REMOVED******REMOVED******REMOVED***downloadAlertIsPresented = true
***REMOVED******REMOVED*** else if attachmentModel.loadStatus == .notLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel.load()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***switch attachmentModel.loadStatus {
***REMOVED******REMOVED******REMOVED******REMOVED***case .notLoaded:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "square.and.arrow.down")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
#if !os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.accentColor)
#endif
***REMOVED******REMOVED******REMOVED******REMOVED***case .loading:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***case .loaded:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(Color.clear)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(width: 24, height: 24)
***REMOVED******REMOVED******REMOVED***.padding(.leading)
***REMOVED***
***REMOVED******REMOVED***.alert(String.emptyAttachmentDownloadErrorMessage, isPresented: $downloadAlertIsPresented) { ***REMOVED***
***REMOVED***
***REMOVED***
