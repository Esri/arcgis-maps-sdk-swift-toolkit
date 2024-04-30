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

***REMOVED***/ A view displaying a list of attachments in a "carousel", with a thumbnail and title.
struct AttachmentPreview: View {
***REMOVED******REMOVED***/ The models for the attachments displayed in the list.
***REMOVED***var attachmentModels: [AttachmentModel]
***REMOVED***
***REMOVED******REMOVED***/ The name for the existing attachment being edited.
***REMOVED***@State private var currentAttachmentName = ""
***REMOVED***
***REMOVED******REMOVED***/ The model for an attachment the user has requested be deleted.
***REMOVED***@State private var deletedAttachmentModel: AttachmentModel?
***REMOVED***
***REMOVED******REMOVED***/ The model for an attachment with the user has requested be renamed.
***REMOVED***@State private var renamedAttachmentModel: AttachmentModel?
***REMOVED***
***REMOVED******REMOVED***/ The new name the user has provided for the attachment.
***REMOVED***@State private var newAttachmentName = ""
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when the attachment is deleted.
***REMOVED***let onDelete: ((AttachmentModel) async throws -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when the attachment is renamed.
***REMOVED***let onRename: ((AttachmentModel, String) async throws -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating the user has requested that the attachment be renamed.
***REMOVED***@State private var renameDialogueIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value which determines if the attachment editing controls should be disabled.
***REMOVED***let editControlsDisabled: Bool
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***attachmentModels: [AttachmentModel],
***REMOVED******REMOVED***editControlsDisabled: Bool = true,
***REMOVED******REMOVED***onRename: ((AttachmentModel, String) async throws -> Void)? = nil,
***REMOVED******REMOVED***onDelete: ((AttachmentModel) async throws -> Void)? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.attachmentModels = attachmentModels
***REMOVED******REMOVED***self.onRename = onRename
***REMOVED******REMOVED***self.onDelete = onDelete
***REMOVED******REMOVED***self.editControlsDisabled = editControlsDisabled
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ScrollView(.horizontal) {
***REMOVED******REMOVED******REMOVED***HStack(alignment: .top, spacing: 8) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(attachmentModels) { attachmentModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentCell(attachmentModel: attachmentModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contextMenu {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !editControlsDisabled {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***renamedAttachmentModel = attachmentModel
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***newAttachmentName = attachmentModel.attachment.name
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***renameDialogueIsShowing = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label("Rename", systemImage: "pencil")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***deletedAttachmentModel = attachmentModel
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label("Delete", systemImage: "trash")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.alert("Rename attachment", isPresented: $renameDialogueIsShowing) {
***REMOVED******REMOVED******REMOVED***TextField("New name", text: $newAttachmentName)
***REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) { ***REMOVED***
***REMOVED******REMOVED******REMOVED***Button("Ok") {
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let renamedAttachmentModel {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await onRename?(renamedAttachmentModel, newAttachmentName)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task(id: deletedAttachmentModel) {
***REMOVED******REMOVED******REMOVED***guard let deletedAttachmentModel else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***try? await onDelete?(deletedAttachmentModel)
***REMOVED******REMOVED******REMOVED***self.deletedAttachmentModel = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view representing a single cell in an `AttachmentPreview`.
***REMOVED***struct AttachmentCell: View  {
***REMOVED******REMOVED******REMOVED***/ The model representing the attachment to display.
***REMOVED******REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The url of the the attachment, used to display the attachment via `QuickLook`.
***REMOVED******REMOVED***@State private var url: URL?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.loadStatus != .loading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ThumbnailView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel: attachmentModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***size: attachmentModel.usingSystemImage ?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CGSize(width: 36, height: 36) :
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel.thumbnailSize
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.loadStatus == .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ThumbnailViewFooter(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel: attachmentModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***size: attachmentModel.thumbnailSize
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(Material.thin, in: RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.attachment.loadStatus != .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachmentModel.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.truncationMode(.middle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.leading, .trailing], 4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(Int64(attachmentModel.attachment.size), format: .byteCount(style: .file))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "square.and.arrow.down")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED***.frame(width: 120, height: 120)
***REMOVED******REMOVED******REMOVED***.background(Color.gray.opacity(0.2))
***REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.attachment.loadStatus == .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Set the url to trigger `.quickLookPreview`.

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** WORKAROUND - attachment.fileURL is just a GUID for FormAttachments
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Note: this can be deleted when Apollo #635 - "FormAttachment.fileURL is not user-friendly" is fixed.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***var tmpURL =  attachmentModel.attachment.fileURL
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let formAttachment = attachmentModel.attachment as? FormAttachment {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tmpURL = tmpURL?.deletingLastPathComponent()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tmpURL = tmpURL?.appending(path: formAttachment.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***_ = FileManager.default.secureCopyItem(at: attachmentModel.attachment.fileURL!, to: tmpURL!)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url = tmpURL
***REMOVED******REMOVED******REMOVED*** else if attachmentModel.attachment.loadStatus == .notLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Load the attachment model with the given size.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel.load()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.quickLookPreview($url)
***REMOVED***
***REMOVED***
***REMOVED***

extension FileManager {
***REMOVED******REMOVED***/ - Note: This can be deleted when Apollo #635 - "FormAttachment.fileURL is not user-friendly" is fixed.
***REMOVED***func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***if FileManager.default.fileExists(atPath: dstURL.path) {
***REMOVED******REMOVED******REMOVED******REMOVED***try FileManager.default.removeItem(at: dstURL)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***try FileManager.default.copyItem(at: srcURL, to: dstURL)
***REMOVED*** catch (let error) {
***REMOVED******REMOVED******REMOVED***print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***return true
***REMOVED***
***REMOVED***

***REMOVED***/ A view displaying details for popup media.
struct ThumbnailViewFooter: View {
***REMOVED******REMOVED***/ The popup media to display.
***REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED***
***REMOVED******REMOVED***/ The size of the media's frame.
***REMOVED***let size: CGSize
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***let gradient = Gradient(colors: [.black, .black.opacity(0.15)])
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: size.height * 0.25)
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if !attachmentModel.name.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachmentModel.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.white)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding([.leading, .trailing], 6)
***REMOVED***
***REMOVED***
***REMOVED***
