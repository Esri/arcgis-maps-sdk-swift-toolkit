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
    //@State private var localizedPoint: CLLocationCoordinate2D?
    
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
        
        //        let initial = Point(latitude: 44.541829415061166, longitude: -117.5794293050851)
        //        let initialCamera = Camera(location: initial, heading: 0, pitch: 90, roll: 0)
        //        let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
        
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
                    
//                    let transform = frame.camera.transform
//                    let quaternion = simd_quatf(transform)
//                    let heading = Double(quaternion.vector.x) * 180 / Double.pi
//                    statusText = "\(heading)"
                    
                    
                    guard let sceneViewProxy, let interfaceOrientation, let initialTransformation else { return }
                   // guard let geoAnchor = frame.anchors.first(where: { $0.identifier == self.geoAnchor?.identifier }) else { return }
                    
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
                    if geoTrackingStatus.state == .localized {
                        isLocalized = true
                    }
                    handleTrackingStatusChange(status: geoTrackingStatus)
                }
                .onAddNode { renderer, node, anchor in
                    if anchor.identifier == geoAnchor?.identifier {
                        statusText += "adding box"
                        
                        //let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
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
//                .onUpdateNode { renderer, node, anchor in
//                    if anchor.identifier == geoAnchor?.identifier, initialTransformation == nil, anchor.transform != .init(diagonal: .one) {
//                        statusText = "\(anchor.transform)\n\(node.worldPosition)"
//                        
////                        let transform = node.simdTransform
////                        let quaternion = simd_quatf(transform)
////                        
////                        let s = "\(quaternion.vector.x), \(quaternion.vector.y), \(quaternion.vector.z), \(quaternion.vector.y), \(transform.columns.3.x), \(transform.columns.3.y), \(transform.columns.3.z)"
////                        statusText = s
////                        
////                        let transformationMatrix = TransformationMatrix.normalized(
////                            quaternionX: Double(quaternion.vector.x),
////                            quaternionY: Double(quaternion.vector.y),
////                            quaternionZ: Double(quaternion.vector.z),
////                            quaternionW: Double(quaternion.vector.w),
////                            translationX: Double(transform.columns.3.x),
////                            translationY: Double(transform.columns.3.y),
////                            translationZ: Double(transform.columns.3.z)
////                        )
////                        initialTransformation = transformationMatrix
////                        statusText = "\(transformationMatrix)"
//                        
//                        let transform = anchor.transform
//                        initialTransformation = .normalized(
//                            quaternionX: 0,
//                            quaternionY: 0,
//                            quaternionZ: 0,
//                            quaternionW: 1,
//                            translationX: Double(transform.columns.3.x),
//                            translationY: Double(transform.columns.3.y),
//                            translationZ: Double(transform.columns.3.z)
//                        )
//                    }
//                }
//                .onSingleTapGesture { screenPoint in
//                    guard let session = arViewProxy.session else { return }
//                    // Perform ARKit raycast on tap location
//                    guard let query = arViewProxy.raycastQuery(from: screenPoint, allowing: .estimatedPlane, alignment: .any) else {
//                        return
//                    }
//                    if let result = session.raycast(query).first {
//                        addGeoAnchor(at: result.worldTransform.translation)
//                    } else {
//                        statusText = "No raycast result.\nTry pointing at a different area\nor move closer to a surface."
//                    }
//                }
            
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
            heading: 0,
            pitch: 90,
            roll: 0
        )
    }
    
    func handleTrackingStatusChange(status: ARGeoTrackingStatus) {
        let state = status.state
        if let trackingStateText = statusText(for: state) {
            statusText = trackingStateText
        }
        
        guard let session = arViewProxy.session, state == .localized else { return }
        guard let heading = currentHeading else { return }
        
        guard geoAnchor == nil else { return }
        
        //                guard let query = session.currentFrame?.raycastQuery(
        //                    from: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2),
        //                    allowing: .estimatedPlane,
        //                    alignment: .any
        //                ) else {
        //                    statusText = "cannot create query"
        //                    return
        //                }
        //                guard let result = session.raycast(query).first else {
        //                    statusText = "raycast failed"
        //                    return
        //                }
        
        Task {
            //statusText = "Getting geo location..."
            
            //                    let point = result.worldTransform.translation
            
            var point = simd_float3()
            point.x = 0
            point.y = 0
            point.z = 2
            let (location, altitude) = try await session.geoLocation(forPoint: point)
            
            cameraController.originCamera = Camera(
                latitude: location.latitude,
                longitude: location.longitude,
                altitude: altitude + 10,
                heading: heading,
                pitch: 90,
                roll: 0
            )
            
//            guard let camera = session.currentFrame?.camera else { return }
//            let point = camera.transform.translation
//            
//            let (location, altitude) = try await session.geoLocation(forPoint: point)
//            let heading = (camera.eulerAngles.z * 180) / .pi
//            
//            cameraController.originCamera = Camera(
//                latitude: location.latitude,
//                longitude: location.longitude,
//                altitude: altitude + 3,
//                heading: Double(heading),
//                pitch: 90,
//                roll: 0
//            )
            
            initialTransformation = .identity
            
            //statusText = "\(location.latitude), \(location.longitude)\n+/-\(status.accuracy.rawValue)m"
            
            if let geoAnchor {
                session.remove(anchor: geoAnchor)
            }
            
            let anchor = ARGeoAnchor(coordinate: location)
            session.add(anchor: anchor)
            geoAnchor = anchor
        }
    }
    
    @State private var initialTransformation: TransformationMatrix?
    
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
