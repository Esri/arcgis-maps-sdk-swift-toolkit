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

***REMOVED***
import ARKit
***REMOVED***

public enum ARLocationTrackingMode {
***REMOVED***case ignore
***REMOVED***case initial
***REMOVED***case continuous
***REMOVED***

public struct ARView: UIViewControllerRepresentable {
***REMOVED***
***REMOVED***private var scene: ArcGIS.Scene = Scene()
***REMOVED***
***REMOVED***private var renderVideoFeed: Bool
***REMOVED***
***REMOVED***private var cameraController = TransformationMatrixCameraController()
***REMOVED***
***REMOVED***private var locationTrackingMode: ARLocationTrackingMode
***REMOVED***
***REMOVED***public func makeUIViewController(context: Context) -> ARViewController {
***REMOVED******REMOVED***let viewController = ARViewController(
***REMOVED******REMOVED******REMOVED***scene: scene,
***REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED***renderVideoFeed: renderVideoFeed
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewController.arSCNView.delegate = context.coordinator
***REMOVED******REMOVED***setProperties(for: viewController, with: context)
***REMOVED******REMOVED***return viewController
***REMOVED***
***REMOVED***
***REMOVED***public func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
***REMOVED******REMOVED***setProperties(for: uiViewController, with: context)
***REMOVED***
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***scene: ArcGIS.Scene = ArcGIS.Scene(),
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController = TransformationMatrixCameraController(),
***REMOVED******REMOVED***locationTrackingMode: ARLocationTrackingMode = .ignore,
***REMOVED******REMOVED***renderVideoFeed: Bool
***REMOVED***) {
***REMOVED******REMOVED***self.scene = scene
***REMOVED******REMOVED***self.cameraController = cameraController
***REMOVED******REMOVED***self.locationTrackingMode = locationTrackingMode
***REMOVED******REMOVED***self.renderVideoFeed = renderVideoFeed
***REMOVED***
***REMOVED***
***REMOVED***private func setProperties(for viewController: ARViewController, with context: Context) {
***REMOVED******REMOVED***context.coordinator.arSCNView = viewController.arSCNView
***REMOVED******REMOVED***context.coordinator.isTracking = viewController.isTracking
***REMOVED******REMOVED***context.coordinator.cameraController = viewController.cameraController
***REMOVED******REMOVED***context.coordinator.lastGoodDeviceOrientation = viewController.lastGoodDeviceOrientation
***REMOVED******REMOVED***context.coordinator.initialTransformation = viewController.initialTransformation
***REMOVED******REMOVED***context.coordinator.sceneViewController = viewController.sceneViewController
***REMOVED***
***REMOVED***
***REMOVED***public func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator()
***REMOVED***
***REMOVED***
***REMOVED***public class Coordinator: NSObject, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionObserver {
***REMOVED******REMOVED******REMOVED***/ We implement `ARSCNViewDelegate` methods, but will use `arSCNViewDelegate` to forward them to clients.
***REMOVED******REMOVED******REMOVED***/ - Since: 200.3
***REMOVED******REMOVED***public weak var arSCNViewDelegate: ARSCNViewDelegate?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var arSCNView: ARSCNView?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var isTracking: Bool = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***var sceneViewProxy: SceneViewProxy?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var sceneViewController: ArcGISSceneViewController?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var cameraController: TransformationMatrixCameraController?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var lastGoodDeviceOrientation: UIDeviceOrientation?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var initialTransformation: TransformationMatrix?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** ARSCNViewDelegate methods
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, didAdd: node, for: anchor)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, willUpdate: node, for: anchor)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, didUpdate: node, for: anchor)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, didRemove: node, for: anchor)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** ARSessionObserver methods
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func session(_ session: ARSession, didFailWithError error: Error) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.session?(session, didFailWithError: error)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.session?(session, cameraDidChangeTrackingState: camera)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func sessionWasInterrupted(_ session: ARSession) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.sessionWasInterrupted?(session)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func sessionInterruptionEnded(_ session: ARSession) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.sessionWasInterrupted?(session)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
***REMOVED******REMOVED******REMOVED***return arSCNViewDelegate?.sessionShouldAttemptRelocalization?(session) ?? false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.session?(session, didOutputAudioSampleBuffer: audioSampleBuffer)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** SCNSceneRendererDelegate methods
***REMOVED******REMOVED***
***REMOVED******REMOVED***public  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, updateAtTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, didApplyConstraintsAtTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, didSimulatePhysicsAtTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, didApplyConstraintsAtTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***@MainActor
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED******REMOVED*** If we aren't tracking yet, return.
***REMOVED******REMOVED******REMOVED******REMOVED***  guard isTracking else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard
***REMOVED******REMOVED******REMOVED******REMOVED***let arSCNView,
***REMOVED******REMOVED******REMOVED******REMOVED***let cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED***let initialTransformation,
***REMOVED******REMOVED******REMOVED******REMOVED***let sceneViewController,
***REMOVED******REMOVED******REMOVED******REMOVED***let sceneViewProxy = sceneViewController.sceneViewProxy
***REMOVED******REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard lastGoodDeviceOrientation != nil else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Get transform from SCNView.pointOfView.
***REMOVED******REMOVED******REMOVED***guard let transform = arSCNView.pointOfView?.transform else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***let cameraTransform = simd_double4x4(transform)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let cameraQuat = simd_quatd(cameraTransform)
***REMOVED******REMOVED******REMOVED***let transformationMatrix = TransformationMatrix.normalized(
***REMOVED******REMOVED******REMOVED******REMOVED***quaternionX: cameraQuat.vector.x,
***REMOVED******REMOVED******REMOVED******REMOVED***quaternionY: cameraQuat.vector.y,
***REMOVED******REMOVED******REMOVED******REMOVED***quaternionZ: cameraQuat.vector.z,
***REMOVED******REMOVED******REMOVED******REMOVED***quaternionW: cameraQuat.vector.w,
***REMOVED******REMOVED******REMOVED******REMOVED***translationX: cameraTransform.columns.3.x,
***REMOVED******REMOVED******REMOVED******REMOVED***translationY: cameraTransform.columns.3.y,
***REMOVED******REMOVED******REMOVED******REMOVED***translationZ: cameraTransform.columns.3.z
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Set the matrix on the camera controller.
***REMOVED******REMOVED******REMOVED***cameraController.transformationMatrix = initialTransformation.adding(transformationMatrix)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Set FOV on camera.
***REMOVED******REMOVED******REMOVED***if let camera = arSCNView.session.currentFrame?.camera {
***REMOVED******REMOVED******REMOVED******REMOVED***let intrinsics = camera.intrinsics
***REMOVED******REMOVED******REMOVED******REMOVED***let imageResolution = camera.imageResolution
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Get the device orientation, but don't allow non-landscape/portrait values.
***REMOVED******REMOVED******REMOVED******REMOVED***let deviceOrientation = UIDevice.current.orientation
***REMOVED******REMOVED******REMOVED******REMOVED***if deviceOrientation.isValidInterfaceOrientation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lastGoodDeviceOrientation = deviceOrientation
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.setFieldOfViewFromLensIntrinsics(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***xFocalLength: intrinsics[0][0],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***yFocalLength: intrinsics[1][1],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***xPrincipal: intrinsics[2][0],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***yPrincipal: intrinsics[2][1],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***xImageSize: Float(imageResolution.width),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***yImageSize: Float(imageResolution.height),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***deviceOrientation: lastGoodDeviceOrientation!
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Render the Scene with the new transformation.
***REMOVED******REMOVED******REMOVED***sceneViewProxy.manualDraw()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Call our arSCNViewDelegate method.
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, willRenderScene: scene, atTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***arSCNViewDelegate?.renderer?(renderer, didRenderScene: scene, atTime: time)
***REMOVED***
***REMOVED***
***REMOVED***

public class ARViewController: UIViewController {
***REMOVED******REMOVED***/ The view used to display the `ARKit` camera image and 3D `SceneKit` content.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***let arSCNView = ARSCNView(frame: .zero)
***REMOVED***
***REMOVED******REMOVED***/ Denotes whether tracking location and angles has started.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public private(set) var isTracking: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ Denotes whether ARKit is being used to track location and angles.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public private(set) var isUsingARKit: Bool = true
***REMOVED***
***REMOVED******REMOVED***/ Whether `ARKit` is supported on this device.
***REMOVED***private let deviceSupportsARKit: Bool = {
***REMOVED******REMOVED***return ARWorldTrackingConfiguration.isSupported
***REMOVED***()
***REMOVED***
***REMOVED******REMOVED***/ The world tracking information used by `ARKit`.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public var arConfiguration: ARConfiguration = {
***REMOVED******REMOVED***let configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED******REMOVED***configuration.planeDetection = [.horizontal]
***REMOVED******REMOVED***return configuration
***REMOVED***() {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED******REMOVED*** If we're already tracking, reset tracking to use the new configuration.
***REMOVED******REMOVED******REMOVED***if isTracking, isUsingARKit {
***REMOVED******REMOVED******REMOVED******REMOVED***arSCNView.session.run(arConfiguration, options: .resetTracking)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The last portrait or landscape orientation value.
***REMOVED***var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
***REMOVED***
***REMOVED******REMOVED***/ The tracking mode controlling how the locations generated from the location data source are used during AR tracking.
***REMOVED***private var locationTrackingMode: ARLocationTrackingMode = .ignore
***REMOVED***
***REMOVED******REMOVED***/ The initial transformation used for a table top experience.  Defaults to the Identity Matrix.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public var initialTransformation: TransformationMatrix = .identity
***REMOVED***
***REMOVED******REMOVED***/ The data source used to get device location.  Used either in conjuction with ARKit data or when ARKit is not present or not being used.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public var locationDataSource: LocationDataSource? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED******REMOVED*** locationDataSource?.locationChangeHandlerDelegate = self
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The translation factor used to support a table top AR experience.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public dynamic var translationFactor: Double {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return cameraController.translationFactor
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***cameraController.translationFactor = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines the clipping distance around the originCamera. The units are meters; the default is 0.0. When the value is set to 0.0 there is no enforced clipping distance.
***REMOVED******REMOVED***/ Setting the value to 10.0 will only render data 10 meters around the originCamera.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public var clippingDistance: Double {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return cameraController.clippingDistance ?? 0.0
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***cameraController.clippingDistance = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The viewpoint camera used to set the initial view of the sceneView instead of the device's GPS location via the location data source.  You can use Key-Value Observing to track changes to the origin camera.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public dynamic var originCamera: Camera {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return cameraController.originCamera
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***cameraController.originCamera = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Private properties
***REMOVED***
***REMOVED******REMOVED***/ The `TransformationMatrixCameraController` used to control the Scene.
***REMOVED***var cameraController = TransformationMatrixCameraController()
***REMOVED***
***REMOVED******REMOVED***/ Operations that happen after device tracking has started.
***REMOVED***@MainActor
***REMOVED***private func finalizeStart() {
***REMOVED******REMOVED******REMOVED*** Run the ARSession.
***REMOVED******REMOVED***if self.isUsingARKit {
***REMOVED******REMOVED******REMOVED***self.arSCNView.session.run(self.arConfiguration, options: .resetTracking)
***REMOVED***
***REMOVED******REMOVED***self.isTracking = true
***REMOVED***
***REMOVED***
***REMOVED***var sceneViewController: ArcGISSceneViewController
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***scene: ArcGIS.Scene,
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController,
***REMOVED******REMOVED***graphicsOverlays: [GraphicsOverlay] = [],
***REMOVED******REMOVED***analysisOverlays: [AnalysisOverlay] = [],
***REMOVED******REMOVED***renderVideoFeed: Bool
***REMOVED***) {
***REMOVED******REMOVED***sceneViewController = ArcGISSceneViewController(
***REMOVED******REMOVED******REMOVED***scene: scene,
***REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED***graphicsOverlays: graphicsOverlays,
***REMOVED******REMOVED******REMOVED***analysisOverlays: analysisOverlays,
***REMOVED******REMOVED******REMOVED***spaceEffect: .transparent,
***REMOVED******REMOVED******REMOVED***atmosphereEffect: .off,
***REMOVED******REMOVED******REMOVED***isAttributionBarHidden: true,
***REMOVED******REMOVED******REMOVED***viewDrawingMode: .manual
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***super.init(nibName: nil, bundle: nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if !isUsingARKit || !renderVideoFeed {
***REMOVED******REMOVED******REMOVED******REMOVED*** User is not using ARKit, or they don't want to see video,
***REMOVED******REMOVED******REMOVED******REMOVED*** set the arSCNView.alpha to 0.0 so it doesn't display.
***REMOVED******REMOVED******REMOVED***arSCNView.alpha = 0
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
***REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***public required init?(coder: NSCoder) {
***REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***public override func viewDidLoad() {
***REMOVED******REMOVED***super.viewDidLoad()
***REMOVED******REMOVED***
***REMOVED******REMOVED***if deviceSupportsARKit {
***REMOVED******REMOVED******REMOVED***view.addSubview(arSCNView)
***REMOVED******REMOVED******REMOVED***arSCNView.frame = view.bounds
***REMOVED******REMOVED******REMOVED***arSCNView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Use ARKit if device supports it.
***REMOVED******REMOVED***isUsingARKit = deviceSupportsARKit
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Add scene view controller
***REMOVED******REMOVED***addChild(sceneViewController)
***REMOVED******REMOVED***sceneViewController.view.frame = self.view.bounds
***REMOVED******REMOVED***sceneViewController.view.backgroundColor = .clear
***REMOVED******REMOVED***sceneViewController.view.frame = view.bounds
***REMOVED******REMOVED***sceneViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
***REMOVED******REMOVED***sceneViewController.didMove(toParent: self)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***try await self.startTracking(self.locationTrackingMode)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public override func viewDidDisappear(_ animated: Bool) {
***REMOVED******REMOVED***super.viewDidDisappear(animated)
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***await stopTracking()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Starts device tracking.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameter completion: The completion handler called when start tracking completes.  If tracking starts successfully, the `error` property will be nil; if tracking fails to start, the error will be non-nil and contain the reason for failure.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public func startTracking(_ locationTrackingMode: ARLocationTrackingMode) async throws {
***REMOVED******REMOVED******REMOVED*** We have a location data source that needs to be started.
***REMOVED******REMOVED***self.locationTrackingMode = locationTrackingMode
***REMOVED******REMOVED***if locationTrackingMode != .ignore,
***REMOVED******REMOVED***   let locationDataSource = self.locationDataSource {
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await locationDataSource.start()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.finalizeStart()
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***throw error
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED*** We're either ignoring the data source or there is no data source so continue with defaults.
***REMOVED******REMOVED******REMOVED***finalizeStart()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Suspends device tracking.
***REMOVED******REMOVED***/ - Since: 200.3
***REMOVED***public func stopTracking() async {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***arSCNView.session.pause()
***REMOVED******REMOVED******REMOVED***await locationDataSource?.stop()
***REMOVED******REMOVED******REMOVED***isTracking = false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
