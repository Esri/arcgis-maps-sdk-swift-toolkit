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
***REMOVED******REMOVED***/ The name for the existing attachment being edited.
***REMOVED***@State private var currentAttachmentName = ""
***REMOVED***
***REMOVED******REMOVED***/ The model for an attachment the user has requested be deleted.
***REMOVED***@State private var deletedAttachmentModel: AttachmentModel?
***REMOVED***
***REMOVED******REMOVED***/ The new name the user has provided for the attachment.
***REMOVED***@State private var newAttachmentName = ""
***REMOVED***
***REMOVED******REMOVED***/ The model for an attachment the user has requested be renamed.
***REMOVED***@State private var renamedAttachmentModel: AttachmentModel?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating the user has requested that the attachment be renamed.
***REMOVED***@State private var renameDialogueIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ An action which scrolls the Carousel to the front.
***REMOVED***@Binding var scrollToNewAttachmentAction: (() -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The models for the attachments displayed in the list.
***REMOVED***let attachmentModels: [AttachmentModel]
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value which determines if the attachment editing controls should be disabled.
***REMOVED***let editControlsDisabled: Bool
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when the attachment is deleted.
***REMOVED***let onDelete: ((AttachmentModel) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when the attachment is renamed.
***REMOVED***let onRename: ((AttachmentModel, String) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The proposed size of each attachment preview cell.
***REMOVED***let proposedCellSize: CGSize
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***attachmentModels: [AttachmentModel],
***REMOVED******REMOVED***editControlsDisabled: Bool = true,
***REMOVED******REMOVED***proposedCellSize: CGSize,
***REMOVED******REMOVED***onRename: ((AttachmentModel, String) -> Void)? = nil,
***REMOVED******REMOVED***onDelete: ((AttachmentModel) -> Void)? = nil,
***REMOVED******REMOVED***scrollToNewAttachmentAction: Binding<(() -> Void)?>
***REMOVED***) {
***REMOVED******REMOVED***self.attachmentModels = attachmentModels
***REMOVED******REMOVED***self.proposedCellSize = proposedCellSize
***REMOVED******REMOVED***self.editControlsDisabled = editControlsDisabled
***REMOVED******REMOVED***self.onRename = onRename
***REMOVED******REMOVED***self.onDelete = onDelete
***REMOVED******REMOVED***_scrollToNewAttachmentAction = scrollToNewAttachmentAction
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Carousel { computedCellSize, scrollToLeftAction in
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***makeCarouselContent(for: computedCellSize)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***scrollToNewAttachmentAction = scrollToLeftAction
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.cellBaseWidth(proposedCellSize.width)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func makeCarouselContent(for size: CGSize) -> some View {
***REMOVED******REMOVED***ForEach(attachmentModels) { attachmentModel in
***REMOVED******REMOVED******REMOVED***AttachmentCell(attachmentModel: attachmentModel, cellSize: size)
***REMOVED******REMOVED******REMOVED******REMOVED***.contextMenu {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !editControlsDisabled {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***renamedAttachmentModel = attachmentModel
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***renameDialogueIsShowing = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let separatorIndex = attachmentModel.name.lastIndex(of: ".") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***newAttachmentName = String(attachmentModel.name[..<separatorIndex])
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***newAttachmentName = attachmentModel.name
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Rename",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to rename an attachment."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "pencil")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***deletedAttachmentModel = attachmentModel
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label("Delete", systemImage: "trash")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Rename attachment",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label in reference to the action of renaming a file, shown in a file rename interface."
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***isPresented: $renameDialogueIsShowing
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***TextField(text: $newAttachmentName) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"New name",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label in reference to the new name of a file, shown in a file rename interface."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.autocorrectionDisabled()
***REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) { ***REMOVED***
***REMOVED******REMOVED******REMOVED***Button("OK") {
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let renamedAttachmentModel {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let currentName = renamedAttachmentModel.name
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let separatorIndex = currentName.lastIndex(of: ".") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let fileExtension = String(currentName[currentName.index(after: separatorIndex)...])
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onRename?(renamedAttachmentModel, [newAttachmentName, fileExtension].joined(separator: "."))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onRename?(renamedAttachmentModel, newAttachmentName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task(id: deletedAttachmentModel) {
***REMOVED******REMOVED******REMOVED***guard let deletedAttachmentModel else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***onDelete?(deletedAttachmentModel)
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
***REMOVED******REMOVED******REMOVED***/ The size of the cell.
***REMOVED******REMOVED***let cellSize: CGSize
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.loadStatus != .loading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ThumbnailView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel: attachmentModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***size: attachmentModel.usingSystemImage ? CGSize(width: 36, height: 36) : cellSize
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(attachmentModel.attachment.measuredSize, format: .byteCount(style: .file))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "square.and.arrow.down")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED***.frame(width: cellSize.width, height: cellSize.height)
***REMOVED******REMOVED******REMOVED***.background(Color.gray.opacity(0.2))
***REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED***if attachmentModel.attachment.loadStatus == .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Set the url to trigger `.quickLookPreview`.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url = attachmentModel.attachment.fileURL
***REMOVED******REMOVED******REMOVED*** else if attachmentModel.attachment.loadStatus == .notLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Load the attachment model with the given size.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModel.load()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.quickLookPreview($url)
***REMOVED***
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
