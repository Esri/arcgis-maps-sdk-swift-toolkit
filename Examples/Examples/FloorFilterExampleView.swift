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
    /// Make a map from a portal item.
    static func makeMap() -> Map {
        Map(item: PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("b4b599a43a474d33946cf0df526426f5")!
        ))
    }
    
    /// Determines the arrangement of the inner `FloorFilter` UI componenets.
    private let floorFilterAlignment = Alignment.bottomLeading
    
    /// Determines the appropriate time to initialize the `FloorFilter`.
    @State private var isMapLoaded = false
    
    /// A Boolean value indicating whether the map is currently being navigated.
    @State private var isNavigating = false
    
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
    
    /// The data model containing the `Map` displayed in the `MapView`.
    @StateObject private var dataModel = MapDataModel(
        map: makeMap()
    )
    
    var body: some View {
        MapView(
            map: dataModel.map,
            viewpoint: viewpoint
        )
        .onNavigatingChanged {
            isNavigating = $0
        }
        .onViewpointChanged(kind: .centerAndScale) {
            viewpoint = $0
        }
        /// Preserve the current viewpoint when a keyboard is presented in landscape.
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay(alignment: floorFilterAlignment) {
            if isMapLoaded,
               let floorManager = dataModel.map.floorManager {
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
                .padding(36)
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
                try await dataModel.map.load()
                isMapLoaded = true
            } catch {
                mapLoadError = true
            }
        }
    }
}
