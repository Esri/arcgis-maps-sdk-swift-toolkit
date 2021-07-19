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
    var searchViewModel = SearchViewModel(
        sources: [LocatorSearchSource(
            displayName: "Locator One",
            maximumResults: 16,
            maximumSuggestions: 16)]/*,
                                     LocatorSearchSource(displayName: "Locator Two")]*/
    )
    
    @State
    var showResults = true
    
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
            }
            .onVisibleAreaChanged {
                searchViewModel.queryArea = $0
            }
            .overlay(
                VStack {
                Button {
                    showResults.toggle()
                } label: {
                    Text(showResults ? "Hide results" : "Show results")
                }
                SearchView(searchViewModel: searchViewModel)
                    .enableResultListView(showResults)
                    .frame(width: 360)
                    .padding()
            },
                alignment: .topTrailing
            )
            .onChange(of: searchViewModel.results, perform: { searchResults in
                display(searchResults: searchResults)
            })
            .onChange(of: searchViewModel.selectedResult, perform: { _ in
                display(selectedResult: searchViewModel.selectedResult)
            })
    }
    
    fileprivate func display(searchResults: Result<[SearchResult]?, RuntimeError>) {
        let searchResultEnvelopeBuilder = EnvelopeBuilder(spatialReference: .wgs84)
        switch searchResults {
        case .success(let results):
            var resultGraphics = [Graphic]()
            results?.forEach({ result in
                if let extent = result.selectionViewpoint?.targetGeometry as? Envelope {
                    searchResultEnvelopeBuilder.union(envelope: extent)
                }
                let graphic = Graphic(geometry: result.geoElement?.geometry,
                                      symbol: .resultSymbol)
                resultGraphics.append(graphic)
                
            })
            let currentGraphics = searchResultsOverlay.graphics
            searchResultsOverlay.removeGraphics(currentGraphics)
            searchResultsOverlay.addGraphics(resultGraphics)
            
            if resultGraphics.count > 0,
               let envelope = searchResultEnvelopeBuilder.toGeometry() as? Envelope {
                searchResultViewpoint = Viewpoint(targetExtent: envelope)
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
    static let resultSymbol: MarkerSymbol = SimpleMarkerSymbol(
        style: .diamond,
        color: .red,
        size: 12.0
    )
}
