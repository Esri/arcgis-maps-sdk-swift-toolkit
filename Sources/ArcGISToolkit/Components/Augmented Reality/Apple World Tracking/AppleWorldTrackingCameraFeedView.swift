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
    @State private var geoTrackingCoordinator = GeoTrackingCoordinator()
    @State private var worldTrackingCoordinator = WorldTrackingCoordinator()
    /// The offset that rebases camera poses at localization.
    @State private var localizationOffset: TransformationMatrix?
    
    public var body: some View {
        SwiftUIARView(sessionProvider: context.provider.arSessionProvider)
            .onDidUpdateFrame { _, frame in
                let camera = frame.camera

                if context.provider.mode == .worldTracking,
                   let location = worldTrackingCoordinator.takePendingLocation(
                    isCoaching: context.isCoaching,
                    isLocalized: context.isLocalized,
                    isCalibrating: context.isCalibrating
                   ) {
                    updateCameraController(
                        location: location,
                        heading: geographicHeading(for: camera.transform),
                        altitude: location.position.z ?? 0,
                        camera: camera
                    )
                    context.isLocalized = true
                }

                if context.provider.mode != .worldTracking,
                   let baseline = geoTrackingCoordinator.cameraBaselineIfReady(
                    sceneIsLocalized: context.isLocalized,
                    location: currentLocation,
                    heading: currentHeading,
                    camera: camera
                   ) {
                    updateCameraController(
                        location: baseline.location,
                        heading: baseline.heading,
                        altitude: baseline.location.position.z ?? 0,
                        camera: baseline.camera
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
                        worldTrackingCoordinator.queueLocation(
                            location,
                            lastLocationTimestamp: lastLocationTimestamp,
                            currentCamera: currentCamera,
                            currentLocation: currentLocation,
                            isCoaching: context.isCoaching,
                            isLocalized: context.isLocalized,
                            isCalibrating: context.isCalibrating
                        )
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
        guard geoTrackingCoordinator.updateLocalizationStatus(status) else {
            localizationOffset = nil
            context.isLocalized = false
            return
        }

        guard let baseline = geoTrackingCoordinator.cameraBaselineIfReady(
            sceneIsLocalized: context.isLocalized,
            location: currentLocation,
            heading: currentHeading,
            camera: camera
        ) else {
            return
        }

        updateCameraController(
            location: baseline.location,
            heading: baseline.heading,
            altitude: baseline.location.position.z ?? 0,
            camera: baseline.camera
        )
        context.isLocalized = true
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
private struct GeoTrackingCoordinator {
    private(set) var isLocalized = false

    mutating func updateLocalizationStatus(_ status: ARGeoTrackingStatus) -> Bool {
        switch status.state {
        case .notAvailable, .initializing, .localizing:
            isLocalized = false
        case .localized:
            isLocalized = true
        @unknown default:
            fatalError("Unknown ARGeoTrackingStatus.State")
        }
        return isLocalized
    }

    func cameraBaselineIfReady(
        sceneIsLocalized: Bool,
        location: Location?,
        heading: Double?,
        camera: ARCamera?
    ) -> (location: Location, heading: Double, camera: ARCamera)? {
        guard isLocalized,
              !sceneIsLocalized,
              let location,
              let heading,
              let camera else {
            return nil
        }
        return (location, heading, camera)
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
private struct WorldTrackingCoordinator {
    private(set) var pendingLocation: Location?

    private let timeThreshold: Double = 10
    private let distanceThreshold: Double = 2

    mutating func queueLocation(
        _ location: Location,
        lastLocationTimestamp: Date?,
        currentCamera: Camera?,
        currentLocation: Location?,
        isCoaching: Bool,
        isLocalized: Bool,
        isCalibrating: Bool
    ) {
        guard !isCoaching,
              abs(lastLocationTimestamp?.timeIntervalSinceNow ?? 0) < timeThreshold,
              location.horizontalAccuracy >= .zero,
              location.verticalAccuracy >= .zero,
              !isLocalized || shouldUpdateCamera(
                currentCamera: currentCamera,
                currentLocation: currentLocation
              ),
              !isLocalized || !isCalibrating else {
            return
        }

        pendingLocation = location
    }

    mutating func takePendingLocation(
        isCoaching: Bool,
        isLocalized: Bool,
        isCalibrating: Bool
    ) -> Location? {
        guard let location = pendingLocation else { return nil }
        pendingLocation = nil

        guard !isCoaching,
              abs(location.timestamp.timeIntervalSinceNow) < timeThreshold,
              location.horizontalAccuracy >= .zero,
              location.verticalAccuracy >= .zero,
              !isLocalized || !isCalibrating else {
            return nil
        }

        return location
    }

    private func shouldUpdateCamera(
        currentCamera: Camera?,
        currentLocation: Location?
    ) -> Bool {
        guard let currentCamera, let currentLocation,
              let result = GeometryEngine.geodeticDistance(
                from: currentCamera.location,
                to: currentLocation.position,
                distanceUnit: .meters,
                azimuthUnit: nil,
                curveType: .geodesic
              ) else {
            return false
        }
        return result.distance.value > distanceThreshold
    }
}
#endif
