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
    @State private var map = Map(basemap: .init(baseLayer: OpenStreetMapLayer())) // Map(basemapStyle: .arcGISImagery)
    
    /// The location display to set on the map view.
    @State private var locationDisplay = {
        let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
        locationDisplay.initialZoomScale = 40_000
        return locationDisplay
    }()
    
    @State private var navModeEnabled = false
    
    var body: some View {
        Toggle("Nav mode", isOn: $navModeEnabled)
        Button {
            locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
            locationDisplay.initialZoomScale = 1_000
        } label: {
            Text("Switch LD")
        }
        MapView(map: map)
            .locationDisplay(locationDisplay)
            .overlay(alignment: .topTrailing) {
                LocationButton(locationDisplay: locationDisplay)
                    .autoPanOptions(autoPanOptions)
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding()
            }
    }
    
    var autoPanOptions: [LocationDisplay.AutoPanMode] {
        navModeEnabled
        ? [.navigation, .recenter]
        : [.compassNavigation, .recenter, .off]
    }
}
