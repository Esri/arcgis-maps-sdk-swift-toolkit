***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import ARKit
***REMOVED***
***REMOVED***

***REMOVED***/ A scene view that provides an augmented reality fly over experience.
public struct FlyoverSceneView: View {
***REMOVED******REMOVED***/ The AR session.
***REMOVED***@StateObject private var session = ObservableARSession()
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED******REMOVED***/ The camera controller that we will set on the scene view.
***REMOVED***@State private var cameraController: TransformationMatrixCameraController
***REMOVED******REMOVED***/ The last portrait or landscape orientation value.
***REMOVED***@State var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
***REMOVED***
***REMOVED******REMOVED***/ Creates a fly over scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - initialCamera: The initial camera.
***REMOVED******REMOVED***/   - translationFactor: The translation factor that defines how much the scene view translates
***REMOVED******REMOVED***/   as the device moves.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. One such property is the camera controller.
***REMOVED***public init(
***REMOVED******REMOVED***initialCamera: Camera,
***REMOVED******REMOVED***translationFactor: Double,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.sceneViewBuilder = sceneView
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
***REMOVED******REMOVED***cameraController.translationFactor = translationFactor
***REMOVED******REMOVED***_cameraController = .init(initialValue: cameraController)
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***SceneViewReader { sceneViewProxy in
***REMOVED******REMOVED******REMOVED***sceneViewBuilder(sceneViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear { session.start() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onDisappear { session.pause() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: session.currentFrame) { frame in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let frame else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: lastGoodDeviceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the last good device orientation.
***REMOVED***func updateLastGoodDeviceOrientation() {
***REMOVED******REMOVED******REMOVED*** Get the device orientation, but don't allow non-landscape/portrait values.
***REMOVED******REMOVED***let deviceOrientation = UIDevice.current.orientation
***REMOVED******REMOVED***if deviceOrientation.isValidInterfaceOrientation {
***REMOVED******REMOVED******REMOVED***lastGoodDeviceOrientation = deviceOrientation
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ An observable object that wraps an `ARSession` and provides the current frame.
private class ObservableARSession: NSObject, ObservableObject, ARSessionDelegate {
***REMOVED******REMOVED***/ The configuration used for the AR session.
***REMOVED***private let configuration: ARWorldTrackingConfiguration
***REMOVED***
***REMOVED******REMOVED***/ The backing AR session.
***REMOVED***private let session = ARSession()
***REMOVED***
***REMOVED***override init() {
***REMOVED******REMOVED***configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED******REMOVED***super.init()
***REMOVED******REMOVED***session.delegate = self
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Starts the AR session.
***REMOVED***func start() {
***REMOVED******REMOVED***session.run(configuration)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Pauses the AR session.
***REMOVED***func pause() {
***REMOVED******REMOVED***session.pause()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The latest AR frame.
***REMOVED***@Published
***REMOVED***var currentFrame: ARFrame?
***REMOVED***
***REMOVED***func session(_ session: ARSession, didUpdate frame: ARFrame) {
***REMOVED******REMOVED***currentFrame = frame
***REMOVED***
***REMOVED***

extension SceneViewProxy {
***REMOVED******REMOVED***/ Updates the scene view's camera for a given augmented reality frame.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - frame: The current AR frame.
***REMOVED******REMOVED***/   - cameraController: The current camera controller assigned to the scene view.
***REMOVED******REMOVED***/   - orientation: The device orientation.
***REMOVED***func updateCamera(
***REMOVED******REMOVED***frame: ARFrame,
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController,
***REMOVED******REMOVED***orientation: UIDeviceOrientation,
***REMOVED******REMOVED***initialTransformation: TransformationMatrix = .identity
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
***REMOVED******REMOVED***cameraController.transformationMatrix = initialTransformation.adding(transformationMatrix)
***REMOVED***
***REMOVED***

private extension ARCamera {
***REMOVED******REMOVED***/ The transform rotated for a particular device orientation.
***REMOVED******REMOVED***/ - Parameter orientation: The device orientation that the transform is appropriate for.
***REMOVED******REMOVED***/ - Precondition: 'orientation.isValidInterfaceOrientation'
***REMOVED***func transform(for orientation: UIDeviceOrientation) -> simd_float4x4 {
***REMOVED******REMOVED***precondition(orientation.isValidInterfaceOrientation)
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
***REMOVED******REMOVED******REMOVED***preconditionFailure()
***REMOVED***
***REMOVED***
***REMOVED***