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
    @State private var trackingStatus: ARGeoTrackingStatus?
    //@State private var localizedPoint: CLLocationCoordinate2D?
    
    @State private var statusText: String = ""
    @State private var geoAnchor: ARGeoAnchor?
    
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
        
        let initial = Point(latitude: 43.541829415061166, longitude: -116.5794293050851)
        let initialCamera = Camera(location: initial, heading: 0, pitch: 90, roll: 0)
//        let initialCamera = Camera(lookingAt: initial, distance: 20, heading: 0, pitch: -10, roll: 0)
        let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
        //cameraController.transformationMatrix = .identity
        cameraController.translationFactor = 1
        _cameraController = .init(initialValue: cameraController)
        
        configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
    }
    
    public var body: some View {
        arView
//        if !ARGeoTrackingConfiguration.isSupported {
//            unsupportedDeviceView
//        } else {
//            Group {
//                switch availability {
//                case .checking:
//                    checkingGeotrackingAvailability
//                case .available:
//                    arView
//                case .unavailable:
//                    geotrackingIsNotAvailable
//                }
//            }
//            .onAppear {
//                ARGeoTrackingConfiguration.checkAvailability { available, error in
//                    if available {
//                        self.availability = .available
//                    } else {
//                        self.availability = .unavailable(error)
//                    }
//                }
//            }
//        }
    }
    
    @MainActor
    @ViewBuilder
    var arView: some View {
//        GeometryReader { proxy in
            ZStack {
                ARSwiftUIView(proxy: arViewProxy)
                    .onDidUpdateFrame { _, frame in
                        trackingStatus = frame.geoTrackingStatus
                        
                        guard let sceneViewProxy, let interfaceOrientation else { return }
                        
                        sceneViewProxy.updateCamera(
                            frame: frame,
                            cameraController: cameraController,
                            orientation: interfaceOrientation
                        )
//                        sceneViewProxy.setFieldOfView(
//                            for: frame,
//                            orientation: interfaceOrientation
//                        )
                        
//                        if let geoAnchor {
//                            statusText = "\(geoAnchor.transform)"
//                        }
                    }
//                    .onAddNode { renderer, node, anchor in
//                        statusText = "anchor added"
//                    }
                
//                if trackingStatus?.state == .localized {
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
//                }
                
//                if let localizedPoint {
//                    statusView(for: "\(localizedPoint.latitude), \(localizedPoint.longitude)")
//                        .background(Color.white.opacity(0.85))
//                }
                
                if !statusText.isEmpty {
                    statusView(for: statusText)
                        .background(Color.white.opacity(0.85))
                }
                
                trackingStatusView
            }
            .observingInterfaceOrientation($interfaceOrientation)
            .onAppear {
                arViewProxy.session?.run(configuration)
            }
//            .onChange(of: trackingStatus) { status in
//                guard let session = arViewProxy.session, let status, status.state == .localized else { return }
//                
////                guard let query = session.currentFrame?.raycastQuery(
////                    from: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2),
////                    allowing: .estimatedPlane,
////                    alignment: .any
////                ) else {
////                    statusText = "cannot create query"
////                    return
////                }
////                guard let result = session.raycast(query).first else {
////                    statusText = "raycast failed"
////                    return
////                }
//                
//                Task {
////                    let point = result.worldTransform.translation
//                    let point = simd_float3()
//                    let (location, _) = try await session.geoLocation(forPoint: point)
//                    cameraController.originCamera = Camera(
//                        latitude: location.latitude,
//                        longitude: location.longitude,
//                        altitude: 3,
//                        heading: 0,
//                        pitch: 90,
//                        roll: 0
//                    )
//                    
//                    statusText = "Localized point: \(location.latitude), \(location.longitude)"
//                    
////                    let anchor = ARGeoAnchor(coordinate: location)
////                    session.add(anchor: anchor)
////                    geoAnchor = anchor
//                }
//            }
        
//        }
    }
    
    @MainActor
    @ViewBuilder
    var checkingGeotrackingAvailability: some View {
        statusView(for: "Checking Geotracking availability at current location.", showProgress: true)
    }
    
    @MainActor
    @ViewBuilder
    var geotrackingIsNotAvailable: some View {
        statusView(for: "Geotracking is not available at your current location.")
    }
    
    @MainActor
    @ViewBuilder
    var unsupportedDeviceView: some View {
        statusView(for: "Geotracking is not supported by this device.")
    }
    
    @MainActor
    @ViewBuilder
    var trackingStatusView: some View {
        switch trackingStatus?.state {
        case .notAvailable:
            statusView(for: "Not available.")
                .background(Color.white.opacity(0.5))
        case .initializing:
            statusView(for: "Initializing.")
                .background(Color.white.opacity(0.5))
        case .localizing:
            statusView(for: "Localizing.")
                .background(Color.white.opacity(0.5))
        case .localized:
            EmptyView()
        case nil:
            EmptyView()
        @unknown default:
            EmptyView()
        }
    }
    
    @ViewBuilder func statusView(for status: String, showProgress: Bool = false) -> some View {
        VStack {
            Text(status)
                .multilineTextAlignment(.center)
                .padding()
            if showProgress {
                ProgressView()
            }
        }
    }
}

extension simd_float4x4 {
    var translation: simd_float3 {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}
