// Copyright 2023 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ARKit
import SwiftUI
import ArcGIS

/// A scene view that provides an augmented reality fly over experience.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public struct FlyoverSceneView: View {
#if os(iOS)
    /// The AR session.
    @StateObject private var session = ObservableARSession()
#endif
    /// The initial camera.
    let initialCamera: Camera
    /// The translation factor.
    let translationFactor: Double
    /// A Boolean value indicating whether to orient the scene view's initial heading to compass heading.
    let shouldOrientToCompass: Bool
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    /// The camera controller that we will set on the scene view.
    @State private var cameraController: TransformationMatrixCameraController
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    
    /// Creates a fly over scene view.
    /// - Parameters:
    ///   - initialLatitude: The initial latitude of the scene view's camera.
    ///   - initialLongitude: The initial longitude of the scene view's camera.
    ///   - initialAltitude: The initial altitude of the scene view's camera.
    ///   - translationFactor: The translation factor that defines how much the scene view translates
    ///   as the device moves.
    ///   - initialHeading: The initial heading of the scene view's camera. A value of `nil` means
    ///   the scene view's heading will be initially oriented to compass heading.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    /// - Remark: The provided scene view will have certain properties overridden in order to
    /// be effectively viewed in augmented reality. One such property is the camera controller.
    public init(
        initialLatitude: Double,
        initialLongitude: Double,
        initialAltitude: Double,
        translationFactor: Double,
        initialHeading: Double? = nil,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        let camera = Camera(
            latitude: initialLatitude,
            longitude: initialLongitude,
            altitude: initialAltitude,
            heading: initialHeading ?? 0,
            pitch: 90,
            roll: 0
        )
        self.init(
            initialCamera: camera,
            translationFactor: translationFactor,
            shouldOrientToCompass: initialHeading == nil,
            sceneView: sceneView
        )
    }
    
    /// Creates a fly over scene view.
    /// - Parameters:
    ///   - initialLocation: The initial location of the scene view's camera.
    ///   - translationFactor: The translation factor that defines how much the scene view translates
    ///   as the device moves.
    ///   - initialHeading: The initial heading of the scene view's camera. A value of `nil` means
    ///   the scene view's heading will be initially oriented to compass heading.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    /// - Remark: The provided scene view will have certain properties overridden in order to
    /// be effectively viewed in augmented reality. One such property is the camera controller.
    public init(
        initialLocation: Point,
        translationFactor: Double,
        initialHeading: Double? = nil,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        let camera = Camera(
            location: initialLocation,
            heading: initialHeading ?? 0,
            pitch: 90,
            roll: 0
        )
        self.init(
            initialCamera: camera,
            translationFactor: translationFactor,
            shouldOrientToCompass: initialHeading == nil,
            sceneView: sceneView
        )
    }
    
    /// Creates a fly over scene view.
    /// - Parameters:
    ///   - initialCamera: The initial camera.
    ///   - translationFactor: The translation factor that defines how much the scene view translates
    ///   as the device moves.
    ///   - shouldOrientToCompass: A Boolean value indicating whether to orient the scene view's
    ///   initial heading to compass heading.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    /// - Remark: The provided scene view will have certain properties overridden in order to
    /// be effectively viewed in augmented reality. One such property is the camera controller.
    private init(
        initialCamera: Camera,
        translationFactor: Double,
        shouldOrientToCompass: Bool,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        self.sceneViewBuilder = sceneView
        self.shouldOrientToCompass = shouldOrientToCompass
        self.translationFactor = translationFactor
        self.initialCamera = initialCamera
        
        let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
        cameraController.translationFactor = translationFactor
        _cameraController = .init(initialValue: cameraController)
    }
    
    public var body: some View {
        SceneViewReader { sceneViewProxy in
            sceneViewBuilder(sceneViewProxy)
                .cameraController(cameraController)
                .atmosphereEffect(.realistic)
#if os(iOS)
                .onAppear {
                    let configuration = ARPositionalTrackingConfiguration()
                    if shouldOrientToCompass {
                        configuration.worldAlignment = .gravityAndHeading
                    }
                    session.start(configuration: configuration)
                }
                .onDisappear { session.pause() }
                .onChange(of: session.currentFrame) { _, frame in
                    guard let frame, let interfaceOrientation else { return }
                    sceneViewProxy.updateCamera(
                        frame: frame,
                        cameraController: cameraController,
                        orientation: interfaceOrientation
                    )
                }
#endif
                .onChange(of: initialCamera) { _, initialCamera in
                    cameraController.originCamera = initialCamera
                }
                .onChange(of: translationFactor) { _, translationFactor in
                    cameraController.translationFactor = translationFactor
                }
                .observingInterfaceOrientation($interfaceOrientation)
        }
    }
}

#if os(iOS)
/// An observable object that wraps an `ARSession` and provides the current frame.
private class ObservableARSession: NSObject, ObservableObject, ARSessionDelegate {
    /// The backing AR session.
    private let session = ARSession()
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    /// Starts the AR session by running a given configuration.
    /// - Parameter configuration: The AR configuration to run.
    func start(configuration: ARConfiguration) {
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
#endif
