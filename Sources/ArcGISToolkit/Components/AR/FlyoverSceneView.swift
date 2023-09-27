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
    @State private var interfaceOrientation: UIInterfaceOrientation?
    
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
    }
    
    public var body: some View {
        ZStack {
            SceneViewReader { sceneViewProxy in
                sceneViewBuilder(sceneViewProxy)
                    .cameraController(cameraController)
                    .viewDrawingMode(.manual)
                ARSwiftUIView(proxy: arViewProxy)
                    .onDidUpdateFrame { _, frame in
                        updateLastGoodDeviceOrientation()
                        sceneViewProxy.draw(
                            frame: frame,
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
                    .overlay {
                        InterfaceOrientationReader(interfaceOrientation: $interfaceOrientation)
                    }
                    .onChange(of: interfaceOrientation) { io in
                        if let io {
                            print("-- new io: \(io)")
                        }
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
    
//    var window: UIWindow? {
//        guard let scene = UIApplication.shared.connectedScenes.first,
//              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
//              let window = windowSceneDelegate.window else {
//            return nil
//        }
//        return window
//    }
//    
//    var interfaceOrientation: UIInterfaceOrientation? {
//        window?.windowScene?.interfaceOrientation
//    }
}

extension SceneViewProxy {
    /// Draws the scene view manually and sets the camera for a given augmented reality frame.
    /// - Parameters:
    ///   - frame: The current AR frame.
    ///   - cameraController: The current camera controller assigned to the scene view.
    ///   - orientation: The device orientation.
    /// - Precondition: 'orientation.isValidInterfaceOrientation'
    func draw(
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
        
        // Set FOV on scene view.
        let intrinsics = frame.camera.intrinsics
        let imageResolution = frame.camera.imageResolution
        
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

private extension ARCamera {
    /// The transform rotated for a particular device orientation.
    /// - Parameter orientation: The device orientation that the transform is appropriate for.
    /// - Precondition: 'orientation.isValidInterfaceOrientation'
    func transform(for orientation: UIDeviceOrientation) -> simd_float4x4 {
        precondition(orientation.isValidInterfaceOrientation)
        switch orientation {
        case .portrait:
            // Rotate camera transform 90 degrees counter-clockwise in the XY plane.
            return simd_float4x4(
                transform.columns.1,
                -transform.columns.0,
                transform.columns.2,
                transform.columns.3
            )
        case .landscapeLeft:
            return transform
        case .landscapeRight:
            return simd_float4x4(
                -transform.columns.0,
                -transform.columns.1,
                transform.columns.2,
                transform.columns.3
            )
        case .portraitUpsideDown:
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

struct InterfaceOrientationReader: UIViewControllerRepresentable {
    let binding: Binding<UIInterfaceOrientation?>
    
    init(interfaceOrientation: Binding<UIInterfaceOrientation?>) {
        binding = interfaceOrientation
    }
    
    func makeUIViewController(context: Context) -> InterfaceOrientationViewController {
        InterfaceOrientationViewController(interfaceOrientation: binding)
    }
    
    func updateUIViewController(_ uiView: InterfaceOrientationViewController, context: Context) {}
}

final class InterfaceOrientationViewController: UIViewController {
    let binding: Binding<UIInterfaceOrientation?>
    
    init(interfaceOrientation: Binding<UIInterfaceOrientation?>) {
        binding = interfaceOrientation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.binding.wrappedValue = self.windowInterfaceOrientation
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { _ in
            self.binding.wrappedValue = self.windowInterfaceOrientation
        }
    }
    
    var windowInterfaceOrientation: UIInterfaceOrientation? {
        view.window?.windowScene?.interfaceOrientation
    }
    
}
