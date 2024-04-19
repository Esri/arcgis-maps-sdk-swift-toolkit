// Copyright 2021 Esri
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

struct SearchExampleView: View {
    /// Provides search behavior customization.
    @State private var locatorSearchSource = SmartLocatorSearchSource(
        name: "My locator",
        maximumResults: 16,
        maximumSuggestions: 16
    )
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    /// The `GraphicsOverlay` used by the `SearchView` to display search results on the map.
    @State private var searchResultsOverlay = GraphicsOverlay()
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight = 0.0
    
    /// The map viewpoint used by the `SearchView` to pan/zoom the map
    /// to the extent of the search results.
    @State private var searchResultViewpoint: Viewpoint? = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1000000
    )
    
    /// Denotes whether the geoview is navigating. Used for the repeat search behavior.
    @State private var isGeoViewNavigating = false
    
    /// The current map/scene view extent. Used to allow repeat searches after panning/zooming the map.
    @State private var geoViewExtent: Envelope?
    
    /// The search area to be used for the current query.
    @State private var queryArea: Geometry?
    
    /// Defines the center for the search.
    @State private var queryCenter: Point?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(
                map: map,
                viewpoint: searchResultViewpoint,
                graphicsOverlays: [searchResultsOverlay]
            )
            .onAttributionBarHeightChanged { newValue in
                withAnimation { attributionBarHeight = newValue }
            }
            .onNavigatingChanged { isGeoViewNavigating = $0 }
            .onViewpointChanged(kind: .centerAndScale) {
                queryCenter = $0.targetGeometry as? Point
            }
            .onVisibleAreaChanged { newValue in
                // For "Repeat Search Here" behavior, use the `geoViewExtent` and
                // `isGeoViewNavigating` modifiers on the `SearchView`.
                geoViewExtent = newValue.extent
                
                // The visible area can be used to limit the results by
                // using the `queryArea` modifier on the `SearchView`.
//                queryArea = newValue
            }
            .overlay {
                SearchView(
                    sources: [locatorSearchSource],
                    viewpoint: $searchResultViewpoint,
                    geoViewProxy: mapViewProxy
                )
                .resultsOverlay(searchResultsOverlay)
//                .queryArea($queryArea)
                .queryCenter($queryCenter)
                .geoViewExtent($geoViewExtent)
                .isGeoViewNavigating($isGeoViewNavigating)
                .padding([.leading, .top, .trailing])
                .padding([.bottom], 10 + attributionBarHeight)
            }
        }
    }
}
