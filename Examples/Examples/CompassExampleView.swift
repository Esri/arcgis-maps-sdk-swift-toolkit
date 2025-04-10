// Copyright 2022 Esri
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

import ArcGIS
import ArcGISToolkit
import SwiftUI

/// An example demonstrating how to use a compass with a map view.
struct CompassExampleView: View {
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    /// Allows for communication between the Compass and MapView or SceneView.
    @State private var viewpoint: Viewpoint? = .esriRedlands
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: map, viewpoint: viewpoint)
                .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
                .overlay(alignment: .topTrailing) {
                    Compass(rotation: viewpoint?.rotation, mapViewProxy: proxy)
                        .snapToZeroSensoryFeedbackIfAvailable()
                        .padding()
                }
        }
    }
}

private extension Compass {
    /// Enables the sensory feedback when the compass snaps to `zero`
    /// when sensory feedback is available.
    @ViewBuilder
    func snapToZeroSensoryFeedbackIfAvailable() -> some View {
        snapToZeroSensoryFeedback()
    }
}

private extension Viewpoint {
    static var esriRedlands: Viewpoint {
        .init(
            center: .init(x: -117.19494, y: 34.05723, spatialReference: .wgs84),
            scale: 10_000,
            rotation: -45
        )
    }
}
