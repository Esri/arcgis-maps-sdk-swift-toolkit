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
    @State private var interfaceOrientation: InterfaceOrientation?
    
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
                    sceneViewProxy.updateCamera(
                        frame: frame,
                        cameraController: cameraController,
                        orientation: interfaceOrientation
                    )
                }
                .overlay {
                    //InterfaceOrientationDetector(interfaceOrientation: $interfaceOrientation)
                }
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

/// A view that is able to update a binding to an interface orientation.
struct InterfaceOrientationDetector: UIViewControllerRepresentable {
    /// The binding to update when an interface orientation change is detected.
    let binding: Binding<UIInterfaceOrientation?>
    
    /// Creates an interface orientation detector view.
    init(interfaceOrientation: Binding<UIInterfaceOrientation?>) {
        binding = interfaceOrientation
    }
    
    func makeUIViewController(context: Context) -> InterfaceOrientationViewController {
        InterfaceOrientationViewController(interfaceOrientation: binding)
    }
    
    func updateUIViewController(_ uiView: InterfaceOrientationViewController, context: Context) {}
    
    final class InterfaceOrientationViewController: UIViewController {
        let binding: Binding<UIInterfaceOrientation?>
        
        init(interfaceOrientation: Binding<UIInterfaceOrientation?>) {
            binding = interfaceOrientation
            super.init(nibName: nil, bundle: nil)
            view.isUserInteractionEnabled = false
            view.isHidden = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            self.binding.wrappedValue = self.windowInterfaceOrientation
        }
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            // According to the Apple documentation, this is the new way to be notified when the
            // interface orientation changes.
            // Also, a similar solution is on SO here: https://stackoverflow.com/a/60577486/1687195
            
            super.viewWillTransition(to: size, with: coordinator)
            
            coordinator.animate { _ in
                self.binding.wrappedValue = self.windowInterfaceOrientation
            }
        }
        
        /// The interface orientation of the window that this view is contained in.
        var windowInterfaceOrientation: UIInterfaceOrientation? {
            view.window?.windowScene?.interfaceOrientation
        }
    }
}
