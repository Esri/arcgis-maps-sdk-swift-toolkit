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


@testable ***REMOVED***Toolkit

***REMOVED***

struct AttachmentCameraControllerTestView: View {
***REMOVED***@State private var captureMode: UIImagePickerController.CameraCaptureMode?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED***.fullScreenCover(isPresented: .constant(true)) {
***REMOVED******REMOVED******REMOVED******REMOVED***AttachmentCameraController(importState: .constant(.none))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onCameraCaptureModeChanged { captureMode in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.captureMode = captureMode
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(captureMode?.name ?? "None")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("Camera Capture Mode")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

extension UIImagePickerController.CameraCaptureMode {
***REMOVED***var name: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .photo: "Photo"
***REMOVED******REMOVED***case .video: "Video"
***REMOVED******REMOVED***@unknown default: "N/A"
***REMOVED***
***REMOVED***
***REMOVED***
