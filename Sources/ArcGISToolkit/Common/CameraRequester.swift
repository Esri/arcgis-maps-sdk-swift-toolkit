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

import AVFoundation
import SwiftUI

private struct CameraRequesterModifier: ViewModifier {
    @ObservedObject var requester: CameraRequester
    
    func body(content: Content) -> some View {
        content
            .alert(cameraAccessAlertTitle, isPresented: $requester.alertIsPresented) {
#if !targetEnvironment(macCatalyst)
                Button(String.settings) {
                    Task { await UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }
                }
#endif
                Button(String.cancel, role: .cancel) {
                    requester.onAccessDenied?()
                }
            } message: {
                Text(cameraAccessAlertMessage)
            }
    }
}

extension View {
    func cameraRequester(_ requester: CameraRequester) -> some View {
        modifier(CameraRequesterModifier(requester: requester))
    }
}

private extension CameraRequesterModifier {
    /// A message for an alert requesting camera access.
    var cameraAccessAlertMessage: String {
        .init(
            localized: "Please enable camera access in settings.",
            bundle: .toolkitModule,
            comment: "A message for an alert requesting camera access."
        )
    }
    
    /// A title for an alert that camera access is disabled.
    var cameraAccessAlertTitle: String {
        .init(
            localized: "Camera access is disabled",
            bundle: .toolkitModule,
            comment: "A title for an alert that camera access is disabled."
        )
    }
}

private protocol CameraAccessDelegate {
    var onAccessDenied: (() -> Void)? { get }
    func requestAccess(onAccessGranted: @escaping () -> Void, onAccessDenied: @escaping () -> Void)
}

final class CameraRequester: ObservableObject, CameraAccessDelegate {
    enum Result {
        case granted
        case denied
    }
    
    @Published var alertIsPresented = false
    
    var onAccessDenied: (() -> Void)?
    
    func requestAccess(onAccessGranted: @escaping () -> Void, onAccessDenied: @escaping () -> Void) {
        self.onAccessDenied = onAccessDenied
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            onAccessGranted()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    onAccessGranted()
                } else {
                    self?.alertIsPresented = true
                }
            }
        default:
            alertIsPresented = true
        }
    }
}
