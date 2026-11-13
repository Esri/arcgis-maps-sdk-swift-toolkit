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
import Foundation
import SwiftUI

/// Displays the camera feed and scene using ARKit world tracking.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
struct WorldTrackingCameraFeedView: View {
    let context: WorldScaleSceneView<AppleWorldTracking>.Context
    let onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
    let onGeoTrackingStatusChangedAction: ((ARGeoTrackingStatus) -> Void)?

    /// The maximum age in seconds for a location used to re-anchor the scene.
    private var maxLocationAge: Double { 10 }
    /// The distance in meters that triggers a new camera anchor.
    private var reanchorDistanceThreshold: Double { 2 }

    /// The latest ArcGIS scene camera, used to measure location deviation.
    @Environment(CameraWrapper.self) private var currentCameraWrapper

    /// The current camera derived from the latest scene view camera wrapper.
    private var currentSceneCamera: Camera? { currentCameraWrapper.camera }

    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    /// The current device location.
    @State private var currentLocation: Location?
    /// The latest location waiting to be paired with an AR frame for re-anchoring.
    @State private var pendingReanchorLocation: Location?
    /// The offset that rebases camera poses at the current anchor.
    @State private var localizationOffset: TransformationMatrix?

    init(
        context: WorldScaleSceneView<AppleWorldTracking>.Context,
        onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?,
        onGeoTrackingStatusChangedAction: ((ARGeoTrackingStatus) -> Void)?
    ) {
        self.context = context
        self.onCameraTrackingStateChangedAction = onCameraTrackingStateChangedAction
        self.onGeoTrackingStatusChangedAction = onGeoTrackingStatusChangedAction
    }

    var body: some View {
        SwiftUIARView(sessionProvider: context.provider.arSessionProvider)
            .onDidUpdateFrame { _, frame in
                let camera = frame.camera
                if let location = pendingReanchorLocation.take() {
                    localizationOffset = context.cameraController.reanchor(
                        to: location,
                        heading: camera.geographicHeading,
                        calibration: context.calibration,
                        camera: camera
                    )
                    context.isLocalized = true
                }

                guard let interfaceOrientation, context.isLocalized else { return }
                context.sceneView.updateCameraAndFieldOfView(
                    from: camera,
                    using: context.cameraController,
                    orientation: interfaceOrientation,
                    initialTransformation: localizationOffset ?? .identity
                )
            }
            .onDidChangeGeoTrackingStatus { _, status in
                onGeoTrackingStatusChangedAction?(status)
            }
            .onCameraDidChangeTrackingState { _, newTrackingState in
                onCameraTrackingStateChangedAction?(newTrackingState)
            }
            .observingInterfaceOrientation($interfaceOrientation)
            .task {
                for await location in context.provider.dataSource.locations {
                    currentLocation = location
                    queueReanchorIfNeeded(for: location)
                }
            }
    }

    /// Queues a camera re-anchor when the location changes significantly.
    /// - Parameter location: The location data source update to consider.
    private func queueReanchorIfNeeded(for location: Location) {
        guard !context.isCoaching,
              abs(location.timestamp.timeIntervalSinceNow) < maxLocationAge,
              location.horizontalAccuracy >= .zero,
              location.verticalAccuracy >= .zero,
              !context.isLocalized || shouldUpdateCamera(),
              !context.isLocalized || !context.isCalibrating else {
            return
        }

        pendingReanchorLocation = location
    }

    /// Determines whether the scene camera has deviated far enough to re-anchor.
    private func shouldUpdateCamera() -> Bool {
        guard let currentSceneCamera, let currentLocation,
              let result = GeometryEngine.geodeticDistance(
                from: currentSceneCamera.location,
                to: currentLocation.position,
                distanceUnit: .meters,
                azimuthUnit: nil,
                curveType: .geodesic
              ) else {
            return false
        }
        return result.distance.value > reanchorDistanceThreshold
    }
}
#endif
