// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import SwiftUI

struct CompassExampleView: View {
    /// The map displayed in the map view.
    private let map = Map(basemapStyle: .arcGISImagery)

    /// Allows for communication between the Compass and MapView or SceneView.
    @State
    private var viewpoint = Viewpoint(
        center: Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84),
        scale: 10_000,
        rotation: -45
    )

    var body: some View {
        MapView(map: map, viewpoint: viewpoint)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .overlay(alignment: .topTrailing) {
                Compass(viewpoint: $viewpoint)
                    .frame(width: 44, height: 44)
                    .padding()
            }
    }
}
