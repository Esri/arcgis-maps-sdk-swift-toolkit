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

    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    /// The current device location.
    @State private var currentLocation: Location?
    /// The current device heading in degrees.
    @State private var currentHeading: Double?
    /// Whether GeoTracking is localized and ready to establish a camera baseline.
    @State private var geoTrackingIsLocalized = false
    /// The offset that rebases camera poses at localization.
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
                if geoTrackingIsLocalized,
                   !context.isLocalized,
                   let currentLocation,
                   let currentHeading {
                    localizationOffset = context.cameraController.reanchor(
                        to: currentLocation,
                        heading: currentHeading,
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
                    currentLocation = location
                }
            }
            .task {
                for await heading in context.provider.dataSource.headings {
                    currentHeading = heading
                }
            }
    }

    /// Updates localization state and camera setup when GeoTracking status changes.
    /// - Parameters:
    ///   - status: The latest GeoTracking status from ARKit.
    ///   - camera: The current AR camera pose, if a frame is available.
    private func handleGeoTrackingStatusChange(
        _ status: ARGeoTrackingStatus,
        camera: ARCamera?
    ) {
        switch status.state {
        case .notAvailable, .initializing, .localizing:
            geoTrackingIsLocalized = false
            localizationOffset = nil
            context.isLocalized = false
        case .localized:
            geoTrackingIsLocalized = true
            guard !context.isLocalized,
                  let camera,
                  let currentLocation,
                  let currentHeading else {
                return
            }
            localizationOffset = context.cameraController.reanchor(
                to: currentLocation,
                heading: currentHeading,
                calibration: context.calibration,
                camera: camera
            )
            context.isLocalized = true
        @unknown default:
            fatalError("Unknown ARGeoTrackingStatus.State")
        }
    }
}
#endif
