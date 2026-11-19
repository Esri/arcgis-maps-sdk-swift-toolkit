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

/// Displays the camera feed and scene using GeoTracking localization.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
struct GeoTrackingCameraFeedView: View {
    let context: WorldScaleSceneView<AppleWorldTracking>.Context
    let onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
    let onGeoTrackingStatusChangedAction: ((ARGeoTrackingStatus) -> Void)?

    /// The current device location.
    @State private var currentLocation: Location?
    /// The current device heading in degrees.
    @State private var currentHeading: Double?
    /// Whether GeoTracking is localized and ready to establish a camera baseline.
    @State private var geoTrackingIsLocalized = false
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
                guard context.interfaceOrientation != nil else { return }

                let camera = frame.camera

                if geoTrackingIsLocalized,
                   !context.isLocalized,
                   let currentLocation,
                   let currentHeading {
                    context.localize(
                        to: currentLocation,
                        heading: currentHeading,
                        camera: camera
                    )
                } else if context.isLocalized {
                    context.updateCamera(from: camera)
                }
            }
            .onDidChangeGeoTrackingStatus { _, status in
                handleGeoTrackingStatusChange(status)
                onGeoTrackingStatusChangedAction?(status)
            }
            .onCameraDidChangeTrackingState { _, newTrackingState in
                onCameraTrackingStateChangedAction?(newTrackingState)
            }
            .task {
                for await location in context.provider.dataSource.locations {
                    currentLocation = location
                }
            }
            .task {
                for await heading in context.provider.dataSource.headings {
                    currentHeading = heading
                }
            }
    }

    /// Updates localization state when GeoTracking status changes.
    /// - Parameter status: The latest GeoTracking status from ARKit.
    private func handleGeoTrackingStatusChange(_ status: ARGeoTrackingStatus) {
        switch status.state {
        case .notAvailable, .initializing, .localizing:
            geoTrackingIsLocalized = false
            context.resetLocalization()
        case .localized:
            geoTrackingIsLocalized = true
        @unknown default:
            fatalError("Unknown ARGeoTrackingStatus.State")
        }
    }
}
#endif
