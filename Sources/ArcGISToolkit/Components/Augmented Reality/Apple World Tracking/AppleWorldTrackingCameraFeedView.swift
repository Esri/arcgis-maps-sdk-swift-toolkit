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

    public var body: some View {
        if context.provider.mode == .worldTracking {
            WorldTrackingCameraFeedView(
                context: context,
                onCameraTrackingStateChangedAction: onCameraTrackingStateChangedAction,
                onGeoTrackingStatusChangedAction: onGeoTrackingStatusChangedAction
            )
        } else {
            GeoTrackingCameraFeedView(
                context: context,
                onCameraTrackingStateChangedAction: onCameraTrackingStateChangedAction,
                onGeoTrackingStatusChangedAction: onGeoTrackingStatusChangedAction
            )
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
extension TransformationMatrixCameraController {
    /// Sets the camera controller's geographic origin and resets its transformation
    /// matrix using a location and AR camera pose. Call
    /// `SceneViewProxy.updateCameraAndFieldOfView(from:using:orientation:initialTransformation:)`
    /// immediately after to apply the current AR camera pose.
    /// - Parameters:
    ///   - location: The geographic location for the new origin.
    ///   - heading: The geographic heading, in degrees, for the new origin.
    ///   - calibration: The elevation and heading corrections to apply.
    ///   - camera: The AR camera pose used to calculate the localization offset.
    /// - Returns: The offset that rebases subsequent camera poses to the localization pose.
    func reanchor(
        to location: Location,
        heading: Double,
        calibration: Calibration,
        camera: ARCamera
    ) -> TransformationMatrix {
        let correctedAltitude = (location.position.z ?? 0) + calibration.totalElevationCorrection
        let correctedHeading = heading + calibration.totalHeadingCorrection

        originCamera = Camera(
            latitude: location.position.y,
            longitude: location.position.x,
            altitude: correctedAltitude,
            heading: correctedHeading,
            pitch: 90,
            roll: 0
        )
        // Identity is only a reset value; it may not be the correct scene pose if
        // the scene draws before updateCameraAndFieldOfView applies the current AR pose.
        transformationMatrix = .identity

        return camera.localizationOffset
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
extension SceneViewProxy {
    /// Updates the scene camera and field of view using an AR camera frame.
    /// - Parameters:
    ///   - camera: The AR camera providing the pose and lens intrinsics.
    ///   - cameraController: The controller used to position the scene camera.
    ///   - orientation: The current interface orientation.
    ///   - initialTransformation: The transform offset established at localization.
    func updateCameraAndFieldOfView(
        from camera: ARCamera,
        using cameraController: TransformationMatrixCameraController,
        orientation: InterfaceOrientation,
        initialTransformation: TransformationMatrix
    ) {
        updateCamera(
            camera: camera,
            cameraController: cameraController,
            orientation: orientation,
            initialTransformation: initialTransformation
        )
        setFieldOfView(
            for: camera,
            orientation: orientation
        )
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
extension ARCamera {
    /// The compass heading represented by this camera pose.
    /// - Returns: The camera heading in degrees in the range [0, 360).
    var geographicHeading: Double {
        let degrees = geographicYaw * 180 / .pi
        let normalized = degrees.truncatingRemainder(dividingBy: 360)
        return normalized < 0 ? normalized + 360 : normalized
    }

    /// Rebases the camera pose to the AR world position and yaw at localization.
    /// - Returns: An offset that removes the localization position and yaw.
    var localizationOffset: TransformationMatrix {
        let inverseYaw = simd_quatf(
            angle: Float(-geographicYaw),
            axis: SIMD3<Float>(0, 1, 0)
        )
        let cameraPosition = SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
        let localizationTransform = TransformationMatrix.normalized(
            quaternion: inverseYaw,
            translation: cameraPosition
        )

        return .identity.subtracting(localizationTransform)
    }

    /// The camera yaw in radians in compass-aligned AR world space.
    private var geographicYaw: Double {
        let cameraForward = SIMD3<Float>(
            -transform.columns.2.x,
            -transform.columns.2.y,
            -transform.columns.2.z
        )
        return atan2(Double(cameraForward.x), Double(-cameraForward.z))
    }
}

private extension TransformationMatrix {
    /// Creates a normalized transformation matrix from a quaternion and translation.
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
#endif
