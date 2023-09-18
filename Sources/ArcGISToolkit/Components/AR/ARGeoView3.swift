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

public struct ARGeoView3: View {
***REMOVED***private let scene: ArcGIS.Scene
***REMOVED***private let configuration: ARWorldTrackingConfiguration
***REMOVED***private let cameraController: TransformationMatrixCameraController
***REMOVED***
***REMOVED******REMOVED***/ The last portrait or landscape orientation value.
***REMOVED***@State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
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
***REMOVED******REMOVED******REMOVED***SceneViewReader { readerSceneViewProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onRender { _, _, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***render(arViewProxy: arViewProxy, sceneViewProxy: sceneViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.run(configuration)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session?.pause()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***SceneView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scene: scene,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED******REMOVED***.viewDrawingMode(.manual)
***REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.sceneViewProxy = readerSceneViewProxy
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension ARGeoView3 {
***REMOVED***func render(arViewProxy: ARSwiftUIViewProxy, sceneViewProxy: SceneViewProxy) {
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
***REMOVED***
***REMOVED***
