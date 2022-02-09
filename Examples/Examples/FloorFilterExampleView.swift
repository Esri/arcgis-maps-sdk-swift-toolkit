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
    @State
    private var map: Map
    
    @State
    private var viewpoint = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1_000_000
    )
    
    @State
    private var floorManager: FloorManager? = nil

    init() {
        // Create the map from a portal item and assign to the mapView.
        
        // Multiple sites/facilities: Esri IST map with all buildings.
//        let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
//        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "49520a67773842f1858602735ef538b5")!)

        // Redlands Campus map.
//        let portal = Portal(url: URL(string: "https://runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
//        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "7687805bd42549f5ba41237443d0c60a")!) //<= another multiple sites/facilities

        // Single site (ESRI Redlands Main) and facility (Building L).
        let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "f133a698536f44c8884ad81f80b6cfc7")!)

        map = Map(item: portalItem)
    }
    
    private let floorFilterPadding: CGFloat = 48
    
    var body: some View {
        MapView(
            map: map,
            viewpoint: viewpoint
        )
            .overlay(alignment: .bottomLeading) {
                if let floorManager = floorManager {
                    FloorFilter(
                        floorManager: floorManager,
                        viewpoint: $viewpoint
                    )
                        .padding(floorFilterPadding)
                }
            }
            .task {
                do {
                    try await map.load()
                    floorManager = map.floorManager
                } catch {
                    print("load error: \(error)")
                }
            }
    }
}
