// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import ARKit
import SwiftUI
import ArcGIS

struct ARSwiftUIView {
    private(set) var alpha: CGFloat = 1.0
    private(set) var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
    private(set) var onCameraTrackingStateChangeAction: ((ARSession, ARCamera) -> Void)?
    private(set) var onGeoTrackingStatusChangeAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
    private(set) var onProxyAvailableAction: ((ARSwiftUIView.Proxy) -> Void)?
    
    init() {
    }
    
    func alpha(_ alpha: CGFloat) -> Self {
        var view = self
        view.alpha = alpha
        return view
    }
    
    func onRender(
        perform action: @escaping (SCNSceneRenderer, SCNScene, TimeInterval) -> Void
    ) -> Self {
        var view = self
        view.onRenderAction = action
        return view
    }
    
    func onCameraTrackingStateChange(
        perform action: @escaping (ARSession, ARCamera) -> Void
    ) -> Self {
        var view = self
        view.onCameraTrackingStateChangeAction = action
        return view
    }
    
    func onGeoTrackingStatusChange(
        perform action: @escaping (ARSession, ARGeoTrackingStatus) -> Void
    ) -> Self {
        var view = self
        view.onGeoTrackingStatusChangeAction = action
        return view
    }
    
    func onProxyAvailable(
        perform action: @escaping (ARSwiftUIView.Proxy) -> Void
    ) -> Self {
        var view = self
        view.onProxyAvailableAction = action
        return view
    }
}

extension ARSwiftUIView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        onProxyAvailableAction?(Proxy(arView: arView))
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(arSwiftUIView: self)
    }
}

extension ARSwiftUIView {
    class Coordinator: NSObject, ARSCNViewDelegate {
        private let view: ARSwiftUIView
        
        init(arSwiftUIView: ARSwiftUIView) {
            self.view = arSwiftUIView
        }
        
        func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
            view.onRenderAction?(renderer, scene, time)
        }
        
        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            view.onCameraTrackingStateChangeAction?(session, camera)
        }
        
        func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
            view.onGeoTrackingStatusChangeAction?(session, geoTrackingStatus)
        }
    }
}

extension ARSwiftUIView {
    class Proxy {
        private let arView: ARSCNView
        
        init(arView: ARSCNView) {
            self.arView = arView
        }
        
        var session: ARSession {
            arView.session
        }
        
        var pointOfView: SCNNode? {
            arView.pointOfView
        }
    }
}

public struct ARGeoView3: View {
    private let configuration: ARWorldTrackingConfiguration
    
    init() {
        configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]
    }
    
    public var body: some View {
        ZStack {
            SceneViewReader { proxy in
                ARSwiftUIView()
                    .alpha(0)
                    .onProxyAvailable { proxy in
                        proxy.session.run(configuration)
                    }
                    .onRenderAction { renderer, scene, time in
                        
                    }
                SceneView(
                    scene: ExampleVars.scene,
                    cameraController: ExampleVars.cameraController
                )
                .attributionBarHidden(true)
                .spaceEffect(.transparent)
                .viewDrawingMode(.manual)
                .atmosphereEffect(.off)
            }
        }
    }
}

private extension ARGeoView3 {
    func render() {
        // Get transform from SCNView.pointOfView.
        guard let transform = arView.pointOfView?.transform else { return }
        let cameraTransform = simd_double4x4(transform)
        
        let cameraQuat = simd_quatd(cameraTransform)
        let transformationMatrix = TransformationMatrix.normalized(
            quaternionX: cameraQuat.vector.x,
            quaternionY: cameraQuat.vector.y,
            quaternionZ: cameraQuat.vector.z,
            quaternionW: cameraQuat.vector.w,
            translationX: cameraTransform.columns.3.x,
            translationY: cameraTransform.columns.3.y,
            translationZ: cameraTransform.columns.3.z
        )
        
        // Set the matrix on the camera controller.
        let cameraController = sceneViewController.cameraController as! TransformationMatrixCameraController
        cameraController.transformationMatrix = initialTransformation.adding(transformationMatrix)
        
        // Set FOV on camera.
        if let camera = arView.session.currentFrame?.camera {
            let intrinsics = camera.intrinsics
            let imageResolution = camera.imageResolution
            
            // Get the device orientation, but don't allow non-landscape/portrait values.
            let deviceOrientation = UIDevice.current.orientation
            if deviceOrientation.isValidInterfaceOrientation {
                lastGoodDeviceOrientation = deviceOrientation
            }
            
            sceneViewController.setFieldOfViewFromLensIntrinsics(
                xFocalLength: intrinsics[0][0],
                yFocalLength: intrinsics[1][1],
                xPrincipal: intrinsics[2][0],
                yPrincipal: intrinsics[2][1],
                xImageSize: Float(imageResolution.width),
                yImageSize: Float(imageResolution.height),
                deviceOrientation: lastGoodDeviceOrientation
            )
        }
        
        // Render the Scene with the new transformation.
        sceneViewController.draw()
    }
}


private enum ExampleVars {
    static var scene: ArcGIS.Scene = {
        let scene = Scene(
            item: PortalItem(
                portal: .arcGISOnline(connection: .anonymous),
                id: PortalItem.ID("7558ee942b2547019f66885c44d4f0b1")!
            )
        )
        
        scene.initialViewpoint = Viewpoint(
            latitude: 37.8651,
            longitude: 119.5383,
            scale: 10
        )
        
        return scene
    }()
    
    static var cameraController: TransformationMatrixCameraController = {
        let controller = TransformationMatrixCameraController()
        controller.originCamera = Camera(
            lookingAt: Point(x: 4.4777, y: 51.9244, spatialReference: .wgs84),
            distance: 1_000,
            heading: 40,
            pitch: 90,
            roll: 0
        )
        
        controller.translationFactor = 3000
        controller.clippingDistance = 6000
        return controller
    }()
}
