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

import Foundation
import ARKit
***REMOVED***
***REMOVED***

struct ARSwiftUIView {
***REMOVED***private(set) var alpha: CGFloat = 1.0
***REMOVED***private(set) var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
***REMOVED***private(set) var onCameraTrackingStateChangeAction: ((ARSession, ARCamera) -> Void)?
***REMOVED***private(set) var onGeoTrackingStatusChangeAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
***REMOVED***private(set) var onProxyAvailableAction: ((ARSwiftUIView.Proxy) -> Void)?
***REMOVED***
***REMOVED***init() {
***REMOVED***
***REMOVED***
***REMOVED***func alpha(_ alpha: CGFloat) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.alpha = alpha
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED***func onRender(
***REMOVED******REMOVED***perform action: @escaping (SCNSceneRenderer, SCNScene, TimeInterval) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onRenderAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED***func onCameraTrackingStateChange(
***REMOVED******REMOVED***perform action: @escaping (ARSession, ARCamera) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onCameraTrackingStateChangeAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED***func onGeoTrackingStatusChange(
***REMOVED******REMOVED***perform action: @escaping (ARSession, ARGeoTrackingStatus) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onGeoTrackingStatusChangeAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED***func onProxyAvailable(
***REMOVED******REMOVED***perform action: @escaping (ARSwiftUIView.Proxy) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onProxyAvailableAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***

extension ARSwiftUIView: UIViewRepresentable {
***REMOVED***func makeUIView(context: Context) -> ARSCNView {
***REMOVED******REMOVED***let arView = ARSCNView()
***REMOVED******REMOVED***arView.delegate = context.coordinator
***REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED***onProxyAvailableAction?(Proxy(arView: arView))
***REMOVED***
***REMOVED******REMOVED***return arView
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiView: ARSCNView, context: Context) {
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(arSwiftUIView: self)
***REMOVED***
***REMOVED***

extension ARSwiftUIView {
***REMOVED***class Coordinator: NSObject, ARSCNViewDelegate {
***REMOVED******REMOVED***private let view: ARSwiftUIView
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(arSwiftUIView: ARSwiftUIView) {
***REMOVED******REMOVED******REMOVED***self.view = arSwiftUIView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***view.onRenderAction?(renderer, scene, time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
***REMOVED******REMOVED******REMOVED***view.onCameraTrackingStateChangeAction?(session, camera)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
***REMOVED******REMOVED******REMOVED***view.onGeoTrackingStatusChangeAction?(session, geoTrackingStatus)
***REMOVED***
***REMOVED***
***REMOVED***

extension ARSwiftUIView {
***REMOVED***class Proxy {
***REMOVED******REMOVED***private let arView: ARSCNView
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(arView: ARSCNView) {
***REMOVED******REMOVED******REMOVED***self.arView = arView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var session: ARSession {
***REMOVED******REMOVED******REMOVED***arView.session
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var pointOfView: SCNNode? {
***REMOVED******REMOVED******REMOVED***arView.pointOfView
***REMOVED***
***REMOVED***
***REMOVED***

public struct ARGeoView3: View {
***REMOVED***private let scene: ArcGIS.Scene
***REMOVED***private let configuration: ARWorldTrackingConfiguration
***REMOVED***private let cameraController: TransformationMatrixCameraController
***REMOVED***
***REMOVED******REMOVED***/ The last portrait or landscape orientation value.
***REMOVED***@State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
***REMOVED***
***REMOVED***@State private var arViewProxy: ARSwiftUIView.Proxy?
***REMOVED***@State private var sceneViewProxy: SceneViewProxy?
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***scene: ArcGIS.Scene,
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController
***REMOVED***) {
***REMOVED******REMOVED***self.cameraController = cameraController
***REMOVED******REMOVED***self.scene = scene
***REMOVED******REMOVED***
***REMOVED******REMOVED***configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED******REMOVED***configuration.planeDetection = [.horizontal]
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***ARSwiftUIView()
***REMOVED******REMOVED******REMOVED******REMOVED***.alpha(0)
***REMOVED******REMOVED******REMOVED******REMOVED***.onProxyAvailable { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.arViewProxy = proxy
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proxy.session.run(configuration)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onRender { _, _, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let arViewProxy, let sceneViewProxy {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***render(arViewProxy: arViewProxy, sceneViewProxy: sceneViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***SceneViewReader { sceneViewProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***SceneView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scene: scene,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED******REMOVED***.viewDrawingMode(.manual)
***REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.sceneViewProxy = sceneViewProxy
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension ARGeoView3 {
***REMOVED***func render(arViewProxy: ARSwiftUIView.Proxy, sceneViewProxy: SceneViewProxy) {
***REMOVED******REMOVED******REMOVED*** Get transform from SCNView.pointOfView.
***REMOVED******REMOVED***guard let transform = arViewProxy.pointOfView?.transform else { return ***REMOVED***
***REMOVED******REMOVED***let cameraTransform = simd_double4x4(transform)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraQuat = simd_quatd(cameraTransform)
***REMOVED******REMOVED***let transformationMatrix = TransformationMatrix.normalized(
***REMOVED******REMOVED******REMOVED***quaternionX: cameraQuat.vector.x,
***REMOVED******REMOVED******REMOVED***quaternionY: cameraQuat.vector.y,
***REMOVED******REMOVED******REMOVED***quaternionZ: cameraQuat.vector.z,
***REMOVED******REMOVED******REMOVED***quaternionW: cameraQuat.vector.w,
***REMOVED******REMOVED******REMOVED***translationX: cameraTransform.columns.3.x,
***REMOVED******REMOVED******REMOVED***translationY: cameraTransform.columns.3.y,
***REMOVED******REMOVED******REMOVED***translationZ: cameraTransform.columns.3.z
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set the matrix on the camera controller.
***REMOVED******REMOVED***cameraController.transformationMatrix = .identity.adding(transformationMatrix)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set FOV on camera.
***REMOVED******REMOVED***if let camera = arViewProxy.session.currentFrame?.camera {
***REMOVED******REMOVED******REMOVED***let intrinsics = camera.intrinsics
***REMOVED******REMOVED******REMOVED***let imageResolution = camera.imageResolution
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Get the device orientation, but don't allow non-landscape/portrait values.
***REMOVED******REMOVED******REMOVED***let deviceOrientation = UIDevice.current.orientation
***REMOVED******REMOVED******REMOVED***if deviceOrientation.isValidInterfaceOrientation {
***REMOVED******REMOVED******REMOVED******REMOVED***lastGoodDeviceOrientation = deviceOrientation
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***sceneViewProxy.setFieldOfViewFromLensIntrinsics(
***REMOVED******REMOVED******REMOVED******REMOVED***xFocalLength: intrinsics[0][0],
***REMOVED******REMOVED******REMOVED******REMOVED***yFocalLength: intrinsics[1][1],
***REMOVED******REMOVED******REMOVED******REMOVED***xPrincipal: intrinsics[2][0],
***REMOVED******REMOVED******REMOVED******REMOVED***yPrincipal: intrinsics[2][1],
***REMOVED******REMOVED******REMOVED******REMOVED***xImageSize: Float(imageResolution.width),
***REMOVED******REMOVED******REMOVED******REMOVED***yImageSize: Float(imageResolution.height),
***REMOVED******REMOVED******REMOVED******REMOVED***deviceOrientation: lastGoodDeviceOrientation
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Render the Scene with the new transformation.
***REMOVED******REMOVED***sceneViewProxy.draw()
***REMOVED******REMOVED******REMOVED***print("-- drawing")
***REMOVED***
***REMOVED***
