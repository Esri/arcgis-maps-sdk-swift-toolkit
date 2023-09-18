// Copyright 2021 Esri.

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

public struct ARFlyoverView: View {
    private let configuration: ARWorldTrackingConfiguration
    
    /// The last portrait or landscape orientation value.
    @State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
    @State private var arViewProxy = ARSwiftUIViewProxy()
    @State private var sceneViewProxy: SceneViewProxy?
    @State private var cameraController: TransformationMatrixCameraController
    
    private let sceneViewBuilder: () -> SceneView
    
    public init(
        initialCamera: Camera,
        translationFactor: Double,
        clippingDistance: Double?,
        @ViewBuilder sceneView: @escaping () -> SceneView
    ) {
        self.sceneViewBuilder = sceneView
        
        let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
        cameraController.translationFactor = translationFactor
        cameraController.clippingDistance = clippingDistance
        _cameraController = .init(initialValue: cameraController)
        
        configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]
    }
    
    public var body: some View {
        ZStack {
            ARSwiftUIView(proxy: arViewProxy)
                .onRender { _, _, _ in
                    guard let sceneViewProxy else { return }
                    updateLastGoodDeviceOrientation()
                    sceneViewProxy.draw(
                        for: arViewProxy,
                        cameraController: cameraController,
                        orientation: lastGoodDeviceOrientation
                    )
                }
                .onAppear {
                    arViewProxy.session?.run(configuration)
                }
                .onDisappear {
                    arViewProxy.session?.pause()
                }
            SceneViewReader { proxy in
                sceneViewBuilder()
                    .cameraController(cameraController)
                    .attributionBarHidden(true)
                    .spaceEffect(.transparent)
                    .viewDrawingMode(.manual)
                    .atmosphereEffect(.off)
                    .onAppear {
                        self.sceneViewProxy = proxy
                    }
            }
        }
    }
    
    func updateLastGoodDeviceOrientation() {
        // Get the device orientation, but don't allow non-landscape/portrait values.
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation.isValidInterfaceOrientation {
            lastGoodDeviceOrientation = deviceOrientation
        }
    }
}

extension SceneViewProxy {
    func draw(
        for arViewProxy: ARSwiftUIViewProxy,
        cameraController: TransformationMatrixCameraController,
        orientation: UIDeviceOrientation
    ) {
        
        // Get transform from SCNView.pointOfView.
        guard let transform = arViewProxy.pointOfView?.transform else { return }
        guard let session = arViewProxy.session else { return }
        
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
        cameraController.transformationMatrix = .identity.adding(transformationMatrix)
        
        // Set FOV on camera.
        if let camera = session.currentFrame?.camera {
            let intrinsics = camera.intrinsics
            let imageResolution = camera.imageResolution
            
            setFieldOfViewFromLensIntrinsics(
                xFocalLength: intrinsics[0][0],
                yFocalLength: intrinsics[1][1],
                xPrincipal: intrinsics[2][0],
                yPrincipal: intrinsics[2][1],
                xImageSize: Float(imageResolution.width),
                yImageSize: Float(imageResolution.height),
                deviceOrientation: orientation
            )
        }
        
        // Render the Scene with the new transformation.
        draw()
    }
}
