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
import QuickLook

***REMOVED*** TODO: look at notes and follow up

***REMOVED*** TODO: Add alert for when attachments fail to load...
***REMOVED*** TODO: Move classes into separate file; maybe structs too.

struct AttachmentsPopupElementView: View {
***REMOVED***var popupElement: AttachmentsPopupElement
***REMOVED***@StateObject private var viewModel: AttachmentsPopupElementModel
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value denoting if the view should be shown as regular width.
***REMOVED***var isRegularWidth: Bool {
***REMOVED******REMOVED***!(horizontalSizeClass == .compact && verticalSizeClass == .regular)
***REMOVED***
***REMOVED***
***REMOVED***@State var loadingAttachments = true
***REMOVED***
***REMOVED***init(popupElement: AttachmentsPopupElement) {
***REMOVED******REMOVED***self.popupElement = popupElement
***REMOVED******REMOVED***_viewModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: AttachmentsPopupElementModel()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** TODO: Move VStack into final else so that we won't show anything if there are no attachments?????
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***PopupElementHeader(
***REMOVED******REMOVED******REMOVED******REMOVED***title: popupElement.title,
***REMOVED******REMOVED******REMOVED******REMOVED***description: popupElement.description
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if loadingAttachments {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED*** else if popupElement.attachments.count == 0 {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("No attachments.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED***switch popupElement.displayType {
***REMOVED******REMOVED******REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: viewModel.attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(attachmentModels: viewModel.attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED***case.preview:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: viewModel.attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(attachmentModels: viewModel.attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED***case .auto:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: viewModel.attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(attachmentModels: viewModel.attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: viewModel.attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(attachmentModels: viewModel.attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***try? await popupElement.fetchAttachments()
***REMOVED******REMOVED******REMOVED***let attachmentModels = popupElement.attachments.map { attachment in
***REMOVED******REMOVED******REMOVED******REMOVED***AttachmentModel(attachment: attachment)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***viewModel.attachmentModels.append(contentsOf: attachmentModels)
***REMOVED******REMOVED******REMOVED***loadingAttachments = false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct AttachmentList: View {
***REMOVED******REMOVED***var attachmentModels: [AttachmentModel]
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 6) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(attachmentModels) { attachmentModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentRow(attachmentModel: attachmentModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel != attachmentModels.last {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***struct AttachmentRow: View  {
***REMOVED******REMOVED******REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED******REMOVED******REMOVED***@State var url: URL?
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ThumbnailView(attachmentModel: attachmentModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachmentModel.attachment.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.truncationMode(.middle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("\(attachmentModel.attachment.size.formatted(.byteCount(style: .file)))")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.attachment.loadStatus == .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url = attachmentModel.attachment.fileURL
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.loadStatus != .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentLoadButton(attachmentModel: attachmentModel)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.quickLookPreview($url)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct ThumbnailView: View  {
***REMOVED******REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED******REMOVED***var size: CGSize = CGSize(width: 40, height: 40)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***if let image = attachmentModel.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.renderingMode(attachmentModel.usingDefaultImage ? .template : .original)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: attachmentModel.usingDefaultImage ? .fit : .fill)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: size.width, height: size.height, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 4))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(foregroundColor(for: attachmentModel))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func foregroundColor(for attachmentModel: AttachmentModel) -> Color {
***REMOVED******REMOVED******REMOVED***attachmentModel.loadStatus == .failed ? .red :
***REMOVED******REMOVED******REMOVED***(attachmentModel.usingDefaultImage ? .accentColor : .primary)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct AttachmentLoadButton: View  {
***REMOVED******REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.loadStatus == .notLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel.load()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else if attachmentModel.loadStatus == .failed {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO:  Show error alert, similar to BasemapGallery.
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch attachmentModel.loadStatus {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .notLoaded:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "square.and.arrow.down")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .loading:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .loaded:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(Color.clear)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 24, height: 24)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.leading)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct AttachmentPreview: View {
***REMOVED******REMOVED***var attachmentModels: [AttachmentModel]
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***ScrollView(.horizontal) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .top, spacing: 8) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(attachmentModels) { attachmentModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentCell(attachmentModel: attachmentModel)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***struct AttachmentCell: View  {
***REMOVED******REMOVED******REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED******REMOVED******REMOVED***@State var url: URL?
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.loadStatus != .loading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ThumbnailView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel: attachmentModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***size: attachmentModel.usingDefaultImage ?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CGSize(width: 40, height: 40) :
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CGSize(width: 120, height: 120)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(Color.white.opacity(0.75))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.usingDefaultImage {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachmentModel.attachment.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.truncationMode(.middle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("\(attachmentModel.attachment.size.formatted(.byteCount(style: .file)))")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 120, height: 120)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(Color.gray.opacity(0.2))
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.attachment.loadStatus == .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url = attachmentModel.attachment.fileURL
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else if attachmentModel.attachment.loadStatus == .notLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel.load(thumbnailSize: CGSize(width: 120, height: 120))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.quickLookPreview($url)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
