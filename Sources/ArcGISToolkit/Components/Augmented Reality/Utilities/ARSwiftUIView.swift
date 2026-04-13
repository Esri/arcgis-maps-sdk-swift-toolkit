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

#if os(iOS)
import ArcGIS
import ARKit
import RealityKit
import SwiftUI

typealias ARViewType = RealityKit.ARView

/// A SwiftUI version of an AR view.
struct ARSwiftUIView {
    /// The closure to call when the session's geo-tracking state changes.
    private(set) var onDidChangeGeoTrackingStatusAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
    /// The closure to call when the session's camera tracking state changes.
    private(set) var onCameraDidChangeTrackingStateAction: ((ARSession, ARCamera.TrackingState) -> Void)?
    /// The closure to call when the session's frame updates.
    private(set) var onDidUpdateFrameAction: ((ARSession, ARFrame) -> Void)?
    /// The closure to call when a new plane anchor has been added to the view.
    private(set) var onAddAnchorAction: (@MainActor (ARPlaneAnchor) -> Void)?
    /// The closure to call when a plane anchor has been updated.
    private(set) var onUpdateAnchorAction: (@MainActor (ARPlaneAnchor) -> Void)?
    
    /// The proxy.
    private let proxy: ARSwiftUIViewProxy
    
    /// Creates an ARSwiftUIView.
    /// - Parameter proxy: The provided proxy which will have it's state filled out
    /// when available by the underlying view.
    init(proxy: ARSwiftUIViewProxy) {
        self.proxy = proxy
    }
    
    /// Sets the closure to call when the session's geo-tracking state changes.
    ///
    /// ARKit invokes the callback only for `ARGeoTrackingConfiguration` sessions.
    func onDidChangeGeoTrackingStatus(
        perform action: @escaping (ARSession, ARGeoTrackingStatus) -> Void
    ) -> Self {
        var view = self
        view.onDidChangeGeoTrackingStatusAction = action
        return view
    }
    
    /// Sets the closure to call when session's camera tracking state changes.
    func onCameraDidChangeTrackingState(
        perform action: @escaping (ARSession, ARCamera.TrackingState) -> Void
    ) -> Self {
        var view = self
        view.onCameraDidChangeTrackingStateAction = action
        return view
    }
    
    /// Sets the closure to call when underlying scene renders.
    func onDidUpdateFrame(
        perform action: @escaping (ARSession, ARFrame) -> Void
    ) -> Self {
        var view = self
        view.onDidUpdateFrameAction = action
        return view
    }
    
    /// Sets the closure to call when a new plane anchor has been added to the scene.
    func onAddAnchor(
        perform action: @escaping @MainActor (ARPlaneAnchor) -> Void
    ) -> Self {
        var view = self
        view.onAddAnchorAction = action
        return view
    }
    
    /// Sets the closure to call when the a plane anchor is updated.
    func onUpdateAnchor(
        perform action: @escaping @MainActor (ARPlaneAnchor) -> Void
    ) -> Self {
        var view = self
        view.onUpdateAnchorAction = action
        return view
    }
}

extension ARSwiftUIView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARViewType {
        let arView = ARViewType()
        arView.session.delegate = context.coordinator
        // Set the AR view on the proxy.
        proxy.arView = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARViewType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return .init(
            onDidChangeGeoTrackingStatusAction: onDidChangeGeoTrackingStatusAction,
            onCameraDidChangeTrackingStateAction: onCameraDidChangeTrackingStateAction,
            onDidUpdateFrameAction: onDidUpdateFrameAction,
            onAddAnchorAction: onAddAnchorAction,
            onUpdateAnchorAction: onUpdateAnchorAction
        )
    }
    
    class Coordinator: NSObject {
        let onDidChangeGeoTrackingStatusAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
        let onCameraDidChangeTrackingStateAction: ((ARSession, ARCamera.TrackingState) -> Void)?
        let onDidUpdateFrameAction: ((ARSession, ARFrame) -> Void)?
        let onAddAnchorAction: (@MainActor (ARPlaneAnchor) -> Void)?
        let onUpdateAnchorAction: (@MainActor (ARPlaneAnchor) -> Void)?
        
        init(
            onDidChangeGeoTrackingStatusAction: ((ARSession, ARGeoTrackingStatus) -> Void)?,
            onCameraDidChangeTrackingStateAction: ((ARSession, ARCamera.TrackingState) -> Void)?,
            onDidUpdateFrameAction: ((ARSession, ARFrame) -> Void)?,
            onAddAnchorAction: (@MainActor (ARPlaneAnchor) -> Void)?,
            onUpdateAnchorAction: (@MainActor (ARPlaneAnchor) -> Void)?
        ) {
            self.onDidChangeGeoTrackingStatusAction = onDidChangeGeoTrackingStatusAction
            self.onCameraDidChangeTrackingStateAction = onCameraDidChangeTrackingStateAction
            self.onDidUpdateFrameAction = onDidUpdateFrameAction
            self.onAddAnchorAction = onAddAnchorAction
            self.onUpdateAnchorAction = onUpdateAnchorAction
        }
    }
}

extension ARSwiftUIView.Coordinator: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let planeAnchors = anchors.compactMap { $0 as? ARPlaneAnchor }
        for anchor in planeAnchors {
            Task { @MainActor [onAddAnchorAction] in
                onAddAnchorAction?(anchor)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let planeAnchors = anchors.compactMap { $0 as? ARPlaneAnchor }
        for anchor in planeAnchors {
            Task { @MainActor [onUpdateAnchorAction] in
                onUpdateAnchorAction?(anchor)
            }
        }
    }
    
    func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
        onDidChangeGeoTrackingStatusAction?(session, geoTrackingStatus)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        onCameraDidChangeTrackingStateAction?(session, camera.trackingState)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        onDidUpdateFrameAction?(session, frame)
    }
}

/// A proxy for the ARSwiftUIView.
@MainActor
class ARSwiftUIViewProxy: NSObject, @preconcurrency ARSessionProviding {
    /// The underlying AR view.
    /// This is set by the ARSwiftUIView when it is available.
    fileprivate var arView: ARViewType!
    
    /// The AR session.
    @objc dynamic var session: ARSession {
        arView.session
    }
    
    /// The scene.
    var scene: RealityKit.Scene {
        arView.scene
    }
}

extension ARSwiftUIViewProxy {
    /// Performs a raycast to get the transformation matrix representing the corresponding
    /// real-world point for `screenPoint`.
    ///
    /// The method returns `nil` when the raycast query or the raycast fails. They can fail due to
    /// certain limitations, such as reflective or irregular surfaces, poorly lit environment that
    /// reduces the amount of visible objects, distance between the camera and the object being
    /// too far, camera occlusion that blocks the rays, etc.
    /// - Parameters:
    ///   - screenPoint: The screen point to determine the real world transformation matrix from.
    ///   - target: The type of surface the raycast can interact with.
    /// - Returns: A `TransformationMatrix` representing the real-world point corresponding to `screenPoint`.
    @MainActor func raycast(from screenPoint: CGPoint, allowing target: ARRaycastQuery.Target) -> TransformationMatrix? {
        // Use the `raycast` method on ARView to get the location of `screenPoint`.
        let results = arView.raycast(
            from: screenPoint,
            allowing: target,
            alignment: .any
        )
        // Get the worldTransform from the first result; if there's no worldTransform, return nil.
        guard let worldTransform = results.first?.worldTransform else { return nil }
        
        // Create our raycast matrix based on the worldTransform location.
        // Right now we ignore the orientation of the plane that was hit to find the point
        // since we only use horizontal planes.
        // If we start supporting vertical planes we will have to stop suppressing the
        // quaternion rotation to a null rotation (0,0,0,1).
        let raycastMatrix = TransformationMatrix.normalized(
            quaternionX: 0,
            quaternionY: 0,
            quaternionZ: 0,
            quaternionW: 1,
            translationX: Double(worldTransform.columns.3.x),
            translationY: Double(worldTransform.columns.3.y),
            translationZ: Double(worldTransform.columns.3.z)
        )
        
        return raycastMatrix
    }
}
#endif
