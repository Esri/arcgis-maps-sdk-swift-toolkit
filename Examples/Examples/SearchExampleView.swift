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
    @ObservedObject
    var searchViewModel = SearchViewModel()
    
    let map = Map(basemapStyle: .arcGISImagery)
    
    @State
    var searchResultViewpoint: Viewpoint? = nil
    
    var searchResultsOverlay = GraphicsOverlay()
    
    var body: some View {
        MapView(
            map: map,
            viewpoint: searchResultViewpoint,
            graphicsOverlays: [searchResultsOverlay]
        )
            .onViewpointChanged(kind: .centerAndScale) {
                searchViewModel.queryCenter = $0.targetGeometry as? Point
                
                // Reset `searchResultViewpoint` here when the user pans/zooms
                // the map, so if the user commits the same search with the
                // same result, the Map will pan/zoom to the result.  Otherwise
                // `searchResultViewpoint` doesn't change which doesn't
                // redraw the map with the new viewpoint.
                searchResultViewpoint = nil
            }
            .onVisibleAreaChanged {
                searchViewModel.queryArea = $0
            }
            .overlay(
                SearchView(searchViewModel: searchViewModel)
                    .frame(width: 360)
                    .padding(),
                alignment: .topTrailing
            )
            .onChange(of: searchViewModel.results, perform: { newValue in
                display(searchResults: newValue)
            })
            .onChange(of: searchViewModel.selectedResult, perform: { newValue in
                display(selectedResult: newValue)
            })
            .task {
                setupSearchViewModel()
            }
    }
    
    /// Sets up any desired customization on `searchViewModel`.
    private func setupSearchViewModel() {
        let smartLocator = SmartLocatorSearchSource(
            displayName: "Locator One",
            maximumResults: 16,
            maximumSuggestions: 16
        )
        searchViewModel.sources = [smartLocator]
    }
    
    fileprivate func display(searchResults: Result<[SearchResult]?, SearchError>) {
        switch searchResults {
        case .success(let results):
            var resultGraphics = [Graphic]()
            results?.forEach({ result in
                let graphic = Graphic(geometry: result.geoElement?.geometry,
                                      symbol: .resultSymbol)
                resultGraphics.append(graphic)
                
            })
            let currentGraphics = searchResultsOverlay.graphics
            searchResultsOverlay.removeGraphics(currentGraphics)
            searchResultsOverlay.addGraphics(resultGraphics)
            
            if resultGraphics.count > 0,
               let envelope = searchResultsOverlay.extent {
                let builder = EnvelopeBuilder(envelope: envelope)
                builder.expand(factor: 1.1)
                searchResultViewpoint = Viewpoint(targetExtent: builder.toGeometry())
            }
            else {
                searchResultViewpoint = nil
            }
        case .failure(_):
            break
        }
    }
    
    fileprivate func display(selectedResult: SearchResult?) {
        guard let selectedResult = selectedResult,
              let graphic = selectedResult.geoElement as? Graphic else { return }
        
        searchResultViewpoint = selectedResult.selectionViewpoint
        if graphic.symbol == nil {
            graphic.symbol = .resultSymbol
        }
        let currentGraphics = searchResultsOverlay.graphics
        searchResultsOverlay.removeGraphics(currentGraphics)
        searchResultsOverlay.addGraphic(graphic)
    }
}

struct SearchExampleView_Previews: PreviewProvider {
    static var previews: some View {
        SearchExampleView()
    }
}

private extension Symbol {
    /// A search result marker symbol.
    static let resultSymbol: MarkerSymbol = PictureMarkerSymbol(image: UIImage(named: "MapPin")!)
}
