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
import RealityKit

public enum RealityGeoViewTrackingMode {
***REMOVED***case ignore
***REMOVED***case initial
***REMOVED***case continuous
***REMOVED***

public struct RealityGeoView: UIViewControllerRepresentable {
***REMOVED***private let scene: ArcGIS.Scene
***REMOVED***private let cameraController: TransformationMatrixCameraController
***REMOVED***private let trackingMode: RealityGeoViewTrackingMode
***REMOVED***private let renderVideoFeed: Bool
***REMOVED***private let graphicsOverlays: [GraphicsOverlay]
***REMOVED***private let analysisOverlays: [AnalysisOverlay]
***REMOVED***
***REMOVED***public func makeUIViewController(context: Context) -> ViewController {
***REMOVED******REMOVED***let viewController = ViewController(
***REMOVED******REMOVED******REMOVED***scene: scene,
***REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED***graphicsOverlays: graphicsOverlays,
***REMOVED******REMOVED******REMOVED***analysisOverlays: analysisOverlays,
***REMOVED******REMOVED******REMOVED***trackingMode: trackingMode,
***REMOVED******REMOVED******REMOVED***renderVideoFeed: renderVideoFeed
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewController.arView.delegate = context.coordinator
***REMOVED******REMOVED***setProperties(for: viewController, with: context)
***REMOVED******REMOVED***return viewController
***REMOVED***
***REMOVED***
***REMOVED***public func updateUIViewController(_ uiViewController: ViewController, context: Context) {
***REMOVED******REMOVED***setProperties(for: uiViewController, with: context)
***REMOVED***
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***scene: ArcGIS.Scene = ArcGIS.Scene(),
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController = TransformationMatrixCameraController(),
***REMOVED******REMOVED***graphicsOverlays: [GraphicsOverlay] = [],
***REMOVED******REMOVED***analysisOverlays: [AnalysisOverlay] = [],
***REMOVED******REMOVED***trackingMode: RealityGeoViewTrackingMode = .initial,
***REMOVED******REMOVED***renderVideoFeed: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***self.scene = scene
***REMOVED******REMOVED***self.cameraController = cameraController
***REMOVED******REMOVED***self.graphicsOverlays = graphicsOverlays
***REMOVED******REMOVED***self.analysisOverlays = analysisOverlays
***REMOVED******REMOVED***self.trackingMode = trackingMode
***REMOVED******REMOVED***self.renderVideoFeed = renderVideoFeed
***REMOVED***
***REMOVED***
***REMOVED***private func setProperties(for viewController: ViewController, with context: Context) {
***REMOVED******REMOVED***context.coordinator.arView = viewController.arView
***REMOVED******REMOVED***context.coordinator.isTracking = viewController.isTracking
***REMOVED******REMOVED***context.coordinator.lastGoodDeviceOrientation = viewController.lastGoodDeviceOrientation
***REMOVED******REMOVED***context.coordinator.initialTransformation = viewController.initialTransformation
***REMOVED******REMOVED***context.coordinator.sceneViewController = viewController.sceneViewController
***REMOVED***
***REMOVED***
***REMOVED***public func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator()
***REMOVED***
***REMOVED***

extension RealityGeoView {
***REMOVED***public class Coordinator: NSObject, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionObserver {
***REMOVED******REMOVED******REMOVED***/ We implement `ARSCNViewDelegate` methods, but will use `delegate` to forward them to clients.
***REMOVED******REMOVED***weak var delegate: ARSCNViewDelegate?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var arView: ARSCNView?
***REMOVED******REMOVED***var isTracking: Bool = false
***REMOVED******REMOVED***var sceneViewController: ArcGISSceneViewController?
***REMOVED******REMOVED***var lastGoodDeviceOrientation: UIDeviceOrientation?
***REMOVED******REMOVED***var initialTransformation: TransformationMatrix?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** ARSCNViewDelegate methods
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, didAdd: node, for: anchor)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, willUpdate: node, for: anchor)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, didUpdate: node, for: anchor)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, didRemove: node, for: anchor)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** ARSessionObserver methods
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func session(_ session: ARSession, didFailWithError error: Error) {
***REMOVED******REMOVED******REMOVED***delegate?.session?(session, didFailWithError: error)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
***REMOVED******REMOVED******REMOVED***delegate?.session?(session, cameraDidChangeTrackingState: camera)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func sessionWasInterrupted(_ session: ARSession) {
***REMOVED******REMOVED******REMOVED***delegate?.sessionWasInterrupted?(session)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func sessionInterruptionEnded(_ session: ARSession) {
***REMOVED******REMOVED******REMOVED***delegate?.sessionWasInterrupted?(session)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
***REMOVED******REMOVED******REMOVED***return delegate?.sessionShouldAttemptRelocalization?(session) ?? false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
***REMOVED******REMOVED******REMOVED***delegate?.session?(session, didOutputAudioSampleBuffer: audioSampleBuffer)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** SCNSceneRendererDelegate methods
***REMOVED******REMOVED***
***REMOVED******REMOVED***public  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, updateAtTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, didApplyConstraintsAtTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, didSimulatePhysicsAtTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, didApplyConstraintsAtTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED******REMOVED*** If we aren't tracking yet, return.
***REMOVED******REMOVED******REMOVED******REMOVED***  guard isTracking else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard
***REMOVED******REMOVED******REMOVED******REMOVED***let arView,
***REMOVED******REMOVED******REMOVED******REMOVED***let initialTransformation,
***REMOVED******REMOVED******REMOVED******REMOVED***let sceneViewController
***REMOVED******REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard lastGoodDeviceOrientation != nil else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Get transform from SCNView.pointOfView.
***REMOVED******REMOVED******REMOVED***guard let transform = arView.pointOfView?.transform else { return ***REMOVED***
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
***REMOVED******REMOVED******REMOVED***let cameraController = sceneViewController.cameraController as! TransformationMatrixCameraController
***REMOVED******REMOVED******REMOVED***cameraController.transformationMatrix = initialTransformation.adding(transformationMatrix)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Set FOV on camera.
***REMOVED******REMOVED******REMOVED***if let camera = arView.session.currentFrame?.camera {
***REMOVED******REMOVED******REMOVED******REMOVED***let intrinsics = camera.intrinsics
***REMOVED******REMOVED******REMOVED******REMOVED***let imageResolution = camera.imageResolution
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Get the device orientation, but don't allow non-landscape/portrait values.
***REMOVED******REMOVED******REMOVED******REMOVED***let deviceOrientation = UIDevice.current.orientation
***REMOVED******REMOVED******REMOVED******REMOVED***if deviceOrientation.isValidInterfaceOrientation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lastGoodDeviceOrientation = deviceOrientation
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***sceneViewController.setFieldOfViewFromLensIntrinsics(
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
***REMOVED******REMOVED******REMOVED***sceneViewController.draw()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Call our arSCNViewDelegate method.
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, willRenderScene: scene, atTime: time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***delegate?.renderer?(renderer, didRenderScene: scene, atTime: time)
***REMOVED***
***REMOVED***
***REMOVED***

extension RealityGeoView {
***REMOVED***public class ViewController: UIViewController {
***REMOVED******REMOVED******REMOVED***/ The view used to display the `ARKit` camera image and 3D `SceneKit` content.
***REMOVED******REMOVED***let arView = ARSCNView(frame: .zero)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Denotes whether tracking location and angles has started.
***REMOVED******REMOVED******REMOVED***/ - Since: 200.3
***REMOVED******REMOVED***private(set) var isTracking: Bool = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Whether `ARKit` is supported on this device.
***REMOVED******REMOVED***private let deviceSupportsARKit: Bool = ARWorldTrackingConfiguration.isSupported
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The world tracking information used by `ARKit`.
***REMOVED******REMOVED***var arConfiguration: ARConfiguration {
***REMOVED******REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we're already tracking, reset tracking to use the new configuration.
***REMOVED******REMOVED******REMOVED******REMOVED***if isTracking, deviceSupportsARKit {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arView.session.run(arConfiguration, options: .resetTracking)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The last portrait or landscape orientation value.
***REMOVED******REMOVED***var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The tracking mode controlling how the locations generated from the location data source are used during AR tracking.
***REMOVED******REMOVED***private var trackingMode: RealityGeoViewTrackingMode = .ignore
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The initial transformation used for a table top experience.  Defaults to the Identity Matrix.
***REMOVED******REMOVED***var initialTransformation: TransformationMatrix = .identity
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The data source used to get device location.  Used either in conjuction with ARKit data or when ARKit is not present or not being used.
***REMOVED******REMOVED***var locationDataSource: LocationDataSource? {
***REMOVED******REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** locationDataSource?.locationChangeHandlerDelegate = self
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The translation factor used to support a table top AR experience.
***REMOVED******REMOVED***var translationFactor: Double {
***REMOVED******REMOVED******REMOVED***get { cameraController.translationFactor ***REMOVED***
***REMOVED******REMOVED******REMOVED***set { cameraController.translationFactor = newValue ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Determines the clipping distance around the originCamera. The units are meters; the default is `nil`.
***REMOVED******REMOVED******REMOVED***/ When the value is set to `nil`, there is no enforced clipping distance and therefore no limiting of displayed data.
***REMOVED******REMOVED******REMOVED***/ Setting the value to 10.0 will only render data 10 meters around the origin camera.
***REMOVED******REMOVED***var clippingDistance: Double? {
***REMOVED******REMOVED******REMOVED***get { cameraController.clippingDistance ***REMOVED***
***REMOVED******REMOVED******REMOVED***set { cameraController.clippingDistance = newValue ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The viewpoint camera used to set the initial view of the sceneView instead of the device's GPS location via the location data source.  You can use Key-Value Observing to track changes to the origin camera.
***REMOVED******REMOVED***var originCamera: Camera {
***REMOVED******REMOVED******REMOVED***get { cameraController.originCamera ***REMOVED***
***REMOVED******REMOVED******REMOVED***set { cameraController.originCamera = newValue ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The `TransformationMatrixCameraController` used to control the Scene.
***REMOVED******REMOVED***var cameraController: TransformationMatrixCameraController {
***REMOVED******REMOVED******REMOVED***sceneViewController.cameraController as! TransformationMatrixCameraController
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var sceneViewController: ArcGISSceneViewController
***REMOVED******REMOVED***
***REMOVED******REMOVED***public init(
***REMOVED******REMOVED******REMOVED***scene: ArcGIS.Scene,
***REMOVED******REMOVED******REMOVED***cameraController: TransformationMatrixCameraController,
***REMOVED******REMOVED******REMOVED***graphicsOverlays: [GraphicsOverlay],
***REMOVED******REMOVED******REMOVED***analysisOverlays: [AnalysisOverlay],
***REMOVED******REMOVED******REMOVED***trackingMode: RealityGeoViewTrackingMode,
***REMOVED******REMOVED******REMOVED***renderVideoFeed: Bool
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***sceneViewController = ArcGISSceneViewController(
***REMOVED******REMOVED******REMOVED******REMOVED***scene: scene,
***REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: graphicsOverlays,
***REMOVED******REMOVED******REMOVED******REMOVED***analysisOverlays: analysisOverlays,
***REMOVED******REMOVED******REMOVED******REMOVED***spaceEffect: .transparent,
***REMOVED******REMOVED******REMOVED******REMOVED***atmosphereEffect: .off,
***REMOVED******REMOVED******REMOVED******REMOVED***isAttributionBarHidden: true,
***REMOVED******REMOVED******REMOVED******REMOVED***viewDrawingMode: .manual
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let config = ARWorldTrackingConfiguration()
***REMOVED******REMOVED******REMOVED***config.worldAlignment = .gravityAndHeading
***REMOVED******REMOVED******REMOVED***config.planeDetection = [.horizontal]
***REMOVED******REMOVED******REMOVED***arConfiguration = config
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.trackingMode = trackingMode
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***super.init(nibName: nil, bundle: nil)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if !deviceSupportsARKit || !renderVideoFeed {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** User is not using ARKit, or they don't want to see video,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** set the arSCNView.alpha to 0.0 so it doesn't display.
***REMOVED******REMOVED******REMOVED******REMOVED***arView.alpha = 0
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
***REMOVED******REMOVED******REMOVED***fatalError("init(nibName:bundle:) has not been implemented")
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public required init?(coder: NSCoder) {
***REMOVED******REMOVED******REMOVED***fatalError("init(coder:) has not been implemented")
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public override func viewDidLoad() {
***REMOVED******REMOVED******REMOVED***super.viewDidLoad()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if deviceSupportsARKit {
***REMOVED******REMOVED******REMOVED******REMOVED***view.addSubview(arView)
***REMOVED******REMOVED******REMOVED******REMOVED***arView.frame = view.bounds
***REMOVED******REMOVED******REMOVED******REMOVED***arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Add scene view controller
***REMOVED******REMOVED******REMOVED***addChild(sceneViewController)
***REMOVED******REMOVED******REMOVED***sceneViewController.view.frame = self.view.bounds
***REMOVED******REMOVED******REMOVED***view.addSubview(sceneViewController.view)
***REMOVED******REMOVED******REMOVED***sceneViewController.view.backgroundColor = .clear
***REMOVED******REMOVED******REMOVED***sceneViewController.view.frame = view.bounds
***REMOVED******REMOVED******REMOVED***sceneViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
***REMOVED******REMOVED******REMOVED***sceneViewController.didMove(toParent: self)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Task.detached {
***REMOVED******REMOVED******REMOVED******REMOVED***try await self.startTracking(withMode: self.trackingMode)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public override func viewDidDisappear(_ animated: Bool) {
***REMOVED******REMOVED******REMOVED***super.viewDidDisappear(animated)
***REMOVED******REMOVED******REMOVED***Task.detached {
***REMOVED******REMOVED******REMOVED******REMOVED***await self.stopTracking()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Operations that happen after device tracking has started.
***REMOVED******REMOVED***@MainActor
***REMOVED******REMOVED***private func finalizeStart() {
***REMOVED******REMOVED******REMOVED******REMOVED*** Run the ARSession.
***REMOVED******REMOVED******REMOVED***if deviceSupportsARKit {
***REMOVED******REMOVED******REMOVED******REMOVED***arView.session.run(arConfiguration, options: .resetTracking)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isTracking = true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Starts device tracking.
***REMOVED******REMOVED***func startTracking(withMode mode: RealityGeoViewTrackingMode) async throws {
***REMOVED******REMOVED******REMOVED******REMOVED*** We have a location data source that needs to be started.
***REMOVED******REMOVED******REMOVED***self.trackingMode = mode
***REMOVED******REMOVED******REMOVED***if mode != .ignore,
***REMOVED******REMOVED******REMOVED***   let locationDataSource = self.locationDataSource {
***REMOVED******REMOVED******REMOVED******REMOVED***Task.detached { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await locationDataSource.start()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.finalizeStart()
***REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***throw error
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** We're either ignoring the data source or there is no data source so continue with defaults.
***REMOVED******REMOVED******REMOVED******REMOVED***finalizeStart()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Suspends device tracking.
***REMOVED******REMOVED***func stopTracking() async {
***REMOVED******REMOVED******REMOVED***Task.detached { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED***self.arView.session.pause()
***REMOVED******REMOVED******REMOVED******REMOVED***await self.locationDataSource?.stop()
***REMOVED******REMOVED******REMOVED******REMOVED***self.isTracking = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
