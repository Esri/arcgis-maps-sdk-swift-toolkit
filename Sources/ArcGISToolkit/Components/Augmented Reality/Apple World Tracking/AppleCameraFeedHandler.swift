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

/// Handles camera feed updates for an Apple world-tracking configuration.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
@MainActor
protocol AppleCameraFeedHandler: AnyObject {
    /// Processes a location update.
    /// - Parameters:
    ///   - location: The latest device location.
    ///   - sceneCamera: The current scene camera, if available.
    func updateLocation(_ location: Location, sceneCamera: Camera?)
    /// Processes a heading update.
    /// - Parameter heading: The latest device heading, in degrees.
    func updateHeading(_ heading: Double)
    /// Processes the AR camera for a frame.
    /// - Parameters:
    ///   - camera: The AR camera for the frame.
    ///   - sceneCamera: The current scene camera, if available.
    func handleFrame(_ camera: ARCamera, sceneCamera: Camera?)
    /// Processes a geo-tracking status update.
    /// - Parameter status: The latest geo-tracking status.
    func handleStatus(_ status: ARGeoTrackingStatus)
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
extension AppleCameraFeedHandler {
    func updateHeading(_: Double) {}
    func handleStatus(_: ARGeoTrackingStatus) {}
}
#endif
