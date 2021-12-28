//
//  FloatingPanelExampleView.swift
//  Examples
//
//  Created by Mark Dostal on 12/16/21.
//

import SwiftUI
import ArcGISToolkit
import ArcGIS

struct FloatingPanelExampleView: View {
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

    var body: some View {
        MapView(
            map: map,
            viewpoint: searchResultViewpoint,
            graphicsOverlays: [searchResultsOverlay]
        )
            .onNavigatingChanged { searchViewModel.isGeoViewNavigating = $0 }
            .onViewpointChanged(kind: .centerAndScale) {
                searchViewModel.queryCenter = $0.targetGeometry as? Point
                
                // Reset `searchResultViewpoint` here when the user pans/zooms
                // the map, so if the user commits the same search with the
                // same result, the Map will pan/zoom to the result. Otherwise,
                // `searchResultViewpoint` doesn't change which doesn't
                // redraw the map with the new viewpoint.
                searchResultViewpoint = nil
            }
            .onVisibleAreaChanged { newValue in
                // Setting `searchViewModel.queryArea` will limit the
                // results to `queryArea`.
                //searchViewModel.queryArea = newValue

                // For "Repeat Search Here" behavior, set the
                // `searchViewModel.geoViewExtent` property when navigating.
                searchViewModel.geoViewExtent = newValue.extent
            }
            .overlay(alignment: .topTrailing) {
                FloatingPanel(
                    content:
                        SearchView(searchViewModel: searchViewModel)
                        .padding()
                )
                    .frame(width: 360)
            }
            .onAppear {
                searchViewModel.viewpoint = $searchResultViewpoint
                searchViewModel.resultsOverlay = searchResultsOverlay
            }
    }
}

//struct FloatingPanelExampleView: View {
//    let map = Map(basemapStyle: .arcGISImagery)
//
//    var body: some View {
//        FloatingPanel(content: MapView(map: map))
////        FloatingPanel(content: Rectangle().foregroundColor(.blue))
//            .padding()
//    }
//}

struct FloatingPanelExampleView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingPanelExampleView()
    }
}
