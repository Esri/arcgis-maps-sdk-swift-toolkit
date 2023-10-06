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
    @State private var isLocalized = false
    @State private var initialTransformation: TransformationMatrix?
    
    @State private var statusText: String = ""
    @State private var geoAnchor: ARGeoAnchor?
    
    @State private var locationDatasSource = SystemLocationDataSource()
    @State private var currentHeading: Double? = 0
    
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
        
        let cameraController = TransformationMatrixCameraController()
        cameraController.translationFactor = 1
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
    var arView: some View {
        //        GeometryReader { proxy in
        ZStack {
            ARSwiftUIView(proxy: arViewProxy)
                .onDidUpdateFrame { _, frame in
                    guard let sceneViewProxy, let interfaceOrientation, let initialTransformation else { return }
                    
                    sceneViewProxy.updateCamera(
                        frame: frame,
                        cameraController: cameraController,
                        orientation: interfaceOrientation,
                        initialTransformation: initialTransformation
                    )
//                    sceneViewProxy.setFieldOfView(
//                        for: frame,
//                        orientation: interfaceOrientation
//                    )
                }
                .onGeoTrackingStatusChange { session, geoTrackingStatus in
                    isLocalized = geoTrackingStatus.state == .localized
                    if let trackingStateText = statusText(for: geoTrackingStatus.state) {
                        statusText = trackingStateText
                    }
                }
                .onAddNode { renderer, node, anchor in
                    if anchor.identifier == geoAnchor?.identifier {
                        let box = SCNSphere(radius: 1)
                        let material = SCNMaterial()
                        material.isDoubleSided = true
                        material.diffuse.contents = UIColor.red.withAlphaComponent(0.85)
                        box.materials = [material]
                        let boxNode = SCNNode()
                        boxNode.geometry = box
                        boxNode.worldPosition = node.worldPosition
                        node.addChildNode(boxNode)
                    }
                }
                .onSingleTapGesture { screenPoint in
                    guard let session = arViewProxy.session else { return }
                    // Perform ARKit raycast on tap location
                    guard let query = arViewProxy.raycastQuery(from: screenPoint, allowing: .estimatedPlane, alignment: .any) else {
                        return
                    }
                    if let result = session.raycast(query).first {
                        addGeoAnchor(at: result.worldTransform.translation)
                    } else {
                        statusText = "No raycast result.\nTry pointing at a different area\nor move closer to a surface."
                    }
                }
            
            if initialTransformation != nil {
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
        }
        .overlay(alignment: .top) {
            if !statusText.isEmpty {
                statusView(for: statusText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(8)
                    .background(.regularMaterial, ignoresSafeAreaEdges: .horizontal)
            }
        }
        .observingInterfaceOrientation($interfaceOrientation)
        .onAppear {
            arViewProxy.session?.run(configuration, options: [.resetTracking])
        }
        .task {
            try? await locationDatasSource.start()
            for await heading in locationDatasSource.headings {
                self.currentHeading = heading
                self.statusText = "heading: \(heading)"
            }
        }
    }
    
    func addGeoAnchor(at worldPosition: SIMD3<Float>) {
        guard let session = arViewProxy.session else { return }
        session.getGeoLocation(forPoint: worldPosition) { (location, altitude, error) in
            if let error = error {
                statusText = "Cannot add geo anchor: \(error.localizedDescription)"
                return
            }
            self.addGeoAnchor(at: location, altitude: altitude)
        }
    }
    
    func addGeoAnchor(at location: CLLocationCoordinate2D, altitude: CLLocationDistance? = nil) {
        guard let session = arViewProxy.session else { return }
        let geoAnchor: ARGeoAnchor
        if let altitude = altitude {
            geoAnchor = ARGeoAnchor(coordinate: location, altitude: altitude)
        } else {
            geoAnchor = ARGeoAnchor(coordinate: location)
        }
        
        session.add(anchor: geoAnchor)
        self.geoAnchor = geoAnchor
        
        cameraController.originCamera = Camera(
            latitude: location.latitude,
            longitude: location.longitude,
            altitude: (altitude ?? 0) + 3,
            heading: currentHeading ?? 0,
            pitch: 90,
            roll: 0
        )
        
        initialTransformation = .identity
    }
    
    @MainActor
    @ViewBuilder
    var checkingGeotrackingAvailability: some View {
        statusView(for: "Checking Geotracking availability at current location.")
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
    
    func statusText(for state: ARGeoTrackingStatus.State) -> String? {
        switch state {
        case .notAvailable:
            return "GeoTracking is not available."
        case .initializing:
            return "Make sure you are outdoors.\nUse the camera to scan static structures or buildings."
        case .localizing:
            return "Attempting to identify device location.\nContinue to scan outdoor structures or buildings."
        case .localized:
            return "Location has been identified."
            //return nil
        @unknown default:
            return nil
        }
    }
    
    @ViewBuilder func statusView(for status: String) -> some View {
        Text(status)
            .multilineTextAlignment(.center)
    }
}

extension simd_float4x4 {
    var translation: simd_float3 {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}

extension TransformationMatrix: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(quaternionX), \(quaternionY), \(quaternionZ), \(quaternionW), \(translationX), \(translationY), \(translationZ)"
    }
}
