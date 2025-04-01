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

struct BasemapGalleryExampleView: View {
    /// A Boolean value indicating whether the basemap gallery is presented.
    @State private var basemapGalleryIsPresented = false
    
    /// The initial list of basemaps.
    @State private var basemaps = makeBasemapGalleryItems()
    
    /// The `Map` displayed in the `MapView`.
    @State private var map: Map = {
        let map = Map(basemapStyle: .arcGISImagery)
        map.initialViewpoint = Viewpoint(
            center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
            scale: 1_000_000
        )
        return map
    }()
    
    var body: some View {
        MapView(map: map)
            .sheet(isPresented: $basemapGalleryIsPresented) {
                VStack(alignment: .trailing) {
                    doneButton
                        .padding()
                    BasemapGallery(items: basemaps, geoModel: map)
                        .style(.grid(maxItemWidth: 100))
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $basemapGalleryIsPresented) {
                        Image("basemap", label: Text("Show base map"))
                    }
                }
            }
    }
    
    /// A button that allows a user to close a sheet.
    ///
    /// This is especially useful for when the sheet is open an iPhone in landscape.
    private var doneButton: some View {
        Button {
            basemapGalleryIsPresented.toggle()
        } label: {
            Text("Done")
        }
    }
    
    private static func makeBasemapGalleryItems() -> [BasemapGalleryItem] {
        [
            "46a87c20f09e4fc48fa3c38081e0cae6",
            "f33a34de3a294590ab48f246e99958c9",
            "52bdc7ab7fb044d98add148764eaa30a", // Mismatched spatial reference
            "3a8d410a4a034a2ba9738bb0860d68c4"  // Incorrect portal item type
        ]
            .map { identifier in
                BasemapGalleryItem(basemap: Basemap(item: PortalItem(
                    portal: .arcGISOnline(connection: .anonymous),
                    id: Item.ID(identifier)!)
                ))
            }
    }
}
