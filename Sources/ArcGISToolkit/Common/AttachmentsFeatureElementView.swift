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
import QuickLook
***REMOVED***

***REMOVED***/ A view displaying an `AttachmentsFeatureElement`.
struct AttachmentsFeatureElementView: View {
***REMOVED******REMOVED***/ The `AttachmentsFeatureElement` to display.
***REMOVED***let featureElement: AttachmentsFeatureElement
***REMOVED***
***REMOVED***@Environment(\.isPortraitOrientation) var isPortraitOrientation
***REMOVED***
***REMOVED***@Environment(\.displayScale) var displayScale
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the input is editable.
***REMOVED***@State private var isEditable = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the feature Element
***REMOVED******REMOVED***/ is an `AttachmentFormElement`.
***REMOVED***private var isShowingAttachmentFormElement = false

***REMOVED******REMOVED***/ A Boolean value denoting if the view should be shown as regular width.
***REMOVED***var isRegularWidth: Bool {
***REMOVED******REMOVED***!isPortraitOrientation
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The states of loading attachments.
***REMOVED***private enum AttachmentLoadingState {
***REMOVED******REMOVED******REMOVED***/ Attachments have not been loaded.
***REMOVED******REMOVED***case notLoaded
***REMOVED******REMOVED******REMOVED***/ Attachments are being loaded.
***REMOVED******REMOVED***case loading
***REMOVED******REMOVED******REMOVED***/ Attachments have been loaded.
***REMOVED******REMOVED***case loaded([AttachmentModel])
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current load state of the attachments.
***REMOVED***@State private var attachmentLoadingState: AttachmentLoadingState = .notLoaded
***REMOVED***
***REMOVED******REMOVED***/ Creates a new `AttachmentsFeatureElementView`.
***REMOVED******REMOVED***/ - Parameter featureElement: The `AttachmentsFeatureElement`.
***REMOVED***init(featureElement: AttachmentsFeatureElement) {
***REMOVED******REMOVED***self.featureElement = featureElement
***REMOVED******REMOVED***isShowingAttachmentFormElement = featureElement is AttachmentFormElement
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value denoting whether the Disclosure Group is expanded.
***REMOVED***@State private var isExpanded = true
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch attachmentLoadingState {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .loading:
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***case .loaded(let attachmentModels):
***REMOVED******REMOVED******REMOVED******REMOVED***if isShowingAttachmentFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If showing a form element, don't show attachments in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** a disclosure group, but also ALWAYS show
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** the list of attachments, even if there are none.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentHeader
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentBody(attachmentModels: attachmentModels)
***REMOVED******REMOVED******REMOVED*** else if !attachmentModels.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(isExpanded: $isExpanded) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentBody(attachmentModels: attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentHeader
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAttachmentIsEditableChange(of: featureElement) { newIsEditable in
***REMOVED******REMOVED******REMOVED***isEditable = newIsEditable
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***guard case .notLoaded = attachmentLoadingState else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***attachmentLoadingState = .loading
***REMOVED******REMOVED******REMOVED***let attachments = (try? await featureElement.featureAttachments) ?? []
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var attachmentModels = attachments
***REMOVED******REMOVED******REMOVED******REMOVED***.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachment: $0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***displayScale: displayScale,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailSize: thumbnailSize
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if isShowingAttachmentFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Reverse attachment models array if we're not editing.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** This allows attachments in a non-editing context to
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** display in the same order as the online Map Viewer.
***REMOVED******REMOVED******REMOVED******REMOVED***attachmentModels = attachmentModels.reversed()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***attachmentLoadingState = .loaded(attachmentModels)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder private func attachmentBody(attachmentModels: [AttachmentModel]) -> some View {
***REMOVED******REMOVED***switch featureElement.attachmentDisplayType {
***REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: attachmentModels)
***REMOVED******REMOVED***case .preview:
***REMOVED******REMOVED******REMOVED***AttachmentPreview(
***REMOVED******REMOVED******REMOVED******REMOVED***attachmentModels: attachmentModels,
***REMOVED******REMOVED******REMOVED******REMOVED***editControlsDisabled: !isEditable,
***REMOVED******REMOVED******REMOVED******REMOVED***onRename: onRename,
***REMOVED******REMOVED******REMOVED******REMOVED***onDelete: onDelete
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .auto:
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModels: attachmentModels,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***editControlsDisabled: !isEditable,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onRename: onRename,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onDelete: onDelete
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: attachmentModels)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private var attachmentHeader: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***PopupElementHeader(
***REMOVED******REMOVED******REMOVED******REMOVED***title: featureElement.displayTitle,
***REMOVED******REMOVED******REMOVED******REMOVED***description: featureElement.description
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if isEditable,
***REMOVED******REMOVED******REMOVED***   let element = featureElement as? AttachmentFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED***AttachmentImportMenu(element: element, onAdd: onAdd)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a model for the new attachment for display.
***REMOVED******REMOVED***/ - Parameter attachment: The added attachment.
***REMOVED***@MainActor
***REMOVED***func onAdd(attachment: FeatureAttachment) -> Void {
***REMOVED******REMOVED***guard case .loaded(var models) = attachmentLoadingState else { return ***REMOVED***
***REMOVED******REMOVED***let newModel = AttachmentModel(
***REMOVED******REMOVED******REMOVED***attachment: attachment,
***REMOVED******REMOVED******REMOVED***displayScale: displayScale,
***REMOVED******REMOVED******REMOVED***thumbnailSize: thumbnailSize
***REMOVED******REMOVED***)
***REMOVED******REMOVED***newModel.load()
***REMOVED******REMOVED***models.insert(newModel, at: 0)
***REMOVED******REMOVED***attachmentLoadingState = .loaded(models)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Renames the given attachment.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - attachment: The attachment to rename.
***REMOVED******REMOVED***/   - newAttachmentName: The new attachment name.
***REMOVED***func onRename(attachment: FeatureAttachment, newAttachmentName: String) async throws -> Void {
***REMOVED******REMOVED***if let element = featureElement as? AttachmentFormElement,
***REMOVED******REMOVED***   let attachment = attachment as? FormAttachment {
***REMOVED******REMOVED******REMOVED***try await element.renameAttachment(attachment, name: newAttachmentName)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes the attachment associated with the given model.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - attachmentModel: The model for the attachment to delete.
***REMOVED***@MainActor
***REMOVED***func onDelete(attachmentModel: AttachmentModel) async throws -> Void {
***REMOVED******REMOVED***if let element = featureElement as? AttachmentFormElement,
***REMOVED******REMOVED***   let attachment = attachmentModel.attachment as? FormAttachment {
***REMOVED******REMOVED******REMOVED***try await element.deleteAttachment(attachment)
***REMOVED******REMOVED******REMOVED***guard case .loaded(var models) = attachmentLoadingState else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***models.removeAll { $0 == attachmentModel ***REMOVED***
***REMOVED******REMOVED******REMOVED***attachmentLoadingState = .loaded(models)
***REMOVED***
***REMOVED***
***REMOVED***

private extension AttachmentsFeatureElement {
***REMOVED******REMOVED***/ Provides a default title to display if `title` is empty.
***REMOVED***var displayTitle: String {
***REMOVED******REMOVED***title.isEmpty ? String(
***REMOVED******REMOVED******REMOVED***localized: "Attachments",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to attachments."
***REMOVED******REMOVED***) : title
***REMOVED***
***REMOVED***

extension AttachmentsFeatureElementView {
***REMOVED******REMOVED***/ The size of thumbnail images, based on the attachment display type
***REMOVED******REMOVED***/ and the current size class of the view.
***REMOVED***var thumbnailSize: CGSize {
***REMOVED******REMOVED******REMOVED*** Set thumbnail size
***REMOVED******REMOVED***let thumbnailSize: CGSize
***REMOVED******REMOVED***switch featureElement.attachmentDisplayType {
***REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED***thumbnailSize = CGSize(width: 40, height: 40)
***REMOVED******REMOVED***case .preview:
***REMOVED******REMOVED******REMOVED***thumbnailSize = CGSize(width: 120, height: 120)
***REMOVED******REMOVED***case .auto:
***REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED***thumbnailSize = CGSize(width: 120, height: 120)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***thumbnailSize = CGSize(width: 40, height: 40)
***REMOVED******REMOVED***
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***thumbnailSize = CGSize(width: 120, height: 120)
***REMOVED***
***REMOVED******REMOVED***return thumbnailSize
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Applies the given transform if the given condition evaluates to `true`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - condition: The condition to evaluate.
***REMOVED******REMOVED***/   - transform: The transform to apply to the source `View`.
***REMOVED******REMOVED***/ - Returns: Either the original `View` or the modified `View` if the condition is `true`.
***REMOVED***@ViewBuilder func onAttachmentIsEditableChange(
***REMOVED******REMOVED***of element: AttachmentsFeatureElement,
***REMOVED******REMOVED***action: @escaping (_ newIsEditable: Bool) -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***if let attachmentFormElement = element as? AttachmentFormElement {
***REMOVED******REMOVED******REMOVED***self
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: ObjectIdentifier(attachmentFormElement)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await isEditable in attachmentFormElement.$isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(isEditable)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
