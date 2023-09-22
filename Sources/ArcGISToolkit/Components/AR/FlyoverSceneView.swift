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
***REMOVED******REMOVED***/ The last portrait or landscape orientation value.
***REMOVED***@State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
***REMOVED***@State private var cameraController: TransformationMatrixCameraController
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED***private let configuration: ARWorldTrackingConfiguration
***REMOVED***
***REMOVED******REMOVED***/ Creates a fly over scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - initialCamera: The initial camera.
***REMOVED******REMOVED***/   - translationFactor: The translation factor that defines how much the scene view translates
***REMOVED******REMOVED***/   as the device moves.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. Properties such as the camera controller,
***REMOVED******REMOVED***/ and view drawing mode.
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
***REMOVED******REMOVED***
***REMOVED******REMOVED***configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***SceneViewReader { sceneViewProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder(sceneViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.viewDrawingMode(.manual)
***REMOVED******REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onDidUpdateFrame { session, frame in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateLastGoodDeviceOrientation()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.draw(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: session,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: lastGoodDeviceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.videoFeedHidden()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.run(configuration)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.pause()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
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

extension SceneViewProxy {
***REMOVED******REMOVED***/ Draws the scene view manually and sets the camera for a given augmented reality view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - arViewProxy: The AR view proxy.
***REMOVED******REMOVED***/   - cameraController: The current camera controller assigned to the scene view.
***REMOVED******REMOVED***/   - orientation: The device orientation.
***REMOVED***func draw(
***REMOVED******REMOVED***frame: ARFrame,
***REMOVED******REMOVED***for: ARSession,
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController,
***REMOVED******REMOVED***orientation: UIDeviceOrientation
***REMOVED***) {
***REMOVED******REMOVED***let cameraTransform = frame.camera.transform
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Rotate camera transform 90 degrees counter-clockwise in the XY plane.
***REMOVED******REMOVED***let transform = simd_float4x4.init(
***REMOVED******REMOVED******REMOVED***cameraTransform.columns.1,
***REMOVED******REMOVED******REMOVED***-cameraTransform.columns.0,
***REMOVED******REMOVED******REMOVED***cameraTransform.columns.2,
***REMOVED******REMOVED******REMOVED***cameraTransform.columns.3
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let quaternion = simd_quatf(transform)
***REMOVED******REMOVED***
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
***REMOVED******REMOVED***cameraController.transformationMatrix = .identity.adding(transformationMatrix)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set FOV on scene view.
***REMOVED******REMOVED***let intrinsics = frame.camera.intrinsics
***REMOVED******REMOVED***let imageResolution = frame.camera.imageResolution
***REMOVED******REMOVED***
***REMOVED******REMOVED***setFieldOfViewFromLensIntrinsics(
***REMOVED******REMOVED******REMOVED***xFocalLength: intrinsics[0][0],
***REMOVED******REMOVED******REMOVED***yFocalLength: intrinsics[1][1],
***REMOVED******REMOVED******REMOVED***xPrincipal: intrinsics[2][0],
***REMOVED******REMOVED******REMOVED***yPrincipal: intrinsics[2][1],
***REMOVED******REMOVED******REMOVED***xImageSize: Float(imageResolution.width),
***REMOVED******REMOVED******REMOVED***yImageSize: Float(imageResolution.height),
***REMOVED******REMOVED******REMOVED***deviceOrientation: orientation
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Render the Scene with the new transformation.
***REMOVED******REMOVED***draw()
***REMOVED***
***REMOVED***
