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
***REMOVED******REMOVED***/ Data used to create the attachment.
***REMOVED***private struct AttachmentData: Equatable {
***REMOVED******REMOVED***var data: Data
***REMOVED******REMOVED***var contentType: String
***REMOVED******REMOVED***var fileName: String = ""
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The attachment form element displaying the menu.
***REMOVED***private let element: AttachmentFormElement
***REMOVED***
***REMOVED******REMOVED***/ Creates an `AttachmentImportMenu`
***REMOVED******REMOVED***/ - Parameter element: The attachment form element displaying the menu.
***REMOVED******REMOVED***/ - Parameter onAdd: The action to perform when an attachment is added.
***REMOVED***init(element: AttachmentFormElement, onAdd: ((FeatureAttachment) async throws -> Void)? = nil) {
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
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment photo picker is presented.
***REMOVED***@State private var photoPickerIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The new image attachment data retrieved from the photos picker.
***REMOVED***@State private var newAttachmentData: AttachmentData?
***REMOVED***
***REMOVED******REMOVED***/ The new image attachment data retrieved from the photos picker.
***REMOVED***@State private var newImageData: Data?
***REMOVED***
***REMOVED******REMOVED***/ The new attachment retrieved from the device's camera.
***REMOVED***@State private var capturedImage: UIImage?
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when an attachment is added.
***REMOVED***let onAdd: ((FeatureAttachment) async throws -> Void)?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Menu {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***cameraIsShowing = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Take photo",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to capture a new photo."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "camera")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***photoPickerIsPresented = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Add photo from library",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose a photo from the user's photo library."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "photo")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***fileImporterIsShowing = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Add photo from files",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose a photo from the user's files."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "folder")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "plus")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(5)
***REMOVED***
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED***.menuStyle(.borderlessButton)
#endif
***REMOVED******REMOVED***.task(id: newAttachmentData) {
***REMOVED******REMOVED******REMOVED***guard let newAttachmentData else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***var fileName: String
***REMOVED******REMOVED******REMOVED******REMOVED***if !newAttachmentData.fileName.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileName = newAttachmentData.fileName
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** This is probably not good and should be re-thought.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Look at how the `AGSPopupAttachmentsViewController` handles this
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** https:***REMOVED***devtopia.esri.com/runtime/cocoa/blob/b788189d3d2eb43b7da8f9cc9af18ed2f3aa6925/api/iOS/Popup/ViewController/AGSPopupAttachmentsViewController.m#L755
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** and
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** https:***REMOVED***devtopia.esri.com/runtime/cocoa/blob/b788189d3d2eb43b7da8f9cc9af18ed2f3aa6925/api/iOS/Popup/ViewController/AGSPopupAttachmentsViewController.m#L725
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileName = "Attachment \(element.attachments.count + 1).\(newAttachmentData.contentType.split(separator: "/").last!)"
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let newAttachment = try await element.addAttachment(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Can this be better? What does legacy do?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: fileName,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***contentType: newAttachmentData.contentType,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: newAttachmentData.data
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***try await onAdd?(newAttachment)
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO: Figure out error handling
***REMOVED******REMOVED******REMOVED******REMOVED***print("Error adding attachment: \(error)")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.newAttachmentData = nil
***REMOVED***
***REMOVED******REMOVED***.task(id: capturedImage) {
***REMOVED******REMOVED******REMOVED***guard let capturedImage, let data = capturedImage.pngData() else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***newAttachmentData = AttachmentData(data: data, contentType: "image/png")
***REMOVED******REMOVED******REMOVED***self.capturedImage = nil
***REMOVED***
***REMOVED******REMOVED***.task(id: newImageData) {
***REMOVED******REMOVED******REMOVED***guard let newImageData else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***newAttachmentData = AttachmentData(data: newImageData, contentType: "image/png")
***REMOVED***
***REMOVED******REMOVED***.fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [.item]) { result in
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case .success(let url):
***REMOVED******REMOVED******REMOVED******REMOVED***guard let data = FileManager.default.contents(atPath: url.path) else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("File picker data was empty")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***newAttachmentData = AttachmentData(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: data,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***contentType: url.mimeType(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileName: url.lastPathComponent
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***print("Error importing from file importer: \(error)")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.fullScreenCover(isPresented: $cameraIsShowing) {
***REMOVED******REMOVED******REMOVED***AttachmentCameraController(capturedImage: $capturedImage)
***REMOVED***
***REMOVED******REMOVED***.modifier(
***REMOVED******REMOVED******REMOVED***AttachmentPhotoPicker(
***REMOVED******REMOVED******REMOVED******REMOVED***newAttachmentData: $newImageData,
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
