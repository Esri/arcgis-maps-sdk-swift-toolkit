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


@testable import ArcGISToolkit

import SwiftUI

struct AttachmentCameraControllerTestView: View {
    @State private var captureMode: UIImagePickerController.CameraCaptureMode?
    
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        Color.clear
            .fullScreenCover(isPresented: .constant(true)) {
                AttachmentCameraController(importState: .constant(.none))
#if !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
                    .onCameraCaptureModeChanged { captureMode in
                        self.captureMode = captureMode
                    }
#endif
                    .overlay {
                        VStack {
                            Text(captureMode?.name ?? "None")
                                .accessibilityIdentifier("Camera Capture Mode")
                            Text(orientation.name)
                                .accessibilityIdentifier("Device Orientation")
                                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                                    orientation = UIDevice.current.orientation
                                }
                                .task {
                                    orientation = UIDevice.current.orientation
                                }
                        }
                    }
            }
    }
}

extension UIDeviceOrientation {
    var name: String {
        switch self {
        case .portrait: "Portrait"
        case .landscapeLeft: "Landscape Left"
        case .landscapeRight: "Landscape Right"
        default: "Other"
        }
    }
}

extension UIImagePickerController.CameraCaptureMode {
    var name: String {
        switch self {
        case .photo: "Photo"
        case .video: "Video"
        @unknown default: "N/A"
        }
    }
}
