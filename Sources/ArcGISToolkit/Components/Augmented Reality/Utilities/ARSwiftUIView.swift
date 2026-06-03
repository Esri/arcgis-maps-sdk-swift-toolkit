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

/// A SwiftUI version of an AR view.
public struct ARSwiftUIView {
    /// The closure to call when the session's geo-tracking state changes.
    private var onDidChangeGeoTrackingStatusAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
    /// The closure to call when the session's camera tracking state changes.
    private var onCameraDidChangeTrackingStateAction: ((ARSession, ARCamera.TrackingState) -> Void)?
    /// The closure to call when the session's frame updates.
    private var onDidUpdateFrameAction: ((ARSession, ARFrame) -> Void)?
    /// The closure to call when a new plane anchor has been added to the view.
    private var onAddAnchorAction: (@MainActor (ARPlaneAnchor) -> Void)?
    /// The closure to call when a plane anchor has been updated.
    private var onUpdateAnchorAction: (@MainActor (ARPlaneAnchor) -> Void)?
    /// The closure to call when the session is interrupted.
    private var onSessionWasInterruptedAction: ((ARSession) -> Void)?
    /// The closure to call when the session interruption ends.
    private var onSessionInterruptionEndedAction: ((ARSession) -> Void)?
    /// The AR session provider for the AR view.
    private let sessionProvider: ARSessionProvider<ARView>
    
    /// Creates an instance with the given session provider.
    /// - Parameter sessionProvider: The session provider which will have its
    /// view set when available.
    public init(sessionProvider: ARSessionProvider<ARView>) {
        self.sessionProvider = sessionProvider
    }
}

public extension ARSwiftUIView {
    /// Sets the closure to call when the session's geo-tracking state changes.
    ///
    /// ARKit invokes the callback only for `ARGeoTrackingConfiguration` sessions.
    func onDidChangeGeoTrackingStatus(
        perform action: @escaping (ARSession, ARGeoTrackingStatus) -> Void
    ) -> Self {
        var copy = self
        copy.onDidChangeGeoTrackingStatusAction = action
        return copy
    }
    
    /// Sets the closure to call when session's camera tracking state changes.
    func onCameraDidChangeTrackingState(
        perform action: @escaping (ARSession, ARCamera.TrackingState) -> Void
    ) -> Self {
        var copy = self
        copy.onCameraDidChangeTrackingStateAction = action
        return copy
    }
    
    /// Sets the closure to call when underlying scene renders.
    func onDidUpdateFrame(
        perform action: @escaping (ARSession, ARFrame) -> Void
    ) -> Self {
        var copy = self
        copy.onDidUpdateFrameAction = action
        return copy
    }
    
    /// Sets the closure to call when a new plane anchor has been added to the scene.
    func onAddAnchor(
        perform action: @escaping @MainActor (ARPlaneAnchor) -> Void
    ) -> Self {
        var copy = self
        copy.onAddAnchorAction = action
        return copy
    }
    
    /// Sets the closure to call when the a plane anchor is updated.
    func onUpdateAnchor(
        perform action: @escaping @MainActor (ARPlaneAnchor) -> Void
    ) -> Self {
        var copy = self
        copy.onUpdateAnchorAction = action
        return copy
    }
    
    /// Sets the closure to call when the session is interrupted.
    func onSessionWasInterrupted(
        perform action: @escaping (ARSession) -> Void
    ) -> Self {
        var copy = self
        copy.onSessionWasInterruptedAction = action
        return copy
    }
    
    /// Sets the closure to call when the session interruption ends.
    func onSessionInterruptionEnded(
        perform action: @escaping (ARSession) -> Void
    ) -> Self {
        var copy = self
        copy.onSessionInterruptionEndedAction = action
        return copy
    }
}

extension ARSwiftUIView: UIViewRepresentable {
    public func makeUIView(context: Context) -> ARView {
        let arView = ARView()
        arView.session.delegate = context.coordinator
        sessionProvider.arView = arView
        return arView
    }
    
    public func updateUIView(_: ARView, context: Context) {
        context.coordinator.arSwiftUIView = self
    }
    
    public class Coordinator: NSObject {
        var arSwiftUIView: ARSwiftUIView
        
        init(arSwiftUIView: ARSwiftUIView) {
            self.arSwiftUIView = arSwiftUIView
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return .init(arSwiftUIView: self)
    }
}

extension ARSwiftUIView.Coordinator: ARSessionDelegate {
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            // Filter new plane anchors to use for horizontal plane visualization.
            guard let planeAnchor = anchor as? ARPlaneAnchor else { continue }
            Task { @MainActor [onAddAnchorAction = arSwiftUIView.onAddAnchorAction] in
                onAddAnchorAction?(planeAnchor)
            }
        }
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            // Filter updated plane anchors to use for horizontal plane visualization.
            guard let planeAnchor = anchor as? ARPlaneAnchor else { continue }
            Task { @MainActor [onUpdateAnchorAction = arSwiftUIView.onUpdateAnchorAction] in
                onUpdateAnchorAction?(planeAnchor)
            }
        }
    }
    
    public func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
        arSwiftUIView.onDidChangeGeoTrackingStatusAction?(session, geoTrackingStatus)
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        arSwiftUIView.onCameraDidChangeTrackingStateAction?(session, camera.trackingState)
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        arSwiftUIView.onDidUpdateFrameAction?(session, frame)
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        arSwiftUIView.onSessionWasInterruptedAction?(session)
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        arSwiftUIView.onSessionWasInterruptedAction?(session)
    }
    
    public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}

/// A class that provides an AR session from an underlying AR view.
@MainActor
public class ARSessionProvider<ARViewType: ARView>: NSObject, @preconcurrency ARSessionProviding {
    /// The underlying AR view.
    public var arView: ARViewType!
    
    /// The AR session.
    @objc public dynamic var session: ARSession { arView.session }
    
    /// The scene.
    public var scene: RealityKit.Scene { arView.scene }
}

public extension ARView {
    /// Performs a raycast to get the transformation matrix representing the
    /// corresponding real-world point for `screenPoint`.
    ///
    /// This method returns `nil` when the raycast query or the raycast fails.
    /// They can fail due to certain limitations, such as reflective or
    /// irregular surfaces, poorly lit environment that reduces the amount of
    /// visible objects, distance between the camera and the object being too
    /// far, camera occlusion that blocks the rays, etc.
    /// - Parameters:
    ///   - screenPoint: The screen point from which to determine the real world
    ///   transformation matrix.
    ///   - target: The type of surface the raycast can interact with.
    /// - Returns: A transformation matrix representing the real-world point
    /// corresponding to `screenPoint`.
    @MainActor func raycast(
        from screenPoint: CGPoint,
        allowing target: ARRaycastQuery.Target
    ) -> TransformationMatrix? {
        // Use the 'raycast' method to get the location of 'screenPoint'.
        let results = raycast(from: screenPoint, allowing: target, alignment: .any)
        // Get the world transform from the first result or return 'nil'.
        guard let worldTransform = results.first?.worldTransform else { return nil }
        
        // Create our raycast matrix based on the 'worldTransform' location.
        // Right now we ignore the orientation of the plane that was hit to find
        // the point since we only use horizontal planes.
        //
        // If we start supporting vertical planes we will have to stop
        // suppressing the quaternion rotation to a null rotation (0,0,0,1).
        return .normalized(
            quaternionX: 0,
            quaternionY: 0,
            quaternionZ: 0,
            quaternionW: 1,
            translationX: Double(worldTransform.columns.3.x),
            translationY: Double(worldTransform.columns.3.y),
            translationZ: Double(worldTransform.columns.3.z)
        )
    }
}
#endif
