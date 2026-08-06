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
public import ARKit
public import SwiftUI

import ArcGIS
import CoreLocation

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
    
    public var body: some View {
        SwiftUIARView(sessionProvider: context.provider.arSessionProvider)
            .onDidUpdateFrame { _, frame in
                guard let interfaceOrientation, context.isLocalized else { return }
                
                let camera = frame.camera
                
                context.sceneView.updateCamera(
                    camera: camera,
                    cameraController: context.cameraController,
                    orientation: interfaceOrientation,
                    initialTransformation: .identity
                )
                context.sceneView.setFieldOfView(
                    for: camera,
                    orientation: interfaceOrientation
                )
            }
            .onDidChangeGeoTrackingStatus { _, status in
                handleGeoTrackingStatusChange(status)
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
    /// - Parameter status: The latest geo-tracking status from ARKit.
    func handleGeoTrackingStatusChange(_ status: ARGeoTrackingStatus) {
        switch status.state {
        case .notAvailable, .initializing, .localizing:
            context.isLocalized = false
        case .localized:
            // Update the camera controller every time geo-tracking is localized,
            // to ensure the best experience.
            if !context.isLocalized, let currentLocation, let currentHeading {
                // Set the initial heading of scene view camera based on location
                // and heading. Geo-tracking requires 90 degrees rotation.
                updateCameraController(
                    location: currentLocation,
                    heading: currentHeading + 90,
                    altitude: currentLocation.position.z ?? 0
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
    func updateCameraController(location: Location, heading: Double, altitude: Double) {
        let correctedAltitude = altitude + context.calibration.totalElevationCorrection
        let correctedHeading = heading + context.calibration.totalHeadingCorrection
        
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
