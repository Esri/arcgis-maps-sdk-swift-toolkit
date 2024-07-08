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
import UniformTypeIdentifiers

***REMOVED***/ A UIImagePickerController wrapper to provide a native photo capture experience.
struct AttachmentCameraController: UIViewControllerRepresentable {
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED***
***REMOVED******REMOVED***/ The current import state.
***REMOVED***@Binding var importState: AttachmentImportState
***REMOVED***
***REMOVED******REMOVED***/ The image picker controller represented within the view.
***REMOVED***private let controller = UIImagePickerController()
***REMOVED***
***REMOVED******REMOVED***/ Dismisses the picker controller.
***REMOVED***func endCapture() {
***REMOVED******REMOVED***controller.dismiss(animated: true)
***REMOVED******REMOVED***dismiss()
***REMOVED***
***REMOVED***
***REMOVED***func makeUIViewController(context: Context) -> some UIViewController {
***REMOVED******REMOVED***controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
***REMOVED******REMOVED***controller.sourceType = .camera
***REMOVED******REMOVED***controller.delegate = context.coordinator
***REMOVED******REMOVED***return controller
***REMOVED***
***REMOVED***
***REMOVED***func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { ***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> CameraControllerCoordinator {
***REMOVED******REMOVED***CameraControllerCoordinator(parent: self)
***REMOVED***
***REMOVED***

***REMOVED***/ A delegate for the attachment camera controller.
final class CameraControllerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
***REMOVED***var parent: AttachmentCameraController
***REMOVED***
***REMOVED***init(parent: AttachmentCameraController) {
***REMOVED******REMOVED***self.parent = parent
***REMOVED***
***REMOVED***
***REMOVED***func imagePickerController(
***REMOVED******REMOVED***_ picker: UIImagePickerController,
***REMOVED******REMOVED***didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
***REMOVED***) {
***REMOVED******REMOVED***parent.importState = .importing
***REMOVED******REMOVED***if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
***REMOVED******REMOVED******REMOVED***if let pngData = image.pngData() {
***REMOVED******REMOVED******REMOVED******REMOVED***parent.importState = .finalizing(AttachmentImportData(contentType: .png, data: pngData))
***REMOVED******REMOVED***
***REMOVED*** else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
***REMOVED******REMOVED******REMOVED***if let contentType = UTType(filenameExtension: videoURL.pathExtension),
***REMOVED******REMOVED******REMOVED***   let videoData = try? Data(contentsOf: videoURL) {
***REMOVED******REMOVED******REMOVED******REMOVED***parent.importState = .finalizing(AttachmentImportData(contentType: contentType, data: videoData))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***parent.endCapture()
***REMOVED***
***REMOVED***
***REMOVED***func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
***REMOVED******REMOVED***parent.endCapture()
***REMOVED***
***REMOVED***
