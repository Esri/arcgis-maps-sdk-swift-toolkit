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

import SwiftUI
import ArcGISToolkit
import ArcGIS

struct FloorFilterExampleView: View {
    private let map: Map
    
    @State
    private var viewpoint = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1_000_000
    )
    
    @State
    private var floorFilterViewModel: FloorFilterViewModel? = nil
    
    init() {
        // Create the map from a portal item and assign to the mapView.
        let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
        let portalItem = PortalItem(portal: portal, itemId: "f133a698536f44c8884ad81f80b6cfc7")
        map = Map(item: portalItem)
    }
    
    private let floorFilterPadding: CGFloat = 48
    
    var body: some View {
        MapView(
            map: map,
            viewpoint: viewpoint
        )
            .overlay(alignment: .bottomLeading) {
                if let viewModel = floorFilterViewModel {
                    FloorFilter(viewModel)
                        .padding(floorFilterPadding)
                }
            }
            .task {
                do {
                    try await map.load()
                    guard let floorManager = map.floorManager else { return }
                    floorFilterViewModel = FloorFilterViewModel(
                        floorManager: floorManager,
                        viewpoint: $viewpoint
                    )
                } catch  { }
            }
    }
}
