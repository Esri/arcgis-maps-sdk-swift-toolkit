***REMOVED*** Copyright 2024 Esri
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
import OSLog
***REMOVED***
import UniformTypeIdentifiers

***REMOVED***/ The context menu shown when the new attachment button is pressed.
struct AttachmentImportMenu: View {
***REMOVED***
***REMOVED******REMOVED***/ The attachment form element displaying the menu.
***REMOVED***private let element: AttachmentsFormElement
***REMOVED***
***REMOVED******REMOVED***/ Creates an `AttachmentImportMenu`***REMOVED******REMOVED******REMOVED***/ Creates an `AttachmentImportMenu`
***REMOVED******REMOVED***/ - Parameter element: The attachment form element displaying the menu.
***REMOVED******REMOVED***/ - Parameter onAdd: The action to perform when an attachment is added.
***REMOVED***init(element: AttachmentsFormElement, onAdd: ((FeatureAttachment) async throws -> Void)? = nil) {
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.onAdd = onAdd
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment camera controller is presented.
***REMOVED***@State private var cameraIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment file importer is presented.
***REMOVED***@State private var fileImporterIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ The current import state.
***REMOVED***@State private var importState: AttachmentImportState = .none
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment photo picker is presented.
***REMOVED***@State private var photoPickerIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when an attachment is added.
***REMOVED***let onAdd: ((FeatureAttachment) async throws -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the error alert is presented.
***REMOVED***var errorIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***importState.isErrored
***REMOVED*** set: { newIsPresented in
***REMOVED******REMOVED******REMOVED***if !newIsPresented {
***REMOVED******REMOVED******REMOVED******REMOVED***importState = .none
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func takePhotoOrVideoButton() -> Button<some View> {
***REMOVED***   Button {
***REMOVED******REMOVED******REMOVED***cameraIsShowing = true
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Take Photo or Video",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to capture a new photo or video."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "camera")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func chooseFromLibraryButton() -> Button<some View> {
***REMOVED***   Button {
***REMOVED******REMOVED******REMOVED***photoPickerIsPresented = true
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Choose From Library",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose a photo or video from the user's photo library."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "photo")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func chooseFromFilesButton() -> Button<some View> {
***REMOVED***   Button {
***REMOVED******REMOVED******REMOVED***fileImporterIsShowing = true
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Choose From Files",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose an file from the user's files."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "folder")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if importState.importInProgress {
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.circular)
***REMOVED***
***REMOVED******REMOVED***Menu {
***REMOVED******REMOVED******REMOVED***if element.input is AnyAttachmentsFormInput {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Show photo/video and library picker if
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** we're allowing all input types.
***REMOVED******REMOVED******REMOVED******REMOVED***takePhotoOrVideoButton()
***REMOVED******REMOVED******REMOVED******REMOVED***chooseFromLibraryButton()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Always show file picker, no matter the input type.
***REMOVED******REMOVED******REMOVED***chooseFromFilesButton()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "plus")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(5)
***REMOVED***
***REMOVED******REMOVED***.disabled(importState.importInProgress)
***REMOVED******REMOVED***.alert(importFailureAlertTitle, isPresented: errorIsPresented) { ***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED***Text(importFailureAlertMessage)
***REMOVED***
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED***.menuStyle(.borderlessButton)
#endif
***REMOVED******REMOVED***.task(id: importState) {
***REMOVED******REMOVED******REMOVED***guard case let .finalizing(newAttachmentImportData) = importState else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***defer { importState = .none ***REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let fileName: String
***REMOVED******REMOVED******REMOVED******REMOVED***if let presetFileName = newAttachmentImportData.fileName {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileName = presetFileName
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let attachmentNumber = element.attachments.count + 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let fileExtension = newAttachmentImportData.fileExtension {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileName = "Attachment \(attachmentNumber).\(fileExtension)"
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileName = "Attachment \(attachmentNumber)"
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***_ = try await element.addAttachment(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Can this be better? What does legacy do?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: fileName,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***contentType: newAttachmentImportData.contentType,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: newAttachmentImportData.data
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.system(error.localizedDescription))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [.item]) { result in
***REMOVED******REMOVED******REMOVED***importState = .importing
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case .success(let url):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** gain access to the url resource and verify there's data.
***REMOVED******REMOVED******REMOVED******REMOVED***if url.startAccessingSecurityScopedResource(),
***REMOVED******REMOVED******REMOVED******REMOVED***   let data = FileManager.default.contents(atPath: url.path) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***importState = .finalizing(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentImportData(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: data,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***contentType: url.mimeType(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileName: url.lastPathComponent
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.dataInaccessible)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** release access
***REMOVED******REMOVED******REMOVED******REMOVED***url.stopAccessingSecurityScopedResource()
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.system(error.localizedDescription))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.fullScreenCover(isPresented: $cameraIsShowing) {
***REMOVED******REMOVED******REMOVED***AttachmentCameraController(
***REMOVED******REMOVED******REMOVED******REMOVED***importState: $importState
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***.modifier(
***REMOVED******REMOVED******REMOVED***AttachmentPhotoPicker(
***REMOVED******REMOVED******REMOVED******REMOVED***importState: $importState,
***REMOVED******REMOVED******REMOVED******REMOVED***photoPickerIsPresented: $photoPickerIsPresented
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension URL {
***REMOVED******REMOVED***/ The Mime type based on the path extension.
***REMOVED******REMOVED***/ - Returns: The Mime type string.
***REMOVED***public func mimeType() -> String {
***REMOVED******REMOVED***if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
***REMOVED******REMOVED******REMOVED***return mimeType
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***return "application/octet-stream"
***REMOVED***
***REMOVED***
***REMOVED***

private extension AttachmentImportMenu {
***REMOVED******REMOVED***/ A title for an alert that the selected file was not able to be imported as an attachment.
***REMOVED***var importFailureAlertTitle: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Error importing attachment",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED***A title for an alert that the selected file was not able to be
***REMOVED******REMOVED******REMOVED***imported as an attachment.
***REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A message for an alert that the selected file was not able to be imported as an attachment.
***REMOVED***var importFailureAlertMessage: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "The selected attachment could not be imported.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED***A message for an alert that the selected file was not able to be
***REMOVED******REMOVED******REMOVED***imported as an attachment.
***REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
