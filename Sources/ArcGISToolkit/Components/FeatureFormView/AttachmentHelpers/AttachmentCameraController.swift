// Copyright 2024 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

/// A UIImagePickerController wrapper to provide a native photo capture experience.
struct AttachmentCameraController: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    /// The current import state.
    @Binding var importState: AttachmentImportState
    
    /// The image picker controller represented within the view.
    private let controller = UIImagePickerController()
    
    /// Dismisses the picker controller.
    func endCapture() {
        controller.dismiss(animated: true)
        dismiss()
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
    func makeCoordinator() -> CameraControllerCoordinator {
        CameraControllerCoordinator(parent: self)
    }
}

/// A delegate for the attachment camera controller.
final class CameraControllerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: AttachmentCameraController
    
    init(parent: AttachmentCameraController) {
        self.parent = parent
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        parent.importState = .importing
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let pngData = image.pngData() {
                parent.importState = .finalizing(AttachmentImportData(data: pngData, contentType: "image/png", fileExtension: "png"))
            }
        } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if let videoData = try? Data(contentsOf: videoURL) {
                parent.importState = .finalizing(AttachmentImportData(data: videoData, contentType: "video/quicktime", fileName: videoURL.lastPathComponent))
            }
        }
        parent.endCapture()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.endCapture()
    }
}
