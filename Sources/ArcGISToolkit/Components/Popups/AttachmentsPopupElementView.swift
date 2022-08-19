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

***REMOVED*** TODO: taking info from Ryan and come up with API for fetching attachment file urls
***REMOVED*** TODO: update Visual Code tooling from README and generate stuff for all but attachments(?)
***REMOVED*** TODO: look at notes and follow up
***REMOVED*** TODO: look at prototype implementations and update if necessary
***REMOVED*** TODO: Goal is to have all done on Monday (or at least all but attachments).

class AttachmentImage: ObservableObject, Identifiable {
***REMOVED***@Published var attachment: PopupAttachment
***REMOVED***@Published var image: UIImage?
***REMOVED***@Published var isLoaded = false
***REMOVED***var id = UUID()
***REMOVED***
***REMOVED***init(attachment: PopupAttachment, image: UIImage? = nil) {
***REMOVED******REMOVED***self.attachment = attachment
***REMOVED******REMOVED***self.image = image
***REMOVED***
***REMOVED***

@MainActor
class AttachmentModel: ObservableObject {
***REMOVED***@Published var attachmentImages = [AttachmentImage]()
***REMOVED***

struct AttachmentsPopupElementView: View {
***REMOVED***var popupElement: AttachmentsPopupElement
***REMOVED***@StateObject private var viewModel: AttachmentModel
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
***REMOVED******REMOVED******REMOVED***wrappedValue: AttachmentModel()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***PopupElementHeader(
***REMOVED******REMOVED******REMOVED******REMOVED***title: popupElement.title,
***REMOVED******REMOVED******REMOVED******REMOVED***description: popupElement.description
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if loadingAttachments {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED*** else if popupElement.attachments.count == 0 {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("No attachments.")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED***switch popupElement.displayType {
***REMOVED******REMOVED******REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentImages: viewModel.attachmentImages)
***REMOVED******REMOVED******REMOVED******REMOVED***case.preview:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentImages: viewModel.attachmentImages)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(attachmentImages: viewModel.attachmentImages)
***REMOVED******REMOVED******REMOVED******REMOVED***case .auto:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentImages: viewModel.attachmentImages)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(attachmentImages: viewModel.attachmentImages)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentImages: viewModel.attachmentImages)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***try? await popupElement.fetchAttachments()
***REMOVED******REMOVED******REMOVED***let attachmentImages = popupElement.attachments.map { attachment in
***REMOVED******REMOVED******REMOVED******REMOVED***AttachmentImage(attachment: attachment)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***viewModel.attachmentImages.append(contentsOf: attachmentImages)
***REMOVED******REMOVED******REMOVED******REMOVED***await withTaskGroup(of: AttachmentImage.self) { group in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for attachment in popupElement.attachments {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachment.kind == .image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let image = try await attachment.makeFullImage()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return (attachment, image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return (attachment, UIImage(systemName: "photo")!)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return(attachment, UIImage(systemName: "doc")!)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await pair in group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentImages.append(pair)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***loadingAttachments = false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct AttachmentList: View {
***REMOVED******REMOVED***var attachmentImages: [AttachmentImage]
***REMOVED******REMOVED***@State var url: URL?
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 6) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(attachmentImages) { attachmentImage in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeAttachmentView(for: attachmentImage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***QuickLook
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func makeImage(for attachmentImage: AttachmentImage) -> Image  {
***REMOVED******REMOVED******REMOVED***switch attachmentImage.attachment.kind {
***REMOVED******REMOVED******REMOVED***case .image:
***REMOVED******REMOVED******REMOVED******REMOVED***if let image = attachmentImage.image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return Image(uiImage: image)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return Image(systemName: "photo")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .video:
***REMOVED******REMOVED******REMOVED******REMOVED***return Image(systemName: "video")
***REMOVED******REMOVED******REMOVED***case .document, .other:
***REMOVED******REMOVED******REMOVED******REMOVED***return Image(systemName: "doc")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***@ViewBuilder func makeAttachmentView(for attachmentImage: AttachmentImage) -> some View  {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeImage(for: attachmentImage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 60, height: 40, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachmentImage.attachment.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.truncationMode(.middle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("\(attachmentImage.attachment.size.formatted(.byteCount(style: .file)))")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentImage.attachment.loadStatus == .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url = attachmentImage.attachment.fileURL
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.quickLookPreview($url)
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await attachmentImage.attachment.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let image = try await attachmentImage.attachment.makeThumbnail(width: 60, height: 60)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentImage.image = image
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "square.and.arrow.down")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.leading)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(showDownloadButton(attachmentImage) ? 1 : 0)
***REMOVED******REMOVED***
***REMOVED***

***REMOVED******REMOVED***func showDownloadButton(_ attachmentImage: AttachmentImage) -> Bool {
***REMOVED******REMOVED******REMOVED***print("loadStatus = \(attachmentImage.attachment.loadStatus)")
***REMOVED******REMOVED******REMOVED***if attachmentImage.attachment.kind == .image {
***REMOVED******REMOVED******REMOVED******REMOVED***return attachmentImage.image == nil
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return attachmentImage.attachment.loadStatus != .loaded
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct AttachmentPreview: View {
***REMOVED******REMOVED***var attachmentImages: [AttachmentImage]
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(0..<attachments.count) { i in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(attachments) { attachment in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if i < images.count {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: images[i])
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 75, height: 75, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachments[i].name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension Attachment: Identifiable {***REMOVED***
