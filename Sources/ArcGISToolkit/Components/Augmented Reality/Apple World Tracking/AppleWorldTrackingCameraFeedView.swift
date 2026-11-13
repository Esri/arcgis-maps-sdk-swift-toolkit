// Copyright 2026 Esri
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
import CoreLocation
import SwiftUI

/// The camera scene view corresponding to `AppleWorldTracking`.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public struct AppleWorldTrackingCameraFeedView: View {
    /// Shared world-scale context used to read provider state and update the
    /// scene.
    let context: WorldScaleSceneView<AppleWorldTracking>.Context
    
    /// Creates an instance using the provided world-scale scene context.
    /// - Parameter context: The world-scale scene context backing this view.
    public init(context: WorldScaleSceneView<AppleWorldTracking>.Context) {
        self.context = context
    }
    
    /// The closure to perform when the camera tracking state changes.
    private var onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
    /// The closure to perform when the geo tracking status changes.
    private var onGeoTrackingStatusChangedAction: ((ARGeoTrackingStatus) -> Void)?
    
    /// The current camera of the scene view.
    @Environment(CameraWrapper.self) private var currentCameraWrapper
    
    /// The current camera derived from the latest scene view camera wrapper.
    var currentCamera: Camera? { currentCameraWrapper.camera }
    
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    /// The timestamp of the last received location.
    @State private var lastLocationTimestamp: Date?
    /// The current device location.
    @State private var currentLocation: Location?
    /// The current device heading in degrees.
    @State private var currentHeading: Double?
    /// The latest location waiting for a world-tracking pose to re-anchor.
    @State private var pendingWorldTrackingLocation: Location?
    /// Whether GeoTracking is localized and ready to establish a camera baseline.
    @State private var geoTrackingIsLocalized = false
    /// The offset that rebases camera poses at localization.
    @State private var localizationOffset: TransformationMatrix?
    
    public var body: some View {
        SwiftUIARView(sessionProvider: context.provider.arSessionProvider)
            .onDidUpdateFrame { _, frame in
                let camera = frame.camera

                if context.provider.mode == .worldTracking,
                   let pendingWorldTrackingLocation {
                    self.pendingWorldTrackingLocation = nil
                    updateWorldTrackingSceneView(
                        for: pendingWorldTrackingLocation,
                        camera: camera
                    )
                }

                if context.provider.mode != .worldTracking,
                   geoTrackingIsLocalized,
                   !context.isLocalized,
                   let currentLocation,
                   let currentHeading {
                    updateCameraController(
                        location: currentLocation,
                        heading: currentHeading,
                        altitude: currentLocation.position.z ?? 0,
                        camera: camera
                    )
                    context.isLocalized = true
                }

                guard let interfaceOrientation, context.isLocalized else { return }
                
                context.sceneView.updateCamera(
                    camera: camera,
                    cameraController: context.cameraController,
                    orientation: interfaceOrientation,
                    initialTransformation: localizationOffset ?? .identity
                )
                context.sceneView.setFieldOfView(
                    for: camera,
                    orientation: interfaceOrientation
                )
            }
            .onDidChangeGeoTrackingStatus { session, status in
                handleGeoTrackingStatusChange(status, camera: session.currentFrame?.camera)
                onGeoTrackingStatusChangedAction?(status)
            }
            .onCameraDidChangeTrackingState { _, newTrackingState in
                onCameraTrackingStateChangedAction?(newTrackingState)
            }
            .observingInterfaceOrientation($interfaceOrientation)
            .task {
                for await location in context.provider.dataSource.locations {
                    lastLocationTimestamp = location.timestamp
                    currentLocation = location
                    if context.provider.mode == .worldTracking {
                        // Call the method to check if world tracking session
                        // needs to be updated.
                        updateWorldTrackingSceneView(for: location)
                    }
                }
            }
            .task {
                for await heading in context.provider.dataSource.headings {
                    currentHeading = heading
                }
            }
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public extension AppleWorldTrackingCameraFeedView {
    /// Sets a closure to perform when the camera tracking state changes.
    /// - Parameter action: The closure to perform when the camera tracking
    /// state has changed.
    func onCameraTrackingStateChanged(
        perform action: @escaping (_ cameraTrackingState: ARCamera.TrackingState) -> Void
    ) -> Self {
        var copy = self
        copy.onCameraTrackingStateChangedAction = action
        return copy
    }
    
    /// Sets a closure to perform when the geo tracking status changes.
    /// - Parameter action: The closure to perform when the geo tracking status
    /// has changed.
    func onGeoTrackingStatusChanged(
        perform action: @escaping (
            _ geoTrackingStatus: ARGeoTrackingStatus
        ) -> Void
    ) -> Self {
        var copy = self
        copy.onGeoTrackingStatusChangedAction = action
        return copy
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
private extension AppleWorldTrackingCameraFeedView /* Geo Tracking */ {
    /// Updates localization state and initial camera setup when geo-tracking
    /// status changes.
    /// - Parameters:
    ///   - status: The latest geo-tracking status from ARKit.
    ///   - camera: The current AR camera pose, if a frame is available.
    func handleGeoTrackingStatusChange(_ status: ARGeoTrackingStatus, camera: ARCamera?) {
        switch status.state {
        case .notAvailable, .initializing, .localizing:
            geoTrackingIsLocalized = false
            localizationOffset = nil
            context.isLocalized = false
        case .localized:
            geoTrackingIsLocalized = true
            if !context.isLocalized,
               let camera,
               let currentLocation,
               let currentHeading {
                updateCameraController(
                    location: currentLocation,
                    heading: currentHeading,
                    altitude: currentLocation.position.z ?? 0,
                    camera: camera
                )
                context.isLocalized = true
            }
        @unknown default:
            fatalError("Unknown ARGeoTrackingStatus.State")
        }
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
private extension AppleWorldTrackingCameraFeedView /* Localization */ {
    /// Updates the camera controller with a geographic anchor and its AR pose.
    /// - Parameters:
    ///   - location: The location for the camera.
    ///   - heading: The geographic heading for the camera.
    ///   - altitude: The altitude for the camera.
    ///   - camera: The AR camera pose at localization.
    func updateCameraController(
        location: Location,
        heading: Double,
        altitude: Double,
        camera: ARCamera
    ) {
        let correctedAltitude = altitude + context.calibration.totalElevationCorrection
        let correctedHeading = heading + context.calibration.totalHeadingCorrection
        localizationOffset = makeLocalizationOffset(for: camera.transform)
        context.cameraController.originCamera = Camera(
            latitude: location.position.y,
            longitude: location.position.x,
            altitude: correctedAltitude,
            heading: correctedHeading,
            pitch: 90,
            roll: 0
        )
        // We have to do this or the error gets bigger and bigger.
        context.cameraController.transformationMatrix = .identity
    }

    /// Rebases the camera pose to the AR world position and yaw at localization.
    /// - Parameter cameraTransform: The camera transform in AR world space.
    /// - Returns: An offset that removes the localization position and yaw.
    func makeLocalizationOffset(for cameraTransform: simd_float4x4) -> TransformationMatrix {
        let inverseYaw = simd_quatf(
            angle: Float(-cameraYaw(for: cameraTransform)),
            axis: SIMD3<Float>(0, 1, 0)
        )
        let cameraPosition = SIMD3<Float>(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )
        let localizationTransform = TransformationMatrix.normalized(
            quaternion: inverseYaw,
            translation: cameraPosition
        )

        return .identity.subtracting(localizationTransform)
    }

    /// The compass heading represented by an AR camera pose.
    /// - Parameter cameraTransform: The camera transform in compass-aligned AR world space.
    /// - Returns: The camera heading in degrees in the range [0, 360).
    func geographicHeading(for cameraTransform: simd_float4x4) -> Double {
        let degrees = cameraYaw(for: cameraTransform) * 180 / .pi
        let normalized = degrees.truncatingRemainder(dividingBy: 360)
        return normalized < 0 ? normalized + 360 : normalized
    }

    /// Returns the camera yaw in radians in compass-aligned AR world space.
    func cameraYaw(for cameraTransform: simd_float4x4) -> Double {
        let cameraForward = SIMD3<Float>(
            -cameraTransform.columns.2.x,
            -cameraTransform.columns.2.y,
            -cameraTransform.columns.2.z
        )
        return atan2(Double(cameraForward.x), Double(-cameraForward.z))
    }
}

private extension TransformationMatrix {
    /// Creates a normalized transformation matrix from a quaternion and translation.
    /// - Parameters:
    ///   - quaternion: The rotation to apply.
    ///   - translation: The translation in meters.
    static func normalized(
        quaternion: simd_quatf,
        translation: SIMD3<Float>
    ) -> TransformationMatrix {
        normalized(
            quaternionX: Double(quaternion.vector.x),
            quaternionY: Double(quaternion.vector.y),
            quaternionZ: Double(quaternion.vector.z),
            quaternionW: Double(quaternion.real),
            translationX: Double(translation.x),
            translationY: Double(translation.y),
            translationZ: Double(translation.z)
        )
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
private extension AppleWorldTrackingCameraFeedView /* World Tracking */ {
    /// The maximum age in seconds for a location used to re-anchor the scene.
    var timeThreshold: Double { 10 }
    
    /// Queues a camera re-anchor when the location changes significantly.
    /// - Parameter location: The location data source location.
    func updateWorldTrackingSceneView(for location: Location) {
        // Do not update the scene view when the coaching overlay is in place.
        guard !context.isCoaching else { return }
        
        // Do not use cached location more than 10 seconds old.
        guard abs(lastLocationTimestamp?.timeIntervalSinceNow ?? 0) < timeThreshold else { return }
        
        // Make sure that horizontal and vertical accuracy are valid.
        guard location.horizontalAccuracy >= .zero,
              location.verticalAccuracy >= .zero else { return }
        
        // Make sure we need to update the camera based on distance deviation.
        guard !context.isLocalized || shouldUpdateCamera(for: location) else { return }
        
        guard !context.isLocalized || !context.isCalibrating else { return }
        pendingWorldTrackingLocation = location
    }

    /// Re-anchors the scene to a location using the current AR camera pose.
    /// - Parameters:
    ///   - location: The location data source location.
    ///   - camera: The AR camera pose for the current frame.
    func updateWorldTrackingSceneView(for location: Location, camera: ARCamera) {
        guard !context.isCoaching,
              abs(location.timestamp.timeIntervalSinceNow) < timeThreshold,
              location.horizontalAccuracy >= .zero,
              location.verticalAccuracy >= .zero,
              !context.isLocalized || !context.isCalibrating else {
            return
        }

        updateCameraController(
            location: location,
            heading: geographicHeading(for: camera.transform),
            altitude: location.position.z ?? 0,
            camera: camera
        )
        context.isLocalized = true
    }
    
    /// The distance threshold in meters between camera and device location to
    /// request a new anchor.
    var distanceThreshold: Double { 2 }
    
    /// Returns a Boolean value indicating if the camera should be updated for a
    /// location coming in from the location data source based on current camera
    /// deviation.
    /// - Parameter location: The location data source location.
    /// - Returns: A Boolean value indicating if the camera should be updated.
    func shouldUpdateCamera(for location: Location) -> Bool {
        guard let currentCamera, let currentLocation else { return false }
        
        // Measure the distance between the location datasource's reported
        // location and the camera's current location.
        guard let result = GeometryEngine.geodeticDistance(
            from: currentCamera.location,
            to: currentLocation.position,
            distanceUnit: .meters,
            azimuthUnit: nil,
            curveType: .geodesic
        ) else {
            return false
        }
        
        // If the location becomes off by over a certain threshold, then update
        // the camera location.
        return result.distance.value > distanceThreshold ? true : false
    }
}
#endif
