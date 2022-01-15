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
    private var floorFilterViewModel: FloorFilterViewModel? = nil
    
    init() {
        // Create the map from a portal item and assign to the mapView.
        let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
            let portalItem = PortalItem(portal: portal, itemId: "49520a67773842f1858602735ef538b5") //<= multiple sites/facilities
//        let portalItem = PortalItem(portal: portal, itemId: "f133a698536f44c8884ad81f80b6cfc7") //<= single site/facility
        map = Map(item: portalItem)
//        
//        Task {
//            do {
//                let map2 = Map(item: portalItem)
//                try await map2.load()
//                print("map2.loadStatus = \(map2.loadStatus)")
//            }
//            catch {
//                print("error: \(error)")
//            }
//        }
        
//        Task {
//            // Create the map from a portal item and assign to the mapView.
//            let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
//            let portalItem = PortalItem(portal: portal, itemId: "49520a67773842f1858602735ef538b5") //<= multiple sites/facilities
//            //        let portalItem = PortalItem(portal: portal, itemId: "f133a698536f44c8884ad81f80b6cfc7") //<= single site/facility
//            await ArcGISURLSession.credentialStore.add(try await .indoors)
//            map = Map(item: portalItem)
//        }
            
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
                var floorManager: FloorManager?
                do {
                    try await map.load()
                    floorManager = map.floorManager
                    try await floorManager?.load()
                } catch {
                    print("FloorManager.loadStatus = \(String(describing: floorManager?.loadStatus))")
                    print("load error: \(error)")
                }
            }
    }
}
