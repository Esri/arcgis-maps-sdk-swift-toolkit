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
    /// The map displayed in the map view.
    let map: Map
    
    /// The view model for the basemap gallery.
    @ObservedObject
    var viewModel: BasemapGalleryViewModel
    
    /// A Boolean value indicating whether to show the basemap gallery.
    @State
    private var showBasemapGallery: Bool = false
    
    /// The initial viewpoint of the map.
    let initialViewpoint = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1_000_000
    )
    
    init() {
        self.map = Map(basemapStyle: .arcGISImagery)
        self.viewModel = BasemapGalleryViewModel(
            geoModel: self.map,
            items: Self.initialBasemaps()
        )
    }
    
    var body: some View {
        MapView(map: map, viewpoint: initialViewpoint)
            .navigationTitle("Basemap Gallery")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showBasemapGallery.toggle()
                    } label: {
                        Image("basemap")
                    }
                    .popover(isPresented: $showBasemapGallery) {
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            NavigationView {
                                BasemapGallery(viewModel: viewModel)
                                    .navigationTitle("Basemaps")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarTrailing) {
                                            Button("Done") { showBasemapGallery = false }
                                        }
                                    }
                            }
                        } else {
                            BasemapGallery(viewModel: viewModel)
                                .padding()
                        }
                    }
                }
            }
    }
    
    static private func initialBasemaps() -> [BasemapGalleryItem] {
        let identifiers = [
            "46a87c20f09e4fc48fa3c38081e0cae6",
            "f33a34de3a294590ab48f246e99958c9"
        ]
        
        return identifiers.map { identifier in
            let url = URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=\(identifier)")!
            return BasemapGalleryItem(basemap: Basemap(item: PortalItem(url: url)!))
        }
    }
}
