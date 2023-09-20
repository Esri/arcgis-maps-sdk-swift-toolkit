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

import ARKit
import SwiftUI
import ArcGIS

/// A scene view that provides an augmented reality fly over experience.
public struct FlyoverSceneView: View {
    /// The last portrait or landscape orientation value.
    @State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
    @State private var arViewProxy = ARSwiftUIViewProxy()
    @State private var cameraController: TransformationMatrixCameraController
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    private let configuration: ARWorldTrackingConfiguration
    
    /// Creates a fly over scene view.
    /// - Parameters:
    ///   - initialCamera: The initial camera.
    ///   - translationFactor: The translation factor that defines how much the scene view translates
    ///   as the device moves.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    /// - Remark: The provided scene view will have certain properties overridden in order to
    /// be effectively viewed in augmented reality. Properties such as the camera controller,
    /// and view drawing mode.
    public init(
        initialCamera: Camera,
        translationFactor: Double,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        self.sceneViewBuilder = sceneView
        
        let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
        cameraController.translationFactor = translationFactor
        _cameraController = .init(initialValue: cameraController)
        
        configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]
    }
    
    public var body: some View {
        ZStack {
            SceneViewReader { sceneViewProxy in
                sceneViewBuilder(sceneViewProxy)
                    .cameraController(cameraController)
                    .viewDrawingMode(.manual)
                ARSwiftUIView(proxy: arViewProxy)
                    .onAnchorsDidUpdate { session, anchors in
                        updateLastGoodDeviceOrientation()
                        sceneViewProxy.draw(
                            for: arViewProxy,
                            cameraController: cameraController,
                            orientation: lastGoodDeviceOrientation
                        )
                    }
                    .videoFeedHidden()
                    .disabled(true)
                    .onAppear {
                        arViewProxy.session?.run(configuration)
                    }
                    .onDisappear {
                        arViewProxy.session?.pause()
                    }
            }
        }
    }
    
    /// Updates the last good device orientation.
    func updateLastGoodDeviceOrientation() {
        // Get the device orientation, but don't allow non-landscape/portrait values.
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation.isValidInterfaceOrientation {
            lastGoodDeviceOrientation = deviceOrientation
        }
    }
}

extension SceneViewProxy {
    /// Draws the scene view manually and sets the camera for a given augmented reality view.
    /// - Parameters:
    ///   - arViewProxy: The AR view proxy.
    ///   - cameraController: The current camera controller assigned to the scene view.
    ///   - orientation: The device orientation.
    func draw(
        for arViewProxy: ARSwiftUIViewProxy,
        cameraController: TransformationMatrixCameraController,
        orientation: UIDeviceOrientation
    ) {
        guard let session = arViewProxy.session, let cameraTransform = arViewProxy.cameraTransform else {
            return
        }
        
        let cameraMatrix = cameraTransform.matrix
        
        let cameraQuat = simd_quatf(cameraMatrix)
        
        let transformationMatrix = TransformationMatrix.normalized(
            quaternionX: Double(cameraQuat.vector.x),
            quaternionY: Double(cameraQuat.vector.y),
            quaternionZ: Double(cameraQuat.vector.z),
            quaternionW: Double(cameraQuat.vector.w),
            translationX: Double(cameraMatrix.columns.3.x),
            translationY: Double(cameraMatrix.columns.3.y),
            translationZ: Double(cameraMatrix.columns.3.z)
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
            
            // Render the Scene with the new transformation.
            draw()
        }
    }
}
