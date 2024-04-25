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
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value denoting whether the Disclosure Group is expanded.
***REMOVED***@State private var isExpanded = true
***REMOVED***
***REMOVED******REMOVED***/ A Boolean which determines whether attachment editing controls are enabled.
***REMOVED******REMOVED***/ Note that editing controls are only applicable when the display type is Preview.
***REMOVED***private var editControlsDisabled: Bool = true
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch attachmentLoadingState {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .loading:
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***case .loaded(let attachmentModels):
***REMOVED******REMOVED******REMOVED******REMOVED***if !editControlsDisabled {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If editing is enabled, don't show attachments in
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
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***guard case .notLoaded = attachmentLoadingState else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***attachmentLoadingState = .loading
***REMOVED******REMOVED******REMOVED***let attachments = (try? await featureElement.featureAttachments) ?? []
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var attachmentModels = attachments
***REMOVED******REMOVED******REMOVED******REMOVED***.map { AttachmentModel(attachment: $0, displayScale: displayScale) ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if editControlsDisabled {
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
***REMOVED******REMOVED******REMOVED******REMOVED***editControlsDisabled: editControlsDisabled,
***REMOVED******REMOVED******REMOVED******REMOVED***onRename: onRename,
***REMOVED******REMOVED******REMOVED******REMOVED***onDelete: onDelete
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .auto:
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModels: attachmentModels,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***editControlsDisabled: editControlsDisabled,
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
***REMOVED******REMOVED******REMOVED***if !editControlsDisabled,
***REMOVED******REMOVED******REMOVED***   let element = featureElement as? AttachmentFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED***AttachmentImportMenu(element: element)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Renames the given attachment.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - attachment: The attachment to rename.
***REMOVED******REMOVED***/   - newAttachmentName: The new attachment name.
***REMOVED******REMOVED***/ - Returns: Nothing.
***REMOVED***func onRename(attachment: FeatureAttachment, newAttachmentName: String) async throws -> Void {
***REMOVED******REMOVED***if let element = featureElement as? AttachmentFormElement,
***REMOVED******REMOVED***   let attachment = attachment as? FormAttachment {
***REMOVED******REMOVED******REMOVED***try await element.renameAttachment(attachment, name: newAttachmentName)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes the given attachment.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - attachment: The attachment to delete.
***REMOVED******REMOVED***/ - Returns: Nothing.
***REMOVED***func onDelete(attachment: FeatureAttachment) async throws -> Void {
***REMOVED******REMOVED***if let element = featureElement as? AttachmentFormElement,
***REMOVED******REMOVED***   let attachment = attachment as? FormAttachment {
***REMOVED******REMOVED******REMOVED***try await element.deleteAttachment(attachment)
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
***REMOVED******REMOVED***/ Controls if the attachment editing controls should be enabled.
***REMOVED******REMOVED***/ - Parameter newShouldShowEditControls: The new value.
***REMOVED******REMOVED***/ - Returns: The `AttachmentsFeatureElementView`.
***REMOVED***public func editControlsDisabled(_ newEditControlsDisabled: Bool) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.editControlsDisabled = newEditControlsDisabled
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
