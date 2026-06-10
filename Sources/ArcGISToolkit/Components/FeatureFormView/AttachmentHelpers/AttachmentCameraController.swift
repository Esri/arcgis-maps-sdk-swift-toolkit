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

#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

/// A UIImagePickerController wrapper to provide a native photo or video capture experience.
struct AttachmentCameraController: UIViewControllerRepresentable {
    /// Specifies whether, images, movies or both, can be captured and an optional maximum duration for movies.
    struct Configuration: Identifiable {
        let allowedFormats: AllowedFormats
        let movieMaxDuration: TimeInterval?
        let id = UUID()
    }
    
    /// Specifies whether, images, movies or both, can be captured.
    enum AllowedFormats {
        case image
        case imageAndMovie
        case movie
    }
    
    /// The current import state.
    @Binding var importState: AttachmentImportState
    
    /// The configuration for the camera controller.
    @Binding var configuration: Configuration?
    
    /// The image picker controller represented within the view.
    private let controller = AttachmentUIImagePickerController()
    
    func makeUIViewController(context: Context) -> some UIViewController {
        controller.mediaTypes = switch configuration?.allowedFormats {
        case .image:
            ["public.image"]
        case .imageAndMovie:
            UIImagePickerController.availableMediaTypes(for: .camera) ?? []
        case .movie:
            ["public.movie"]
        case .none:
            []
        }
        if let movieMaxDuration = configuration?.movieMaxDuration {
            controller.videoMaximumDuration = movieMaxDuration
        }
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
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
            if let jpegData = image.jpegData(compressionQuality: 0.9) {
                parent.importState = .finalizing(AttachmentImportData(contentType: .jpeg, data: jpegData))
            }
        } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if let contentType = UTType(filenameExtension: videoURL.pathExtension),
               let videoData = try? Data(contentsOf: videoURL) {
                parent.importState = .finalizing(AttachmentImportData(contentType: contentType, data: videoData))
            }
        }
        parent.configuration = nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.configuration = nil
    }
}

#if !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
extension AttachmentCameraController {
    /// Specifies an action to perform when the camera capture mode has changed from photo to video or vice versa.
    /// - Parameter action: The new camera capture mode.
    func onCameraCaptureModeChanged(perform action: @MainActor @Sendable @escaping (_: UIImagePickerController.CameraCaptureMode) -> Void) -> Self {
        self.controller.action = action
        return self
    }
}
#endif

/// A wrapper around ``UIImagePickerController``.
///
/// Use this wrapper to monitor additional properties like the current camera capture mode (photo/video).
class AttachmentUIImagePickerController: UIImagePickerController {
    /// Observes changes to the camera capture mode.
    var cameraCaptureModeObserver: (any NSObjectProtocol)?
    
    /// An action to perform when the camera capture mode changes.
    var action: (@MainActor (UIImagePickerController.CameraCaptureMode) -> Void)?
    
    override func viewDidAppear(_ animated: Bool) {
        cameraCaptureModeObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("SourceFormatDidChange"), object: nil, queue: nil) { notification in
            Task { @MainActor in
                self.action?(self.cameraCaptureMode)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let cameraCaptureModeObserver {
            NotificationCenter.default.removeObserver(cameraCaptureModeObserver)
        }
    }
}
#endif
