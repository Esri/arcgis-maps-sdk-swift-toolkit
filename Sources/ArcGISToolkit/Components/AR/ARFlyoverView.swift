***REMOVED***
***REMOVED***  File.swift
***REMOVED***
***REMOVED***
***REMOVED***  Created by Ryan Olson on 9/18/23.
***REMOVED***

import Foundation
import ARKit
***REMOVED***
***REMOVED***

public struct ARFlyoverView: View {
***REMOVED***private let configuration: ARWorldTrackingConfiguration
***REMOVED***
***REMOVED******REMOVED***/ The last portrait or landscape orientation value.
***REMOVED***@State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
***REMOVED***@State private var sceneViewProxy: SceneViewProxy?
***REMOVED***
***REMOVED***private let sceneViewBuilder: () -> SceneView
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***initialCamera: Camera,
***REMOVED******REMOVED***translationFactor: Double,
***REMOVED******REMOVED***clippingDistance: Double?,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping () -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.sceneViewBuilder = sceneView
***REMOVED******REMOVED***
***REMOVED******REMOVED***configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED******REMOVED***configuration.planeDetection = [.horizontal]
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***.onRender { _, _, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateLastGoodDeviceOrientation()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.draw(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: arViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: lastGoodDeviceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.run(configuration)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.pause()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***SceneViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.viewDrawingMode(.manual)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.sceneViewProxy = proxy
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func updateLastGoodDeviceOrientation() {
***REMOVED******REMOVED******REMOVED*** Get the device orientation, but don't allow non-landscape/portrait values.
***REMOVED******REMOVED***let deviceOrientation = UIDevice.current.orientation
***REMOVED******REMOVED***if deviceOrientation.isValidInterfaceOrientation {
***REMOVED******REMOVED******REMOVED***lastGoodDeviceOrientation = deviceOrientation
***REMOVED***
***REMOVED***
***REMOVED***

extension SceneViewProxy {
***REMOVED***func draw(
***REMOVED******REMOVED***for arViewProxy: ARSwiftUIViewProxy,
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController,
***REMOVED******REMOVED***orientation: UIDeviceOrientation
***REMOVED***) {
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Get transform from SCNView.pointOfView.
***REMOVED******REMOVED***guard let transform = arViewProxy.pointOfView?.transform else { return ***REMOVED***
***REMOVED******REMOVED***guard let session = arViewProxy.session else { return ***REMOVED***
***REMOVED******REMOVED***
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
***REMOVED******REMOVED***if let camera = session.currentFrame?.camera {
***REMOVED******REMOVED******REMOVED***let intrinsics = camera.intrinsics
***REMOVED******REMOVED******REMOVED***let imageResolution = camera.imageResolution
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***setFieldOfViewFromLensIntrinsics(
***REMOVED******REMOVED******REMOVED******REMOVED***xFocalLength: intrinsics[0][0],
***REMOVED******REMOVED******REMOVED******REMOVED***yFocalLength: intrinsics[1][1],
***REMOVED******REMOVED******REMOVED******REMOVED***xPrincipal: intrinsics[2][0],
***REMOVED******REMOVED******REMOVED******REMOVED***yPrincipal: intrinsics[2][1],
***REMOVED******REMOVED******REMOVED******REMOVED***xImageSize: Float(imageResolution.width),
***REMOVED******REMOVED******REMOVED******REMOVED***yImageSize: Float(imageResolution.height),
***REMOVED******REMOVED******REMOVED******REMOVED***deviceOrientation: orientation
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Render the Scene with the new transformation.
***REMOVED******REMOVED***draw()
***REMOVED***
***REMOVED***
