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
    let searchViewModel = SearchViewModel(
        sources: [LocatorSearchSource(displayName: "Locator One"),
                  LocatorSearchSource(displayName: "Locator Two")]
    )
    
    @State
    var showResults = true
    
    @State
    private var viewpoint: Viewpoint?
    
    @State
    private var visibleArea: ArcGIS.Polygon?

    var body: some View {
        ZStack (alignment: .topTrailing) {
            MapViewReader { proxy in
                MapView(map: Map(basemap: Basemap.imageryWithLabels()))
                    .onViewpointChanged(type: .centerAndScale) {
                        searchViewModel.queryCenter = $0.targetGeometry as? Point
                    }
                    .onVisibleAreaChanged {
                        searchViewModel.queryArea = $0
                    }
                    .onChange(of: searchViewModel.results, perform: { results in
                        print("Search results changed")
                    })
                    .onChange(of: searchViewModel.suggestions, perform: { results in
                        print("Search suggestions changed")
                    })
                    .overlay(
                        SearchView(proxy: proxy, searchViewModel:searchViewModel)
                            .enableResultListView(showResults)
                            .frame(width: 360)
                            .padding(),
                        alignment: .topTrailing
                    )
                Button {
                    showResults.toggle()
                } label: {
                    Text(showResults ? "Hide results" : "Show results")
                }

            }
        }
    }
}

struct SearchExampleView_Previews: PreviewProvider {
    static var previews: some View {
        SearchExampleView()
    }
}
