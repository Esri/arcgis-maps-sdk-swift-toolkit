// Copyright 2023 Esri
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

struct BookmarksTestCase6View: View {
    @State private var bookmarks = [
        Bookmark(
            name: "San Diego Convention Center",
            viewpoint: .sanDiegoConventionCenter
        )
    ]
    
    @State private var isPresented = true
    
    @State private var map = Map(basemapStyle: .arcGISCommunity)
    
    @State private var viewpoint: Viewpoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onViewpointChanged(kind: .centerAndScale) {
                    self.viewpoint = $0
                }
                .sheet(isPresented: $isPresented) {
                    Bookmarks(
                        isPresented: $isPresented,
                        bookmarks: bookmarks,
                        selection: .constant(nil),
                        geoViewProxy: mapViewProxy
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        if let center = viewpoint?.targetGeometry.extent.center,
                           let point = GeometryEngine.project(center, into: .wgs84) {
                            Text(
                                CoordinateFormatter.latitudeLongitudeString(
                                    from: point,
                                    format: .decimalDegrees,
                                    decimalPlaces: 1
                                )
                            )
                        }
                    }
                }
        }
    }
}

extension Viewpoint {
    static var sanDiegoConventionCenter: Self {
        .init(latitude: 32.706166, longitude: -117.161436, scale: 3_850)
    }
}
