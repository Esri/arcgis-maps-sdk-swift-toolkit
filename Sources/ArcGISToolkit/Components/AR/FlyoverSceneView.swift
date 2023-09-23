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

extension FlyoverSceneView {
    class Model: NSObject, ObservableObject {
        var sceneViewProxy: SceneViewProxy?
        private let configuration: ARWorldTrackingConfiguration
        private let session = ARSession()
        private let cameraController: TransformationMatrixCameraController
        /// The last portrait or landscape orientation value.
        private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
        
        init(initialCamera: Camera, translationFactor: Double) {
            configuration = ARWorldTrackingConfiguration()
            configuration.worldAlignment = .gravityAndHeading
            
            let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
            cameraController.translationFactor = translationFactor
            self.cameraController = cameraController
            
            super.init()
            
            session.delegate = self
        }
        
        /// Updates the last good device orientation.
        func updateLastGoodDeviceOrientation() {
            // Get the device orientation, but don't allow non-landscape/portrait values.
            let deviceOrientation = UIDevice.current.orientation
            if deviceOrientation.isValidInterfaceOrientation {
                lastGoodDeviceOrientation = deviceOrientation
            }
        }
        
        /// Starts the AR session.
        func startARSession() {
            session.run(configuration)
        }
        
        /// Pauses the AR session.
        func pauseARSession() {
            session.pause()
        }
        
//        @Published
//        var currentFrame: ARFrame?
    }
}

extension FlyoverSceneView.Model: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        updateLastGoodDeviceOrientation()
        currentFrame = frame
        sceneViewProxy?.updateCamera(frame: frame, cameraController: cameraController, orientation: lastGoodDeviceOrientation)
    }
}

/// A scene view that provides an augmented reality fly over experience.
public struct FlyoverSceneView: View {
    @StateObject private var model: Model
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    
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
        _model = StateObject(wrappedValue: Model(initialCamera: initialCamera, translationFactor: translationFactor))
    }
    
    public var body: some View {
        SceneViewReader { sceneViewProxy in
            sceneViewBuilder(sceneViewProxy)
                .cameraController(model.cameraController)
                .onAppear {
                    model.sceneViewProxy = sceneViewProxy
                    model.startARSession()
                }
                .onDisappear {
                    model.pauseARSession()
                }
        }
    }
}

extension SceneViewProxy {
    /// Updates the scene view's camera for a given augmented reality frame.
    /// - Parameters:
    ///   - frame: The current AR frame.
    ///   - cameraController: The current camera controller assigned to the scene view.
    ///   - orientation: The device orientation.
    func updateCamera(
        frame: ARFrame,
        cameraController: TransformationMatrixCameraController,
        orientation: UIDeviceOrientation
    ) {
        let transform = frame.camera.transform(for: orientation)
        let quaternion = simd_quatf(transform)
        let transformationMatrix = TransformationMatrix.normalized(
            quaternionX: Double(quaternion.vector.x),
            quaternionY: Double(quaternion.vector.y),
            quaternionZ: Double(quaternion.vector.z),
            quaternionW: Double(quaternion.vector.w),
            translationX: Double(transform.columns.3.x),
            translationY: Double(transform.columns.3.y),
            translationZ: Double(transform.columns.3.z)
        )
        
        // Set the matrix on the camera controller.
        cameraController.transformationMatrix = .identity.adding(transformationMatrix)
    }
}

private extension ARCamera {
    /// The transform rotated for a particular device orientation.
    /// - Parameter orientation: The device orientation that the transform is appropriate for.
    /// - Precondition: 'orientation.isValidInterfaceOrientation'
    func transform(for orientation: UIDeviceOrientation) -> simd_float4x4 {
        precondition(orientation.isValidInterfaceOrientation)
        switch orientation {
        case .portrait:
            // Rotate camera transform 90 degrees clockwise in the XY plane.
            return simd_float4x4(
                transform.columns.1,
                -transform.columns.0,
                transform.columns.2,
                transform.columns.3
            )
        case .landscapeLeft:
            // No rotation necessary.
            return transform
        case .landscapeRight:
            // Rotate 180.
            return simd_float4x4(
                -transform.columns.0,
                -transform.columns.1,
                transform.columns.2,
                transform.columns.3
            )
        case .portraitUpsideDown:
            // Rotate 90 counter clockwise.
            return simd_float4x4(
                -transform.columns.1,
                transform.columns.0,
                transform.columns.2,
                transform.columns.3
            )
        default:
            preconditionFailure()
        }
    }
}
