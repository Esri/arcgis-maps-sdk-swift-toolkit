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
    /// Whether GeoTracking is localized and ready to establish a camera baseline.
    @State private var geoTrackingIsLocalized = false
    /// The offset that rebases GeoTracking camera poses at localization.
    @State private var geoTrackingLocalizationOffset: TransformationMatrix?
    
    public var body: some View {
        SwiftUIARView(sessionProvider: context.provider.arSessionProvider)
            .onDidUpdateFrame { _, frame in
                let camera = frame.camera

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
                    initialTransformation: geoTrackingLocalizationOffset ?? .identity
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
            geoTrackingLocalizationOffset = nil
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
    
    /// Updates the scene view's camera controller with location and heading.
    /// - Parameters:
    ///   - location: The location for the camera.
    ///   - heading: The heading for the camera.
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
        geoTrackingLocalizationOffset = makeLocalizationOffset(for: camera.transform)
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
        let cameraForward = SIMD3<Float>(
            -cameraTransform.columns.2.x,
            -cameraTransform.columns.2.y,
            -cameraTransform.columns.2.z
        )
        let yaw = atan2(cameraForward.x, -cameraForward.z)
        let inverseYaw = simd_quatf(angle: -yaw, axis: SIMD3<Float>(0, 1, 0))
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
    /// The time threshold in seconds between location updates to reset the
    /// world-tracking session.
    var timeThreshold: Double { 10 }
    
    /// Updates the scene view's camera controller with a new location coming
    /// from the location data source and resets the AR session when using
    /// world-tracking configuration.
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
        
        let altitude = location.position.z ?? 0
        
        let newOriginCamera: Camera? = if !context.isLocalized {
            Camera(
                latitude: location.position.y,
                longitude: location.position.x,
                altitude: altitude,
                heading: 0,
                pitch: 90,
                roll: 0
            )
        } else if !context.isCalibrating {
            Camera(
                latitude: location.position.y,
                longitude: location.position.x,
                altitude: altitude + context.calibration.totalElevationCorrection,
                heading: context.calibration.totalHeadingCorrection,
                pitch: 90,
                roll: 0
            )
        } else {
            // Ignore location updates when calibrating heading and elevation.
            nil
        }
        
        guard let newOriginCamera else {
            return
        }
        
        context.cameraController.originCamera = newOriginCamera
        
        // We have to do this or the error gets bigger and bigger.
        context.cameraController.transformationMatrix = .identity
        
        context.provider.runARSession(options: .resetTracking)
        
        // If initial camera is not set, then we set it the flag here to true
        // and set the status text to empty.
        guard !context.isLocalized else { return }
        
        context.isLocalized = true
    }
    
    /// The distance threshold in meters between camera and device location to
    /// reset the world-tracking session.
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
