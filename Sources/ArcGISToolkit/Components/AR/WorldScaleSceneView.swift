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

enum GeotrackingLocationAvailability {
    case checking
    case available
    case unavailable(Error?)
}

/// A scene view that provides an augmented reality world scale experience.
public struct WorldScaleSceneView: View {
    /// The proxy for the ARSwiftUIView.
    @State private var arViewProxy = ARSwiftUIViewProxy()
    /// The proxy for the scene view.
    @State private var sceneViewProxy: SceneViewProxy?
    /// The camera controller that will be set on the scene view.
    @State private var cameraController: TransformationMatrixCameraController
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    /// The configuration for the AR session.
    private let configuration: ARConfiguration
    
    @State private var availability: GeotrackingLocationAvailability = .checking
    
    /// Creates a world scale scene view.
    /// - Parameters:
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    /// - Remark: The provided scene view will have certain properties overridden in order to
    /// be effectively viewed in augmented reality. Properties such as the camera controller,
    /// and view drawing mode.
    public init(
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        self.sceneViewBuilder = sceneView
        
        let initial = Point(latitude: 0, longitude: 0)
        let initialCamera = Camera(location: initial, heading: 0, pitch: 90, roll: 0)
        let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
//        cameraController.translationFactor = translationFactor
        _cameraController = .init(initialValue: cameraController)
        
        configuration = ARGeoTrackingConfiguration()
    }
    
    public var body: some View {
        if !ARGeoTrackingConfiguration.isSupported {
            unsupportedDeviceView
        } else {
            Group {
                switch availability {
                case .checking:
                    checkingGeotrackingAvailability
                case .available:
                    arView
                case .unavailable:
                    geotrackingIsNotAvailable
                }
            }
            .onAppear {
                ARGeoTrackingConfiguration.checkAvailability { available, error in
                    if available {
                        self.availability = .available
                    } else {
                        self.availability = .unavailable(error)
                    }
                }
            }
        }
    }
    
    @MainActor
    @ViewBuilder
    var checkingGeotrackingAvailability: some View {
        VStack {
            Text("Checking Geotracking availability at current location")
                .multilineTextAlignment(.center)
                .padding()
            ProgressView()
        }
    }
    
    @MainActor
    @ViewBuilder
    var geotrackingIsNotAvailable: some View {
        Text("Geotracking is not available at your current location.")
            .multilineTextAlignment(.center)
            .padding()
    }
    
    @MainActor
    @ViewBuilder
    var unsupportedDeviceView: some View {
        Text("Geotracking is not supported by this device.")
            .multilineTextAlignment(.center)
            .padding()
    }
    
    @MainActor
    @ViewBuilder
    var arView: some View {
        ZStack {
            ARSwiftUIView(proxy: arViewProxy)
                .onDidUpdateFrame { _, frame in
                    guard let sceneViewProxy, let interfaceOrientation else { return }
                    sceneViewProxy.updateCamera(
                        frame: frame,
                        cameraController: cameraController,
                        orientation: interfaceOrientation
                    )
                    sceneViewProxy.setFieldOfView(
                        for: frame,
                        orientation: interfaceOrientation
                    )
                }
            
            SceneViewReader { proxy in
                sceneViewBuilder(proxy)
                    .cameraController(cameraController)
                    .attributionBarHidden(true)
                    .spaceEffect(.transparent)
                    .atmosphereEffect(.off)
                    .onAppear {
                        // Capture scene view proxy as a workaround for a bug where
                        // preferences set for `ARSwiftUIView` are not honored. The
                        // issue has been logged with a bug report with ID FB13188508.
                        self.sceneViewProxy = proxy
                    }
            }
        }
        .observingInterfaceOrientation($interfaceOrientation)
        .onAppear {
            arViewProxy.session?.run(configuration)
        }
    }
}