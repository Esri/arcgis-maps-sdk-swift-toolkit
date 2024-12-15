// Copyright 2024 Esri
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

/// An example demonstrating how to use the location button with a map view.
struct LocationButtonExampleView: View {
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    /// The location display to set on the map view.
    @State private var locationDisplay = {
        let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
        locationDisplay.autoPanMode = .recenter
        locationDisplay.initialZoomScale = 40_000
        return locationDisplay
    }()
    
    var body: some View {
        MapView(map: map)
            .locationDisplay(locationDisplay)
            .overlay(alignment: .topTrailing) {
                LocationButton(locationDisplay: locationDisplay)
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding()
            }
    }
}
