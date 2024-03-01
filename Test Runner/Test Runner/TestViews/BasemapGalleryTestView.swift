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

struct BasemapGalleryTestView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    @State private var basemaps = makeBasemapGalleryItems()
    
    var body: some View {
        MapView(map: map)
            .sheet(isPresented: .constant(true)) {
                BasemapGallery(items: basemaps, geoModel: map)
                    .style(.grid(maxItemWidth: 100))
            }
    }
    
    private static func makeBasemapGalleryItems() -> [BasemapGalleryItem] {
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
