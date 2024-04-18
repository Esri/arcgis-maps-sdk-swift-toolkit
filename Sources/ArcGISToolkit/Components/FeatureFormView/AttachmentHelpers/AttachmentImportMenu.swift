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

***REMOVED***/ The popup menu shown when the new attachment button is pressed.
struct AttachmentImportMenu: View {
***REMOVED***private let element: AttachmentFormElement
***REMOVED***
***REMOVED***init(element: AttachmentFormElement) {
***REMOVED******REMOVED***self.element = element
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment camera controller is presented.
***REMOVED***@State private var cameraIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment file importer is presented.
***REMOVED***@State private var fileImporterIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment photo picker is presented.
***REMOVED***@State private var photosPickerIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ The new attachment data retrieved from the photos picker.
***REMOVED***@State private var newAttachmentData: Data?
***REMOVED***
***REMOVED******REMOVED***/ The new attachment retrieved from the device's camera.
***REMOVED***@State private var capturedImage: UIImage?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Menu {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***cameraIsShowing = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label("Take photo", systemImage: "camera")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***photosPickerIsShowing = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label("Add photo from library", systemImage: "photo")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***fileImporterIsShowing = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label("Add photo from files", systemImage: "folder")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "plus")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED***
***REMOVED******REMOVED***.task(id: newAttachmentData) {
***REMOVED******REMOVED******REMOVED***guard let newAttachmentData else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***_ = try await element.addAttachment(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: "Attachment \(element.attachments.count + 1)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***contentType: "image/png",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: newAttachmentData
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print("Error adding attachment: \(error)")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.newAttachmentData = nil
***REMOVED***
***REMOVED******REMOVED***.task(id: capturedImage) {
***REMOVED******REMOVED******REMOVED***guard let capturedImage, let data = capturedImage.pngData() else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***newAttachmentData = data
***REMOVED******REMOVED******REMOVED***self.capturedImage = nil
***REMOVED***
***REMOVED******REMOVED***.fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [.item]) { result in
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case .success(let url):
***REMOVED******REMOVED******REMOVED******REMOVED***guard let data = FileManager.default.contents(atPath: url.path) else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("File picker data was empty")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***newAttachmentData = data
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***print("Error importing from file importer: \(error)")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.fullScreenCover(isPresented: $cameraIsShowing) {
***REMOVED******REMOVED******REMOVED***AttachmentCameraController(capturedImage: $capturedImage)
***REMOVED***
***REMOVED******REMOVED***.modifier(
***REMOVED******REMOVED******REMOVED***AttachmentPhotoPicker(
***REMOVED******REMOVED******REMOVED******REMOVED***newAttachmentData: $newAttachmentData,
***REMOVED******REMOVED******REMOVED******REMOVED***photoPickerIsShowing: $photosPickerIsShowing
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
