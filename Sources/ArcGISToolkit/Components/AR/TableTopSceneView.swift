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

***REMOVED***/ A scene view that provides an augmented reality table top experience.
public struct TableTopSceneView: View {
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
***REMOVED***@State private var sceneViewProxy: SceneViewProxy?
***REMOVED***@State private var initialTransformation: TransformationMatrix? = nil
***REMOVED***@State private var cameraController: TransformationMatrixCameraController
***REMOVED***@State private var interfaceOrientation: InterfaceOrientation?
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED***private let configuration: ARWorldTrackingConfiguration
***REMOVED***private var initialTransformationIsSet: Bool { initialTransformation != nil ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a table top scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - anchorPoint: The location point of the ArcGIS Scene that is anchored on a physical surface.
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
***REMOVED******REMOVED***let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
***REMOVED******REMOVED***cameraController.translationFactor = translationFactor
***REMOVED******REMOVED***cameraController.clippingDistance = clippingDistance
***REMOVED******REMOVED***_cameraController = .init(initialValue: cameraController)
***REMOVED******REMOVED***
***REMOVED******REMOVED***configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED******REMOVED***configuration.planeDetection = [.horizontal]
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***InterfaceOrientationDetector(interfaceOrientation: $interfaceOrientation)
***REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***.onDidUpdateFrame { _, frame in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation ?? .portrait,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation: initialTransformation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.setFieldOfView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation ?? .portrait
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onAddNode { _, node, anchor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***addPlane(with: node, for: anchor)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onUpdateNode { _, node, anchor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updatePlane(with: node, for: anchor)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  !initialTransformationIsSet
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let transformation = sceneViewProxy.initialTransformation(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: arViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***using: screenPoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation = transformation
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.run(configuration)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.pause()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***SceneViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder(proxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.sceneViewProxy = proxy
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.opacity(initialTransformationIsSet ? 1 : 0)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Visualizes a new node added to the scene as an AR Plane.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - node: The node to be added to the scene.
***REMOVED******REMOVED***/   - anchor: The anchor position of the node.
***REMOVED***private func addPlane(with node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED*** Place content only for anchors found by plane detection.
***REMOVED******REMOVED***guard let planeAnchor = anchor as? ARPlaneAnchor,
***REMOVED******REMOVED******REMOVED***  ***REMOVED*** Create a custom object to visualize the plane geometry and extent.
***REMOVED******REMOVED******REMOVED***  let plane = Plane(anchor: planeAnchor) else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Add the visualization to the ARKit-managed node so that it tracks
***REMOVED******REMOVED******REMOVED*** changes in the plane anchor as plane estimation continues.
***REMOVED******REMOVED***node.addChildNode(plane)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Visualizes a node updated in scene as an AR Plane.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - node: The node to be updated in the scene.
***REMOVED******REMOVED***/   - anchor: The anchor position of the node.
***REMOVED***private func updatePlane(with node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED***if initialTransformationIsSet {
***REMOVED******REMOVED******REMOVED***node.removeFromParentNode()
***REMOVED***
***REMOVED******REMOVED***
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

private extension View {
***REMOVED******REMOVED***/ Sets a closure to perform when a single tap occurs on the view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - action: The closure to perform upon single tap.
***REMOVED******REMOVED***/   - screenPoint: The location of the tap in the view's coordinate space.
***REMOVED***func onSingleTapGesture(perform action: @escaping (_ screenPoint: CGPoint) -> Void) -> some View {
***REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED***return self.onTapGesture { screenPoint in
***REMOVED******REMOVED******REMOVED******REMOVED***action(screenPoint)
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return self.gesture(
***REMOVED******REMOVED******REMOVED******REMOVED***DragGesture()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onEnded { dragAttributes in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(dragAttributes.location)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A helper class to visualize a plane found by ARKit.
private class Plane: SCNNode {
***REMOVED******REMOVED***/ The plane node.
***REMOVED***let node: SCNNode
***REMOVED***
***REMOVED******REMOVED***/ Creates a plane node to visuialize a plane found by ARKit.
***REMOVED******REMOVED***/ - Parameter anchor: The ARPlaneAnchor used to set the plane node's geometry.
***REMOVED***init?(anchor: ARPlaneAnchor) {
***REMOVED******REMOVED******REMOVED*** Create a node to visualize the plane's bounding rectangle.
***REMOVED******REMOVED***let extent = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
***REMOVED******REMOVED***node = SCNNode(geometry: extent)
***REMOVED******REMOVED***node.simdPosition = anchor.center
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** `SCNPlane` is vertically oriented in its local coordinate space, so
***REMOVED******REMOVED******REMOVED*** rotate it to match the orientation of `ARPlaneAnchor`.
***REMOVED******REMOVED***node.eulerAngles.x = -.pi / 2
***REMOVED******REMOVED***
***REMOVED******REMOVED***super.init()
***REMOVED******REMOVED***
***REMOVED******REMOVED***node.opacity = 0.25
***REMOVED******REMOVED***guard let material = node.geometry?.firstMaterial else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***material.diffuse.contents = UIColor.white
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Add the plane node as child node so they appear in the scene.
***REMOVED******REMOVED***addChildNode(node)
***REMOVED***
***REMOVED***
***REMOVED***required init?(coder aDecoder: NSCoder) {
***REMOVED******REMOVED***fatalError("init(coder:) has not been implemented")
***REMOVED***
***REMOVED***

private extension ARSwiftUIViewProxy {
***REMOVED******REMOVED***/ Performs a hit test operation to get the transformation matrix representing the corresponding real-world point for `screenPoint`.
***REMOVED******REMOVED***/ - Parameter screenPoint: The screen point to determine the real world transformation matrix from.
***REMOVED******REMOVED***/ - Returns: A `TransformationMatrix` representing the real-world point corresponding to `screenPoint`.
***REMOVED***func hitTest(at screenPoint: CGPoint) -> TransformationMatrix? {
***REMOVED******REMOVED******REMOVED*** Use the `raycastQuery` method on ARSCNView to get the location of `screenPoint`.
***REMOVED******REMOVED***guard let query = raycastQuery(
***REMOVED******REMOVED******REMOVED***from: screenPoint,
***REMOVED******REMOVED******REMOVED***allowing: .existingPlaneGeometry,
***REMOVED******REMOVED******REMOVED***alignment: .any
***REMOVED******REMOVED***) else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = session?.raycast(query)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Get the worldTransform from the first result; if there's no worldTransform, return nil.
***REMOVED******REMOVED***guard let worldTransform = results?.first?.worldTransform else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create our hit test matrix based on the worldTransform location.
***REMOVED******REMOVED******REMOVED*** Right now we ignore the orientation of the plane that was hit to find the point
***REMOVED******REMOVED******REMOVED*** since we only use horizontal planes.
***REMOVED******REMOVED******REMOVED*** If we start supporting vertical planes we will have to stop suppressing the
***REMOVED******REMOVED******REMOVED*** quaternion rotation to a null rotation (0,0,0,1).
***REMOVED******REMOVED***let hitTestMatrix = TransformationMatrix.normalized(
***REMOVED******REMOVED******REMOVED***quaternionX: 0,
***REMOVED******REMOVED******REMOVED***quaternionY: 0,
***REMOVED******REMOVED******REMOVED***quaternionZ: 0,
***REMOVED******REMOVED******REMOVED***quaternionW: 1,
***REMOVED******REMOVED******REMOVED***translationX: Double(worldTransform.columns.3.x),
***REMOVED******REMOVED******REMOVED***translationY: Double(worldTransform.columns.3.y),
***REMOVED******REMOVED******REMOVED***translationZ: Double(worldTransform.columns.3.z)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return hitTestMatrix
***REMOVED***
***REMOVED***

private extension SceneViewProxy {
***REMOVED******REMOVED***/ Sets the initial transformation used to offset the originCamera.  The initial transformation is based on an AR point determined
***REMOVED******REMOVED***/ via existing plane hit detection from `screenPoint`.  If an AR point cannot be determined, this method will return `false`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - arViewProxy: The AR view proxy.
***REMOVED******REMOVED***/   - screenPoint: The screen point to determine the `initialTransformation` from.
***REMOVED******REMOVED***/ - Returns: The `initialTransformation`.
***REMOVED***func initialTransformation(
***REMOVED******REMOVED***for arViewProxy: ARSwiftUIViewProxy,
***REMOVED******REMOVED***using screenPoint: CGPoint
***REMOVED***) -> TransformationMatrix? {
***REMOVED******REMOVED******REMOVED*** Use the `hitTest` method to get the matrix of `screenPoint`.
***REMOVED******REMOVED***guard let matrix = arViewProxy.hitTest(at: screenPoint) else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set the `initialTransformation` as the TransformationMatrix.identity - hit test matrix.
***REMOVED******REMOVED***let initialTransformation = TransformationMatrix.identity.subtracting(matrix)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return initialTransformation
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
