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
import QuickLook

***REMOVED***/ A view displaying an `AttachmentsFeatureElementView`.
struct AttachmentsFeatureElementView: View {
***REMOVED******REMOVED***/ The `AttachmentsFeatureElement` to display.
***REMOVED***var featureElement: AttachmentsFeatureElement
***REMOVED***
***REMOVED***@Environment(\.isPortraitOrientation) var isPortraitOrientation
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
***REMOVED***@State private var attachmentLoadingState: AttachmentLoadingState = .notLoaded
***REMOVED***
***REMOVED******REMOVED***/ Creates a new `AttachmentsFeatureElementView`.
***REMOVED******REMOVED***/ - Parameter featureElement: The `AttachmentsFeatureElement`.
***REMOVED***init(featureElement: AttachmentsFeatureElement) {
***REMOVED******REMOVED***self.featureElement = featureElement
***REMOVED***
***REMOVED***
***REMOVED***@State private var isExpanded: Bool = true

***REMOVED******REMOVED***/ A boolean which determines whether attachment editing controls are enabled.
***REMOVED***private var shouldEnableEditControls: Bool = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch attachmentLoadingState {
***REMOVED******REMOVED******REMOVED***case .notLoaded, .loading:
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***case .loaded(let attachmentModels):
***REMOVED******REMOVED******REMOVED******REMOVED***if !attachmentModels.isEmpty || shouldEnableEditControls {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(isExpanded: $isExpanded) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch featureElement.displayType {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .preview:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModels: attachmentModels,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***shouldEnableEditControls: shouldEnableEditControls,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onRename: onRename,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onDelete: onDelete
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .auto:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentPreview(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attachmentModels: attachmentModels,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***shouldEnableEditControls: shouldEnableEditControls,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onRename: onRename,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onDelete: onDelete
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentList(attachmentModels: attachmentModels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PopupElementHeader(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: featureElement.displayTitle,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: featureElement.description
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if shouldEnableEditControls,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let element = featureElement.attachmentFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentImportMenu(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***guard case .notLoaded = attachmentLoadingState else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***attachmentLoadingState = .loading
***REMOVED******REMOVED******REMOVED***var attachments = (try? await featureElement.attachments) ?? []
***REMOVED******REMOVED******REMOVED***print("attachment count: \(attachments.count)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***try? await addDemoAttachments()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***attachments = (try? await featureElement.attachments) ?? []
***REMOVED******REMOVED******REMOVED******REMOVED***print("attachment count: \(attachments.count)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let attachmentModels = attachments
***REMOVED******REMOVED******REMOVED******REMOVED***.reversed()
***REMOVED******REMOVED******REMOVED******REMOVED***.map { AttachmentModel(attachment: $0) ***REMOVED***
***REMOVED******REMOVED******REMOVED***attachmentLoadingState = .loaded(attachmentModels)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func onRename(attachment: FeatureAttachment, newAttachmentName: String) async throws -> Void {
***REMOVED******REMOVED***if let element = featureElement.attachmentFormElement,
***REMOVED******REMOVED***   let attachment = attachment.formAttachment {
***REMOVED******REMOVED******REMOVED***try await element.renameAttachment(attachment, name: newAttachmentName)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func onDelete(attachment: FeatureAttachment) async throws -> Void {
***REMOVED******REMOVED***if let element = featureElement.attachmentFormElement,
***REMOVED******REMOVED***   let attachment = attachment.formAttachment {
***REMOVED******REMOVED******REMOVED***try await element.deleteAttachment(attachment)
***REMOVED***
***REMOVED***

***REMOVED***private func addDemoAttachments() async throws {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let data = UIImage(named: "forest.jpg")!.jpegData(compressionQuality: 1.0)!
***REMOVED******REMOVED******REMOVED******REMOVED***let data = UIImage(named: "forest.jpg")!.pngData()!
***REMOVED******REMOVED******REMOVED***print("data: \(data); size: \(data.count)")
***REMOVED******REMOVED******REMOVED******REMOVED***arcgisFeature.addAttachment(withName: "Attachment.png", contentType: "png", data: data) { [weak self] (attachment:AGSAttachment?, error:Error?) -> Void in
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***var url = URL(filePath: "/Users/mark1113_1/Development/PopupAttachmentTestFiles/forest.jpg")
***REMOVED******REMOVED******REMOVED******REMOVED***let image = UIImage(contentsOfFile: url.absoluteString)
***REMOVED******REMOVED******REMOVED******REMOVED***print("image = \(image)")
***REMOVED******REMOVED******REMOVED******REMOVED***var data = try? Data(contentsOf: url)
***REMOVED******REMOVED******REMOVED***let attachment = try await featureElement.attachmentFormElement?.addAttachment(
***REMOVED******REMOVED******REMOVED******REMOVED***name: "forest",
***REMOVED******REMOVED******REMOVED******REMOVED***contentType: "image/jpg",
***REMOVED******REMOVED******REMOVED******REMOVED***data: data
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***print("added one attachment")
***REMOVED******REMOVED******REMOVED******REMOVED***url = URL(filePath: "/Users/mark1113_1/Development/PopupAttachmentTestFiles/DeadLaptop.mov")
***REMOVED******REMOVED******REMOVED******REMOVED***data = try? Data(contentsOf: url)
***REMOVED******REMOVED******REMOVED******REMOVED***try await featureElement.attachmentFormElement?.addAttachment(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: "Dead Laptop",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***contentType: "quicktime",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: data
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***print("added two attachment")
***REMOVED******REMOVED******REMOVED******REMOVED***url = URL(filePath: "/Users/mark1113_1/Development/PopupAttachmentTestFiles/Barefoot Contessa | Emily's English Roasted Potatoes | Recipes.pdf")
***REMOVED******REMOVED******REMOVED******REMOVED***data = try? Data(contentsOf: url)
***REMOVED******REMOVED******REMOVED******REMOVED***try await featureElement.attachmentFormElement?.addAttachment(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: "Emily's English Roasted Potatoes",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***contentType: "pdf",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: data
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***print("added three attachment")
***REMOVED******REMOVED******REMOVED******REMOVED***url = URL(filePath: "/Users/mark1113_1/Development/PopupAttachmentTestFiles/sample3.mp3")
***REMOVED******REMOVED******REMOVED******REMOVED***data = try? Data(contentsOf: url)
***REMOVED******REMOVED******REMOVED******REMOVED***try await featureElement.attachmentFormElement?.addAttachment(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: "sample3",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***contentType: "mp3",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: data
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***print("added four attachment")
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***print("error adding attachment: \(error.localizedDescription)")
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
***REMOVED***public func shouldEnableEditControls(_ newShouldEnableEditControls: Bool) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.shouldEnableEditControls = newShouldEnableEditControls
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
