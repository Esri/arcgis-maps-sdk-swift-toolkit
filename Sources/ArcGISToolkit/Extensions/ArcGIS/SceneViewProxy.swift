***REMOVED*** Copyright 2023 Esri
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

import Foundation
***REMOVED***
import ARKit
***REMOVED***

#if !os(visionOS)
extension SceneViewProxy {
***REMOVED******REMOVED***/ Updates the scene view's camera for a given augmented reality frame.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - frame: The current AR frame.
***REMOVED******REMOVED***/   - cameraController: The current camera controller assigned to the scene view.
***REMOVED******REMOVED***/   - orientation: The interface orientation.
***REMOVED***func updateCamera(
***REMOVED******REMOVED***frame: ARFrame,
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController,
***REMOVED******REMOVED***orientation: InterfaceOrientation,
***REMOVED******REMOVED***initialTransformation: TransformationMatrix? = nil
***REMOVED***) {
***REMOVED******REMOVED***let transform = frame.camera.transform(for: orientation)
***REMOVED******REMOVED***let quaternion = simd_quatf(transform)
***REMOVED******REMOVED***let transformationMatrix = TransformationMatrix.normalized(
***REMOVED******REMOVED******REMOVED***quaternionX: Double(quaternion.vector.x),
***REMOVED******REMOVED******REMOVED***quaternionY: Double(quaternion.vector.y),
***REMOVED******REMOVED******REMOVED***quaternionZ: Double(quaternion.vector.z),
***REMOVED******REMOVED******REMOVED***quaternionW: Double(quaternion.vector.w),
***REMOVED******REMOVED******REMOVED***translationX: Double(transform.columns.3.x),
***REMOVED******REMOVED******REMOVED***translationY: Double(transform.columns.3.y),
***REMOVED******REMOVED******REMOVED***translationZ: Double(transform.columns.3.z)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set the matrix on the camera controller.
***REMOVED******REMOVED***if let initialTransformation {
***REMOVED******REMOVED******REMOVED***cameraController.transformationMatrix = initialTransformation.adding(transformationMatrix)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***cameraController.transformationMatrix = transformationMatrix
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the field of view for the scene view's camera for a given augmented reality frame.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - frame: The current AR frame.
***REMOVED******REMOVED***/   - orientation: The interface orientation.
***REMOVED***func setFieldOfView(for frame: ARFrame, orientation: InterfaceOrientation) {
***REMOVED******REMOVED***let camera = frame.camera
***REMOVED******REMOVED***let intrinsics = camera.intrinsics
***REMOVED******REMOVED***let imageResolution = camera.imageResolution
***REMOVED******REMOVED***
***REMOVED******REMOVED***setFieldOfViewFromLensIntrinsics(
***REMOVED******REMOVED******REMOVED***xFocalLength: intrinsics[0][0],
***REMOVED******REMOVED******REMOVED***yFocalLength: intrinsics[1][1],
***REMOVED******REMOVED******REMOVED***xPrincipal: intrinsics[2][0],
***REMOVED******REMOVED******REMOVED***yPrincipal: intrinsics[2][1],
***REMOVED******REMOVED******REMOVED***xImageSize: Float(imageResolution.width),
***REMOVED******REMOVED******REMOVED***yImageSize: Float(imageResolution.height),
***REMOVED******REMOVED******REMOVED***interfaceOrientation: orientation
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension ARCamera {
***REMOVED******REMOVED***/ The transform rotated for a particular interface orientation.
***REMOVED******REMOVED***/ - Parameter orientation: The interface orientation that the transform is appropriate for.
***REMOVED***func transform(for orientation: InterfaceOrientation) -> simd_float4x4 {
***REMOVED******REMOVED***switch orientation {
***REMOVED******REMOVED***case .portrait:
***REMOVED******REMOVED******REMOVED******REMOVED*** Rotate camera transform 90 degrees clockwise in the XY plane.
***REMOVED******REMOVED******REMOVED***return simd_float4x4(
***REMOVED******REMOVED******REMOVED******REMOVED***transform.columns.1,
***REMOVED******REMOVED******REMOVED******REMOVED***-transform.columns.0,
***REMOVED******REMOVED******REMOVED******REMOVED***transform.columns.2,
***REMOVED******REMOVED******REMOVED******REMOVED***transform.columns.3
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .landscapeLeft:
***REMOVED******REMOVED******REMOVED******REMOVED*** No rotation necessary.
***REMOVED******REMOVED******REMOVED***return transform
***REMOVED******REMOVED***case .landscapeRight:
***REMOVED******REMOVED******REMOVED******REMOVED*** Rotate 180.
***REMOVED******REMOVED******REMOVED***return simd_float4x4(
***REMOVED******REMOVED******REMOVED******REMOVED***-transform.columns.0,
***REMOVED******REMOVED******REMOVED******REMOVED***-transform.columns.1,
***REMOVED******REMOVED******REMOVED******REMOVED***transform.columns.2,
***REMOVED******REMOVED******REMOVED******REMOVED***transform.columns.3
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .portraitUpsideDown:
***REMOVED******REMOVED******REMOVED******REMOVED*** Rotate 90 counter clockwise.
***REMOVED******REMOVED******REMOVED***return simd_float4x4(
***REMOVED******REMOVED******REMOVED******REMOVED***-transform.columns.1,
***REMOVED******REMOVED******REMOVED******REMOVED***transform.columns.0,
***REMOVED******REMOVED******REMOVED******REMOVED***transform.columns.2,
***REMOVED******REMOVED******REMOVED******REMOVED***transform.columns.3
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***assertionFailure("Unrecognized interface orientation")
***REMOVED******REMOVED******REMOVED***return transform
***REMOVED***
***REMOVED***
***REMOVED***
#endif
