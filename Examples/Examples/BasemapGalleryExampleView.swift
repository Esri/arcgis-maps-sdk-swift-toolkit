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
import ArcGIS
import ArcGISToolkit

struct BasemapGalleryExampleView: View {
    /// The data model containing the `Map` displayed in the `MapView`.
    @StateObject private var dataModel = MapDataModel(
        map: Map(basemapStyle: .arcGISImagery)
    )
    
    /// A Boolean value indicating whether to show the basemap gallery.
    @State private var showBasemapGallery = false
    
    /// The initial viewpoint of the map.
    let initialViewpoint = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1_000_000
    )
    
    /// The initial list of basemaps.
    private let basemaps = initialBasemaps()
    
    var body: some View {
        MapView(map: dataModel.map, viewpoint: initialViewpoint)
            .overlay(alignment: .topTrailing) {
                if showBasemapGallery {
                    BasemapGallery(items: basemaps, geoModel: dataModel.map)
                        .style(.automatic())
                        .padding()
                }
            }
            .navigationTitle("Basemap Gallery")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $showBasemapGallery) {
                        Image("basemap", label: Text("Show base map"))
                    }
                }
            }
    }
    
    private static func initialBasemaps() -> [BasemapGalleryItem] {
        let identifiers = [
            "46a87c20f09e4fc48fa3c38081e0cae6",
            "f33a34de3a294590ab48f246e99958c9",
            "52bdc7ab7fb044d98add148764eaa30a",  // <<== mismatched spatial reference
            "3a8d410a4a034a2ba9738bb0860d68c4"   // <<== incorrect portal item type
        ]
        
        return identifiers.map { identifier in
            let url = URL(string: "https://www.arcgis.com/home/item.html?id=\(identifier)")!
            return BasemapGalleryItem(basemap: Basemap(item: PortalItem(url: url)!))
        }
    }
}
