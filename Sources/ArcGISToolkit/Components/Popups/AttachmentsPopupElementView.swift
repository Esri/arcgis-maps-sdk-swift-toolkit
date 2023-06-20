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

***REMOVED***/ A view displaying an `AttachmentsPopupElement`.
struct AttachmentsPopupElementView: View {
***REMOVED******REMOVED***/ The `PopupElement` to display.
***REMOVED***var popupElement: AttachmentsPopupElement
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value denoting if the view should be shown as regular width.
***REMOVED***var isRegularWidth: Bool {
***REMOVED******REMOVED***!(horizontalSizeClass == .compact && verticalSizeClass == .regular)
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
***REMOVED***@State private var attachmentLoadingState: AttachmentLoadingState = .notLoaded
***REMOVED***
***REMOVED******REMOVED***/ Creates a new `AttachmentsPopupElementView`.
***REMOVED******REMOVED***/ - Parameter popupElement: The `AttachmentsPopupElement`.
***REMOVED***init(popupElement: AttachmentsPopupElement) {
***REMOVED******REMOVED***self.popupElement = popupElement
***REMOVED***
***REMOVED***
***REMOVED***@State private var isExpanded: Bool = true
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch attachmentLoadingState {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .loading:
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***case .loaded(let attachmentModels):
***REMOVED******REMOVED******REMOVED******REMOVED***if !attachmentModels.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(isExpanded: $isExpanded) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch popupElement.displayType {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .preview:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(attachmentModels: attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .auto:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(attachmentModels: attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PopupElementHeader(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: popupElement.displayTitle,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: popupElement.description
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***guard case .notLoaded = attachmentLoadingState else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***attachmentLoadingState = .loading
***REMOVED******REMOVED******REMOVED***let attachments = (try? await popupElement.attachments) ?? []
***REMOVED******REMOVED******REMOVED***let attachmentModels = attachments
***REMOVED******REMOVED******REMOVED******REMOVED***.reversed()
***REMOVED******REMOVED******REMOVED******REMOVED***.map { AttachmentModel(attachment: $0) ***REMOVED***
***REMOVED******REMOVED******REMOVED***attachmentLoadingState = .loaded(attachmentModels)
***REMOVED***
***REMOVED***
***REMOVED***

private extension AttachmentsPopupElement {
***REMOVED******REMOVED***/ Provides a default title to display if `title` is empty.
***REMOVED***var displayTitle: String {
***REMOVED******REMOVED***title.isEmpty ? String(localized: "Attachments", bundle: .toolkitModule) : title
***REMOVED***
***REMOVED***
