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

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
@MainActor
final class GeoTrackingCameraFeedHandler: AppleCameraFeedHandler {
    private let context: WorldScaleSceneView<AppleWorldTracking>.Context

    private var currentLocation: Location?
    private var currentHeading: Double?
    private var isLocalized = false

    init(context: WorldScaleSceneView<AppleWorldTracking>.Context) {
        self.context = context
    }

    func updateLocation(_ location: Location, sceneCamera _: Camera?) {
        currentLocation = location
    }

    func updateHeading(_ heading: Double) {
        currentHeading = heading
    }

    func handleFrame(_ camera: ARCamera, sceneCamera _: Camera?) {
        if isLocalized,
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

    func handleStatus(_ status: ARGeoTrackingStatus) {
        switch status.state {
        case .notAvailable, .initializing, .localizing:
            isLocalized = false
            context.resetLocalization()
        case .localized:
            isLocalized = true
        @unknown default:
            fatalError("Unknown ARGeoTrackingStatus.State")
        }
    }
}
#endif
