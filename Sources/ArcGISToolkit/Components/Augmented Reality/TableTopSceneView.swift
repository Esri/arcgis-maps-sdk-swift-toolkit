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

import ARKit
***REMOVED***
***REMOVED***

***REMOVED***/ A scene view that provides an augmented reality table top experience.
public struct TableTopSceneView: View {
***REMOVED******REMOVED***/ The proxy for the ARSwiftUIView.
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
***REMOVED******REMOVED***/ The initial transformation for the scene's camera controller.
***REMOVED***@State private var initialTransformation: TransformationMatrix? = nil
***REMOVED******REMOVED***/ The camera controller that will be set on the scene view.
***REMOVED***@State private var cameraController: TransformationMatrixCameraController
***REMOVED******REMOVED***/ The current interface orientation.
***REMOVED***@State private var interfaceOrientation: InterfaceOrientation?
***REMOVED******REMOVED***/ The help text to guide the user through an AR experience.
***REMOVED***@State private var helpText: String = ""
***REMOVED******REMOVED***/ A Boolean value that indicates whether the coaching overlay view is active.
***REMOVED***@State private var coachingOverlayIsActive: Bool = true
***REMOVED******REMOVED***/ A Boolean value that indicates whether to hide the coaching overlay view.
***REMOVED***var coachingOverlayIsHidden: Bool = false
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED******REMOVED***/ The configuration for the AR session.
***REMOVED***private let configuration: ARWorldTrackingConfiguration
***REMOVED******REMOVED***/ A Boolean value indicating that the scene's initial transformation has been set.
***REMOVED***var initialTransformationIsSet: Bool { initialTransformation != nil ***REMOVED***
***REMOVED******REMOVED***/ The anchor point for the scene view.
***REMOVED***let anchorPoint: Point
***REMOVED******REMOVED***/ The translation factor for the scene's camera controller.
***REMOVED***let translationFactor: Double
***REMOVED******REMOVED***/ The clipping distance for the scene's camera controller.
***REMOVED***let clippingDistance: Double?
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
***REMOVED******REMOVED***self.anchorPoint = anchorPoint
***REMOVED******REMOVED***self.translationFactor = translationFactor
***REMOVED******REMOVED***self.clippingDistance = clippingDistance
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
***REMOVED******REMOVED***SceneViewReader { sceneViewProxy in
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onDidUpdateFrame { _, frame in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let interfaceOrientation else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation: initialTransformation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.setFieldOfView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAddNode { renderer, node, anchor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***addPlane(renderer: renderer, node: node, anchor: anchor)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onUpdateNode { _, node, anchor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updatePlane(with: node, for: anchor)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture { screenPoint in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard !initialTransformationIsSet else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let transformation = sceneViewProxy.initialTransformation(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: arViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***using: screenPoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation = transformation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***helpText = ""
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session.run(configuration)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session.pause()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if !coachingOverlayIsHidden {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ARCoachingOverlay(goal: .horizontalPlane)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sessionProvider(arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.active(coachingOverlayIsActive)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.allowsHitTesting(false)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.overlay (alignment: .top) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !helpText.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(helpText)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(.regularMaterial, ignoresSafeAreaEdges: .horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder(sceneViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.opacity(initialTransformationIsSet ? 1 : 0)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: anchorPoint) { anchorPoint in
***REMOVED******REMOVED******REMOVED***cameraController.originCamera = Camera(location: anchorPoint, heading: 0, pitch: 90, roll: 0)
***REMOVED***
***REMOVED******REMOVED***.onChange(of: translationFactor) { translationFactor in
***REMOVED******REMOVED******REMOVED***cameraController.translationFactor = translationFactor
***REMOVED***
***REMOVED******REMOVED***.onChange(of: clippingDistance) { clippingDistance in
***REMOVED******REMOVED******REMOVED***cameraController.clippingDistance = clippingDistance
***REMOVED***
***REMOVED******REMOVED***.observingInterfaceOrientation($interfaceOrientation)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Visualizes a new node added to the scene as an AR Plane.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - renderer: The renderer for the scene.
***REMOVED******REMOVED***/   - node: The node to be added to the scene.
***REMOVED******REMOVED***/   - anchor: The anchor position of the node.
***REMOVED***private func addPlane(renderer: SCNSceneRenderer, node: SCNNode, anchor: ARAnchor) {
***REMOVED******REMOVED***guard !initialTransformationIsSet,
***REMOVED******REMOVED******REMOVED***  let planeAnchor = anchor as? ARPlaneAnchor,
***REMOVED******REMOVED******REMOVED***  let device = renderer.device,
***REMOVED******REMOVED******REMOVED***  let planeGeometry = ARSCNPlaneGeometry(device: device)
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Disable coaching overlay when a plane node is found.
***REMOVED******REMOVED***coachingOverlayIsActive = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***planeGeometry.update(from: planeAnchor.geometry)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Add SCNMaterial to plane geometry.
***REMOVED******REMOVED***let material = SCNMaterial()
***REMOVED******REMOVED***material.isDoubleSided = true
***REMOVED******REMOVED***material.diffuse.contents = UIColor.white.withAlphaComponent(0.65)
***REMOVED******REMOVED***planeGeometry.materials = [material]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create a SCNNode from plane geometry.
***REMOVED******REMOVED***let planeNode = SCNNode(geometry: planeGeometry)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Add the visualization to the ARKit-managed node so that it tracks
***REMOVED******REMOVED******REMOVED*** changes in the plane anchor as plane estimation continues.
***REMOVED******REMOVED***node.addChildNode(planeNode)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set help text when plane is visualized.
***REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED***helpText = .planeFound
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Visualizes a node updated in the scene as an AR Plane.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - node: The node to be updated in the scene.
***REMOVED******REMOVED***/   - anchor: The anchor position of the node.
***REMOVED***private func updatePlane(with node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED***if initialTransformationIsSet {
***REMOVED******REMOVED******REMOVED***node.removeFromParentNode()
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let planeAnchor = anchor as? ARPlaneAnchor,
***REMOVED******REMOVED******REMOVED***  let planeNode = node.childNodes.first,
***REMOVED******REMOVED******REMOVED***  let planeGeometry = planeNode.geometry as? ARSCNPlaneGeometry
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Update extent visualization to the anchor's new geometry.
***REMOVED******REMOVED***planeGeometry.update(from: planeAnchor.geometry)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set help text when plane visualization is updated.
***REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED***helpText = .planeFound
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the visibility of the coaching overlay view for the AR experince.
***REMOVED******REMOVED***/ - Parameter hidden: A Boolean value that indicates whether to hide the
***REMOVED******REMOVED***/  coaching overlay view.
***REMOVED***public func coachingOverlayHidden(_ hidden: Bool) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.coachingOverlayIsHidden = hidden
***REMOVED******REMOVED***return view
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
***REMOVED******REMOVED******REMOVED*** Use the `raycast` method to get the matrix of `screenPoint`.
***REMOVED******REMOVED***guard let matrix = arViewProxy.raycast(from: screenPoint, allowing: .existingPlaneGeometry) else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set the `initialTransformation` as the TransformationMatrix.identity - raycast matrix.
***REMOVED******REMOVED***let initialTransformation = TransformationMatrix.identity.subtracting(matrix)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return initialTransformation
***REMOVED***
***REMOVED***

private extension String {
***REMOVED***static var planeFound: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "Tap a surface to place the scene",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** An instruction to the user to tap on a horizontal surface to
***REMOVED******REMOVED******REMOVED******REMOVED*** place an ArcGIS Scene.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
