***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

***REMOVED***/ A view displaying a list of attachments in a "carousel", with a thumbnail and title.
struct AttachmentPreview: View {
***REMOVED******REMOVED***/ The attachment models displayed in the list.
***REMOVED***var attachmentModels: [AttachmentModel]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ScrollView(.horizontal) {
***REMOVED******REMOVED******REMOVED***HStack(alignment: .top, spacing: 8) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(attachmentModels) { attachmentModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentCell(attachmentModel: attachmentModel)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view representing a single cell in an `AttachmentPreview`.
***REMOVED***struct AttachmentCell: View  {
***REMOVED******REMOVED******REMOVED***/ The model representing the attachment to display.
***REMOVED******REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The url of the the attachment, used to display the attachment via `QuickLook`.
***REMOVED******REMOVED***@State var url: URL?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.loadStatus != .loading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ThumbnailView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel: attachmentModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***size: attachmentModel.usingDefaultImage ?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CGSize(width: 36, height: 36) :
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CGSize(width: 120, height: 120)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(Color.white.opacity(0.75))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.usingDefaultImage {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachmentModel.attachment.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.truncationMode(.middle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.leading, .trailing], 4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("\(attachmentModel.attachment.size.formatted(.byteCount(style: .file)))")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.leading, .trailing], 4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED***.frame(width: 120, height: 120)
***REMOVED******REMOVED******REMOVED***.background(Color.gray.opacity(0.2))
***REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.attachment.loadStatus == .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Set the url to trigger `.quickLookPreview`.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url = attachmentModel.attachment.fileURL
***REMOVED******REMOVED******REMOVED*** else if attachmentModel.attachment.loadStatus == .notLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Load the attachment model with the given size.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel.load(thumbnailSize: CGSize(width: 120, height: 120))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.quickLookPreview($url)
***REMOVED***
***REMOVED***
***REMOVED***
