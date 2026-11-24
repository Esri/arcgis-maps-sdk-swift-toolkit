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

/// Localizes and re-anchors the scene using device location and ARKit world tracking.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
@MainActor
final class WorldTrackingCameraFeedHandler: AppleCameraFeedHandler {
    /// The world-scale scene context.
    private let context: WorldScaleSceneView<AppleWorldTracking>.Context

    /// The maximum age in seconds for a location used to re-anchor the scene.
    private var maxLocationAge: Double { 10 }
    /// The distance in meters that triggers a new camera anchor.
    private var reanchorDistanceThreshold: Double { 2 }

    /// The latest location used to determine whether to re-anchor.
    private var currentLocation: Location?
    /// A location to use for re-anchoring on the next camera frame.
    private var pendingReanchorLocation: Location?

    /// Creates a handler for the given world-scale scene context.
    init(context: WorldScaleSceneView<AppleWorldTracking>.Context) {
        self.context = context
    }

    func updateLocation(_ location: Location, sceneCamera: Camera?) {
        currentLocation = location
        queueReanchorIfNeeded(for: location, sceneCamera: sceneCamera)
    }

    func handleFrame(_ camera: ARCamera, sceneCamera _: Camera?) {
        if let location = pendingReanchorLocation.take() {
            context.localize(
                to: location,
                heading: camera.geographicHeading,
                camera: camera
            )
        } else if context.isLocalized {
            context.updateCamera(from: camera)
        }
    }

    /// Queues a camera re-anchor when the location changes significantly.
    /// - Parameter location: The location data source update to consider.
    private func queueReanchorIfNeeded(for location: Location, sceneCamera: Camera?) {
        guard !context.isCoaching,
              abs(location.timestamp.timeIntervalSinceNow) < maxLocationAge,
              location.horizontalAccuracy >= .zero,
              location.verticalAccuracy >= .zero,
              !context.isLocalized || shouldReanchor(sceneCamera: sceneCamera),
              !context.isLocalized || !context.isCalibrating else {
            return
        }

        pendingReanchorLocation = location
    }

    /// Determines whether the scene camera has deviated far enough to re-anchor.
    private func shouldReanchor(sceneCamera: Camera?) -> Bool {
        guard let sceneCamera, let currentLocation,
              let result = GeometryEngine.geodeticDistance(
                from: sceneCamera.location,
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
