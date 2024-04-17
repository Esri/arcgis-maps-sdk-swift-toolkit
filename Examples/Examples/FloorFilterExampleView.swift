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

struct FloorFilterExampleView: View {
    /// Determines the arrangement of the inner `FloorFilter` UI components.
    private var floorFilterAlignment: Alignment { .bottomLeading }
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight = 0.0
    
    /// Determines the appropriate time to initialize the `FloorFilter`.
    @State private var isMapLoaded = false
    
    /// A Boolean value indicating whether the map is currently being navigated.
    @State private var isNavigating = false
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(
        item: PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("b4b599a43a474d33946cf0df526426f5")!
        )
    )
    
    /// A Boolean value indicating whether an error was encountered while loading the map.
    @State private var mapLoadError = false
    
    /// The initial viewpoint of the map.
    @State private var viewpoint: Viewpoint? = Viewpoint(
        center: Point(
            x: -117.19496,
            y: 34.05713,
            spatialReference: .wgs84
        ),
        scale: 100_000
    )
    
    var body: some View {
        MapView(map: map, viewpoint: viewpoint)
            .onAttributionBarHeightChanged { newHeight in
                withAnimation { attributionBarHeight = newHeight }
            }
            .onNavigatingChanged {
                isNavigating = $0
            }
            .onViewpointChanged(kind: .centerAndScale) {
                viewpoint = $0
            }
            // Preserve the current viewpoint when a keyboard is presented in landscape.
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .overlay(alignment: floorFilterAlignment) {
                if isMapLoaded,
                   let floorManager = map.floorManager {
                    FloorFilter(
                        floorManager: floorManager,
                        alignment: floorFilterAlignment,
                        viewpoint: $viewpoint,
                        isNavigating: $isNavigating
                    )
                    .frame(
                        maxWidth: 400,
                        maxHeight: 400
                    )
                    .padding([.horizontal], 10)
                    .padding([.vertical], 10 + attributionBarHeight)
                } else if mapLoadError {
                    Label(
                        "Map load error!",
                        systemImage: "exclamationmark.triangle"
                    )
                    .foregroundColor(.red)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
                }
            }
            .task {
                do {
                    try await map.load()
                    isMapLoaded = true
                } catch {
                    mapLoadError = true
                }
            }
    }
}
