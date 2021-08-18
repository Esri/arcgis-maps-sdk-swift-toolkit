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
    var basemapGalleryItems: [BasemapGalleryItem] = [
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISLightGray),
            name: "ArcGIS Light Gray",
            description: "A vector basemap for the world featuring a light neutral background style with minimal colors as the base layer and labels as the reference layer.",
            thumbnail: UIImage(named: "LightGray")
            //            thumbnailURL: URL(string: "https://www.arcgis.com/sharing/rest/content/items/0f74af7609054be8a29e0ba5f154f0a8/info/thumbnail/thumbnail1607388219207.jpeg")!
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISNova),
            name: "ArcGIS Nova",
            description: "A vector basemap for the world featuring a dark background with glowing blue symbology inspired by science-fiction and futuristic themes.",
            thumbnail: UIImage(named: "Nova")
            //            thumbnailURL: URL(string: "https://www.arcgis.com/sharing/rest/content/items/90f86b329f37499096d3715ac6e5ed1f/info/thumbnail/thumbnail1607555507609.jpeg")!
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISNewspaper),
            name: "ArcGIS Newspaper",
            description: "A vector basemap in black & white design with halftone patterns, red highlights, and stylized fonts to depict a unique \"newspaper\" styled theme.",
            thumbnail: UIImage(named: "Newspaper")
            //            thumbnailURL: URL(string: "https://www.arcgis.com/sharing/rest/content/items/e3c062eedf8b487b8bb5b9b08db1b7a9/info/thumbnail/thumbnail1607553292807.jpeg")!
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISNavigationNight),
            name: "ArcGIS NavigationNight",
            description: "A vector basemap for the world featuring a 'dark mode' version of the `Basemap.Style.arcGISNavigation` style, using the same content.",
            thumbnail: UIImage(named: "NavigationNight")
            //            thumbnailURL: URL(string: "https://www.arcgis.com/sharing/rest/content/items/77073a29526046b89bb5622b6276e933/info/thumbnail/thumbnail1607386977674.jpeg")!
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISStreets),
            name: "ArcGIS Streets",
            description: "A vector basemap for the world featuring a classic Esri street map style.",
            thumbnail: UIImage(named: "Streets")
            //            thumbnailURL: URL(string: "https://www.arcgis.com/sharing/rest/content/items/e3e6df1d2f6a485d8a70f28fdd3ce19e/info/thumbnail/thumbnail1607389307240.jpeg")!
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISTerrain),
            name: "ArcGIS Terrain",
            description: "A composite basemap with elevation hillshade (raster), minimal map content like water and land fill, water lines and roads (vector) as the base layers and minimal map content like populated place names, admin and water labels with boundary lines (vector) as the reference layer.",
            thumbnail: UIImage(named: "Terrain")
            //            thumbnailURL: URL(string: "https://www.arcgis.com/sharing/rest/content/items/2ef1306b93c9459ca7c7b4f872c070b9/info/thumbnail/thumbnail1607387869592.jpeg")!
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISMidcentury),
            name: "ArcGIS Midcentury",
            description: "A vector basemap inspired by the art and advertising of the 1950's that presents a unique design option to the ArcGIS basemaps.",
            thumbnail: UIImage(named: "Midcentury")
            //            thumbnailURL: URL(string: "https://www.arcgis.com/sharing/rest/content/items/52d6a28f09704f04b33761ba7c4bf93f/info/thumbnail/thumbnail1607554184831.jpeg")!
        )
    ]
    
    let map = Map(basemapStyle: .arcGISNova)
    
    @State
    var showBasemapGallery: Bool = true  // NOTE: Set to false when BasemapGallery is back in the navigation stack.
    
    let initialViewpoint: Viewpoint? = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1000000
    )
    
    var body: some View {
        ZStack(alignment: .topTrailing, content: {
            MapView(map: map, viewpoint: initialViewpoint)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showBasemapGallery.toggle()
                        } label: {
                            Image(systemName: "map.fill")
                        }
                    }
                }
            if showBasemapGallery {
                BasemapGallery(
                    geoModel: map,
                    basemapGalleryItems: basemapGalleryItems
                )
                    .basemapGalleryStyle(.automatic)
                    .frame(width: 300)
                    .padding()
            }
        })
    }
}

struct BasemapGalleryExampleView_Previews: PreviewProvider {
    static var previews: some View {
        BasemapGalleryExampleView()
    }
}

// MARK: Extensions
