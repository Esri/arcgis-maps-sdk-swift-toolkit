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
public struct TableTopSceneView: View {
***REMOVED******REMOVED***/ The last portrait or landscape orientation value.
***REMOVED***@State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
***REMOVED***@State private var sceneViewProxy: SceneViewProxy?
***REMOVED***@State private var initialTransformation: TransformationMatrix? = nil
***REMOVED***
***REMOVED***private let cameraController: TransformationMatrixCameraController
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED***private let configuration: ARWorldTrackingConfiguration
***REMOVED***private var didSetTransforamtion: Bool {
***REMOVED******REMOVED***initialTransformation != nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a fly over scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - anchorPoint: The anchor point of the ArcGIS Scene.
***REMOVED******REMOVED***/   - translationFactor: The translation factor that defines how much the scene view translates
***REMOVED******REMOVED***/   as the device moves.
***REMOVED******REMOVED***/   - clippingDistance: Determines the clipping distance in meters around the camera. A value
***REMOVED******REMOVED***/   of `nil` means that no data will be clipped.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. Properties such as the camera controller,
***REMOVED******REMOVED***/ and view drawing mode.
***REMOVED***public init(
***REMOVED******REMOVED***anchorPoint: Point,
***REMOVED******REMOVED***translationFactor: Double,
***REMOVED******REMOVED***clippingDistance: Double?,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.sceneViewBuilder = sceneView
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialCamera = Camera(location: anchorPoint, heading: 0, pitch: 90, roll: 0)
***REMOVED******REMOVED***cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
***REMOVED******REMOVED***cameraController.translationFactor = translationFactor
***REMOVED******REMOVED***cameraController.clippingDistance = clippingDistance
***REMOVED******REMOVED***
***REMOVED******REMOVED***configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED******REMOVED***configuration.planeDetection = [.horizontal]
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onRender { _, _, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateLastGoodDeviceOrientation()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.draw(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: arViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: lastGoodDeviceOrientation,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation: initialTransformation ?? .identity
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAddNode { renderer, node, anchor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visualizePlane(renderer, didAdd: node, for: anchor)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onUpdateNode { renderer, node, anchor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updatePlane(renderer, didUpdate: node, for: anchor)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.run(configuration)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.pause()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture { screenPoint in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  !didSetTransforamtion else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let transformation = sceneViewProxy.setInitialTransformation(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: arViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***using: screenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation = transformation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SceneViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder(proxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.viewDrawingMode(.manual)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.sceneViewProxy = proxy
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.opacity(didSetTransforamtion ? 1 : 0)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
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
***REMOVED***func visualizePlane(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED*** Place content only for anchors found by plane detection.
***REMOVED******REMOVED***guard let planeAnchor = anchor as? ARPlaneAnchor else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create a custom object to visualize the plane geometry and extent.
***REMOVED******REMOVED***let plane = Plane(anchor: planeAnchor)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Add the visualization to the ARKit-managed node so that it tracks
***REMOVED******REMOVED******REMOVED*** changes in the plane anchor as plane estimation continues.
***REMOVED******REMOVED***node.addChildNode(plane)
***REMOVED***
***REMOVED***
***REMOVED***func updatePlane(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED***if didSetTransforamtion {
***REMOVED******REMOVED***   node.removeFromParentNode()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***guard let planeAnchor = anchor as? ARPlaneAnchor,
***REMOVED******REMOVED******REMOVED***  let plane = node.childNodes.first as? Plane
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Update extent visualization to the anchor's new bounding rectangle.
***REMOVED******REMOVED***if let extentGeometry = plane.node.geometry as? SCNPlane {
***REMOVED******REMOVED******REMOVED***extentGeometry.width = CGFloat(planeAnchor.extent.x)
***REMOVED******REMOVED******REMOVED***extentGeometry.height = CGFloat(planeAnchor.extent.z)
***REMOVED******REMOVED******REMOVED***plane.node.simdPosition = planeAnchor.center
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ Helper class to visualize a plane found by ARKit
class Plane: SCNNode {
***REMOVED***let node: SCNNode
***REMOVED***
***REMOVED***init(anchor: ARPlaneAnchor) {
***REMOVED******REMOVED******REMOVED*** Create a node to visualize the plane's bounding rectangle.
***REMOVED******REMOVED***let extent = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
***REMOVED******REMOVED***node = SCNNode(geometry: extent)
***REMOVED******REMOVED***node.simdPosition = anchor.center
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** `SCNPlane` is vertically oriented in its local coordinate space, so
***REMOVED******REMOVED******REMOVED*** rotate it to match the orientation of `ARPlaneAnchor`.
***REMOVED******REMOVED***node.eulerAngles.x = -.pi / 2

***REMOVED******REMOVED***super.init()

***REMOVED******REMOVED***node.opacity = 0.25
***REMOVED******REMOVED***guard let material = node.geometry?.firstMaterial
***REMOVED******REMOVED******REMOVED***else { fatalError("SCNPlane always has one material") ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***material.diffuse.contents = UIColor.white

***REMOVED******REMOVED******REMOVED*** Add the plane node as child node so they appear in the scene.
***REMOVED******REMOVED***addChildNode(node)
***REMOVED***
***REMOVED***
***REMOVED***required init?(coder aDecoder: NSCoder) {
***REMOVED******REMOVED***fatalError("init(coder:) has not been implemented")
***REMOVED***
***REMOVED***

private extension SceneViewProxy {
***REMOVED******REMOVED***/ Sets the initial transformation used to offset the originCamera.  The initial transformation is based on an AR point determined via existing plane hit detection from `screenPoint`.  If an AR point cannot be determined, this method will return `false`.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameter screenPoint: The screen point to determine the `initialTransformation` from.
***REMOVED******REMOVED***/ - Returns: The `initialTransformation`.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***func setInitialTransformation(
***REMOVED******REMOVED***for arViewProxy: ARSwiftUIViewProxy,
***REMOVED******REMOVED***using screenPoint: CGPoint,
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController
***REMOVED***) -> TransformationMatrix? {
***REMOVED******REMOVED******REMOVED*** Use the `internalHitTest` method to get the matrix of `screenPoint`.
***REMOVED******REMOVED***guard let matrix = internalHitTest(using: screenPoint, for: arViewProxy) else { return nil ***REMOVED***

***REMOVED******REMOVED******REMOVED*** Set the `initialTransformation` as the TransformationMatrix.identity - hit test matrix.
***REMOVED******REMOVED***let initialTransformation = TransformationMatrix.identity.subtracting(matrix)

***REMOVED******REMOVED***return initialTransformation
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Internal method to perform a hit test operation to get the transformation matrix representing the corresponding real-world point for `screenPoint`.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameter screenPoint: The screen point to determine the real world transformation matrix from.
***REMOVED******REMOVED***/ - Returns: An `TransformationMatrix` representing the real-world point corresponding to `screenPoint`.
***REMOVED***func internalHitTest(using screenPoint: CGPoint, for arViewProxy: ARSwiftUIViewProxy) -> TransformationMatrix? {
***REMOVED******REMOVED******REMOVED*** Use the `raycastQuery` method on ARSCNView to get the location of `screenPoint`.
***REMOVED******REMOVED***guard let query = arViewProxy.raycastQuery(
***REMOVED******REMOVED******REMOVED***from: screenPoint,
***REMOVED******REMOVED******REMOVED***allowing: .existingPlaneGeometry,
***REMOVED******REMOVED******REMOVED***alignment: .any
***REMOVED******REMOVED***) else { return nil ***REMOVED***

***REMOVED******REMOVED***let results = arViewProxy.session?.raycast(query)

***REMOVED******REMOVED******REMOVED*** Get the worldTransform from the first result; if there's no worldTransform, return nil.
***REMOVED******REMOVED***guard let worldTransform = results?.first?.worldTransform else { return nil ***REMOVED***

***REMOVED******REMOVED******REMOVED*** Create our hit test matrix based on the worldTransform location.
***REMOVED******REMOVED******REMOVED*** right now we ignore the orientation of the plane that was hit to find the point
***REMOVED******REMOVED******REMOVED*** since we only use horizontal planes, when we will start using vertical planes
***REMOVED******REMOVED******REMOVED*** we should stop suppressing the quaternion rotation to a null rotation (0,0,0,1)
***REMOVED******REMOVED***let hitTestMatrix = TransformationMatrix.normalized(
***REMOVED******REMOVED******REMOVED***quaternionX: 0,
***REMOVED******REMOVED******REMOVED***quaternionY: 0,
***REMOVED******REMOVED******REMOVED***quaternionZ: 0,
***REMOVED******REMOVED******REMOVED***quaternionW: 1,
***REMOVED******REMOVED******REMOVED***translationX: Double(worldTransform.columns.3.x),
***REMOVED******REMOVED******REMOVED***translationY: Double(worldTransform.columns.3.y),
***REMOVED******REMOVED******REMOVED***translationZ: Double(worldTransform.columns.3.z)
***REMOVED******REMOVED***)

***REMOVED******REMOVED***return hitTestMatrix
***REMOVED***
***REMOVED***
