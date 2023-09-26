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
    /// The AR session.
    @StateObject private var session = ObservableARSession()
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    /// The camera controller that we will set on the scene view.
    @State private var cameraController: TransformationMatrixCameraController
    /// The last portrait or landscape orientation value.
    @State var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
    
    /// Creates a fly over scene view.
    /// - Parameters:
    ///   - initialCamera: The initial camera.
    ///   - translationFactor: The translation factor that defines how much the scene view translates
    ///   as the device moves.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    /// - Remark: The provided scene view will have certain properties overridden in order to
    /// be effectively viewed in augmented reality. One such property is the camera controller.
    public init(
        initialCamera: Camera,
        translationFactor: Double,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        self.sceneViewBuilder = sceneView
        
        let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
        cameraController.translationFactor = translationFactor
        _cameraController = .init(initialValue: cameraController)
    }
    
    public var body: some View {
        SceneViewReader { sceneViewProxy in
            sceneViewBuilder(sceneViewProxy)
                .cameraController(cameraController)
                .onAppear { session.start() }
                .onDisappear { session.pause() }
                .onChange(of: session.currentFrame) { frame in
                    guard let frame else { return }
                    updateLastGoodDeviceOrientation()
                    sceneViewProxy.updateCamera(
                        frame: frame,
                        cameraController: cameraController,
                        orientation: lastGoodDeviceOrientation
                    )
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

/// An observable object that wraps an `ARSession` and provides the current frame.
private class ObservableARSession: NSObject, ObservableObject, ARSessionDelegate {
    /// The configuration used for the AR session.
    private let configuration: ARWorldTrackingConfiguration
    
    /// The backing AR session.
    private let session = ARSession()
    
    override init() {
        configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        super.init()
        session.delegate = self
    }
    
    /// Starts the AR session.
    func start() {
        session.run(configuration)
    }
    
    /// Pauses the AR session.
    func pause() {
        session.pause()
    }
    
    /// The latest AR frame.
    @Published
    var currentFrame: ARFrame?
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        currentFrame = frame
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
