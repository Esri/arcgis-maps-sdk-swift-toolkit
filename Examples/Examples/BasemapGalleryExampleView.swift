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

// TODO: once user taps on a map (or maybe in the view model setter for current item)
// TODO: then check if SRs match and don't set basemap if they don't.  Figure out
// TODO: how to then gray out the item in the gallery.

struct BasemapGalleryExampleView: View {
    var basemapGalleryItems: [BasemapGalleryItem] = [
        BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
                )!
            ),
            name: "OpenStreetMap (Blueprint)",
            description: "OpenStreetMap (OSM) is a collaborative project to create a free editable map of the world. This vector basemap is based on the Daylight map distribution of OSM data and is hosted by Esri. It presents the map in a cartographic style is like a blueprint technical drawing.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=f33a34de3a294590ab48f246e99958c9")!
                )!
            ),
            name: "National Geographic Style Map",
            description: "This vector web map provides a detailed view of the world featuring beautiful political boundaries, labeling, and background that highlights the differences in the physical characteristics of the land.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=9e557abc61ce41c9b8ec8b15800c20d3")!
                )!
            ),
            name: "Firefly Imagery Hybrid",
            description: "This map features an alternative view of the World Imagery map designed to be used as a neutral imagery basemap, with de-saturated colors, that is useful for overlaying other brightly styled layers.  The map also includes a reference layer.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
                )!
            ),
            name: nil,
            description: "This web map features satellite imagery for the world and high-resolution aerial imagery for many areas. It uses WGS84 Geographic, version 2 tiling scheme.",
            thumbnail: nil
        ),
        BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=4a3922d6d15f405d8c2b7a448a7fbad2")!
                )!
            ),
            name: "Human Geography Dark Label",
            description: "This (v2) vector tile layer provides a detailed basemap for the world, featuring a dark monochromatic style with content adjusted to support Human Geography information. This map is designed for use with Human Geography Dark Detail and Base layers.",
            thumbnail: nil
        ),
    ]
    
    let geoModel: GeoModel = Map(basemapStyle: .arcGISNova)
//    let geoModel: GeoModel = Scene(basemapStyle: .arcGISNova)

    @ObservedObject
    var viewModel = BasemapGalleryViewModel()
    
    @State
    var showBasemapGallery: Bool = true  // NOTE: Set to false when BasemapGallery is back in the navigation stack.
    
    let initialViewpoint: Viewpoint? = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1000000
    )
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var galleryWidth: CGFloat {
        get {
            if horizontalSizeClass == .regular {
                return 300.0
            }
            else {
                return 150.0
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView(map: geoModel as! Map, viewpoint: initialViewpoint)
//            SceneView(scene: geoModel as! ArcGIS.Scene, viewpoint: initialViewpoint)
                .overlay(
                    VStack(alignment: .trailing) {
                        if showBasemapGallery {
                            BasemapGallery(viewModel: viewModel)
                                .basemapGalleryStyle(.automatic)
                                .frame(width: galleryWidth)
                        }
                    }
                        .padding(),
                    alignment: .topTrailing
                )
                .onAppear() {
                    SetupViewModel()
                }
        }
        .navigationTitle("Basemap Gallery")
        .navigationBarItems(trailing: Button {
            showBasemapGallery.toggle()
        } label: {
            HStack(alignment: .center) {
                Image(uiImage: UIImage(named: "basemap")!)
                Text(showBasemapGallery ? "Hide Basemaps" : "Show Basemaps")
            }
        })
    }
    
    private func SetupViewModel() {
        viewModel.geoModel = geoModel
        viewModel.basemapGalleryItems = basemapGalleryItems
        viewModel.portal = Portal.arcGISOnline(isLoginRequired: false)
    }
}
