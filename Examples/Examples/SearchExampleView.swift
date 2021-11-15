// Copyright 2021 Esri.

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
import Combine
import ArcGIS
import ArcGISToolkit

struct SearchExampleView: View {
    /// The `SearchViewModel` used to define behavior of the `SearchView`.
    @ObservedObject
    var searchViewModel = SearchViewModel(
        sources: [SmartLocatorSearchSource(
            name: "My locator",
            maximumResults: 16,
            maximumSuggestions: 16
        )]
    )
    
    let map = Map(basemapStyle: .arcGISImagery)
    
    /// The map viewpoint used by the `SearchView` to pan/zoom the map
    /// to the extent of the search results.
    @State
    private var searchResultViewpoint: Viewpoint? = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1000000
    )
    
    /// The `GraphicsOverlay` used by the `SearchView` to display search results on the map.
    let searchResultsOverlay = GraphicsOverlay()
    
    @State
    private var isNavigating: Bool = false

    var body: some View {
        MapView(
            map: map,
            viewpoint: searchResultViewpoint,
            graphicsOverlays: [searchResultsOverlay]
        )
            .onNavigatingChanged { isNavigating = $0 }
            .onViewpointChanged(kind: .centerAndScale) {
                searchViewModel.queryCenter = $0.targetGeometry as? Point
                
                // Reset `searchResultViewpoint` here when the user pans/zooms
                // the map, so if the user commits the same search with the
                // same result, the Map will pan/zoom to the result.  Otherwise
                // `searchResultViewpoint` doesn't change which doesn't
                // redraw the map with the new viewpoint.
                searchResultViewpoint = nil
            }
            .onVisibleAreaChanged { newValue in
                // Setting `searchViewModel.queryArea` will limit the
                // results to `queryArea`.
                //searchViewModel.queryArea = newValue

                // For "Repeat Search Here" behavior, set the
                // `searchViewModel.extent` property when navigating.
                if isNavigating || searchViewModel.geoViewExtent == nil {
                    searchViewModel.geoViewExtent = newValue.extent
                }
            }
            .overlay(alignment: .topTrailing) {
                SearchView(
                    searchViewModel: searchViewModel,
                    viewpoint: $searchResultViewpoint,
                    resultsOverlay: searchResultsOverlay
                )
                    .searchBarWidth(360.0)
                    .padding()
            }
    }
}
