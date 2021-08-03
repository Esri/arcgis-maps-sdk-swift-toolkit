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
//    enum MapOrScene {
//        /// The example shows a map view.
//        case map
//        /// The example shows a scene view.
//        case scene
//    }
//
//    @State
//    private var mapOrScene: MapOrScene = .map
    
    var basemapGalleryItems: [BasemapGalleryItem] = [
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISLightGray),
            name: "ArcGIS Light Gray",
            description: "A vector basemap for the world featuring a light neutral background style with minimal colors as the base layer and labels as the reference layer.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISNova),
            name: "ArcGIS Nova",
            description: "A vector basemap for the world featuring a dark background with glowing blue symbology inspired by science-fiction and futuristic themes.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISNewspaper),
            name: "ArcGIS Newspaper)",
            description: "A vector basemap in black & white design with halftone patterns, red highlights, and stylized fonts to depict a unique \"newspaper\" styled theme.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISNavigationNight),
            name: "ArcGIS NavigationNight",
            description: "A vector basemap for the world featuring a 'dark mode' version of the `Basemap.Style.arcGISNavigation` style, using the same content.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISStreets),
            name: "ArcGIS Streets",
            description: "A vector basemap for the world featuring a classic Esri street map style.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISTerrain),
            name: "ArcGIS Terrain",
            description: "A composite basemap with elevation hillshade (raster), minimal map content like water and land fill, water lines and roads (vector) as the base layers and minimal map content like populated place names, admin and water labels with boundary lines (vector) as the reference layer.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(style: .arcGISMidcentury),
            name: "ArcGIS Midcentury",
            description: "A vector basemap inspired by the art and advertising of the 1950's that presents a unique design option to the ArcGIS basemaps.",
            thumbnail: nil
        )
    ]
    
    var body: some View {
        Group {
            BasemapGallery(basemaps: basemapGalleryItems)
//            List {
//                ForEach(basemapGalleryItems) { basemapGalleryItem in
//                    Text(basemapGalleryItem.title)
//                }
//            }
        }
//        Picker("Map or Scene", selection: $mapOrScene, content: {
//            Text("Map").tag(MapOrScene.map)
//            Text("Scene").tag(MapOrScene.scene)
//        })
//            .pickerStyle(SegmentedPickerStyle())
//            .padding()
//        switch mapOrScene {
//        case .map:
//            OverviewMapForMapView()
//        case .scene:
//            OverviewMapForSceneView()
//        }
    }
}

struct BasemapGalleryExampleView_Previews: PreviewProvider {
    static var previews: some View {
        BasemapGalleryExampleView()
    }
}

// MARK: Extensions
