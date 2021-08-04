***REMOVED***.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct BasemapGalleryExampleView: View {
***REMOVED***var basemapGalleryItems: [BasemapGalleryItem] = [
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISLightGray),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Light Gray",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap for the world featuring a light neutral background style with minimal colors as the base layer and labels as the reference layer.",
***REMOVED******REMOVED******REMOVED***thumbnail: UIImage(named: "LightGray")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailURL: URL(string: "https:***REMOVED***www.arcgis.com/sharing/rest/content/items/0f74af7609054be8a29e0ba5f154f0a8/info/thumbnail/thumbnail1607388219207.jpeg")!
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISNova),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Nova",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap for the world featuring a dark background with glowing blue symbology inspired by science-fiction and futuristic themes.",
***REMOVED******REMOVED******REMOVED***thumbnail: UIImage(named: "Nova")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailURL: URL(string: "https:***REMOVED***www.arcgis.com/sharing/rest/content/items/90f86b329f37499096d3715ac6e5ed1f/info/thumbnail/thumbnail1607555507609.jpeg")!
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISNewspaper),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Newspaper",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap in black & white design with halftone patterns, red highlights, and stylized fonts to depict a unique \"newspaper\" styled theme.",
***REMOVED******REMOVED******REMOVED***thumbnail: UIImage(named: "Newspaper")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailURL: URL(string: "https:***REMOVED***www.arcgis.com/sharing/rest/content/items/e3c062eedf8b487b8bb5b9b08db1b7a9/info/thumbnail/thumbnail1607553292807.jpeg")!
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISNavigationNight),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS NavigationNight",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap for the world featuring a 'dark mode' version of the `Basemap.Style.arcGISNavigation` style, using the same content.",
***REMOVED******REMOVED******REMOVED***thumbnail: UIImage(named: "NavigationNight")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailURL: URL(string: "https:***REMOVED***www.arcgis.com/sharing/rest/content/items/77073a29526046b89bb5622b6276e933/info/thumbnail/thumbnail1607386977674.jpeg")!
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISStreets),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Streets",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap for the world featuring a classic Esri street map style.",
***REMOVED******REMOVED******REMOVED***thumbnail: UIImage(named: "Streets")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailURL: URL(string: "https:***REMOVED***www.arcgis.com/sharing/rest/content/items/e3e6df1d2f6a485d8a70f28fdd3ce19e/info/thumbnail/thumbnail1607389307240.jpeg")!
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISTerrain),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Terrain",
***REMOVED******REMOVED******REMOVED***description: "A composite basemap with elevation hillshade (raster), minimal map content like water and land fill, water lines and roads (vector) as the base layers and minimal map content like populated place names, admin and water labels with boundary lines (vector) as the reference layer.",
***REMOVED******REMOVED******REMOVED***thumbnail: UIImage(named: "Terrain")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailURL: URL(string: "https:***REMOVED***www.arcgis.com/sharing/rest/content/items/2ef1306b93c9459ca7c7b4f872c070b9/info/thumbnail/thumbnail1607387869592.jpeg")!
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISMidcentury),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Midcentury",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap inspired by the art and advertising of the 1950's that presents a unique design option to the ArcGIS basemaps.",
***REMOVED******REMOVED******REMOVED***thumbnail: UIImage(named: "Midcentury")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***thumbnailURL: URL(string: "https:***REMOVED***www.arcgis.com/sharing/rest/content/items/52d6a28f09704f04b33761ba7c4bf93f/info/thumbnail/thumbnail1607554184831.jpeg")!
***REMOVED******REMOVED***)
***REMOVED***]
***REMOVED***
***REMOVED***let map = Map(basemapStyle: .arcGISNova)
***REMOVED***
***REMOVED***@State
***REMOVED***var selectedBasemapGalleryItem: BasemapGalleryItem?
***REMOVED***
***REMOVED***@State
***REMOVED***var showBasemapGallery: Bool = true  ***REMOVED*** NOTE: Set to false when BasemapGallery is back in the navigation stack.
***REMOVED***
***REMOVED***let initialViewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1000000
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack(alignment: .topTrailing, content: {
***REMOVED******REMOVED******REMOVED***MapView(map: map, viewpoint: initialViewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: selectedBasemapGalleryItem) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let selectedItem = selectedBasemapGalleryItem {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map.basemap = selectedItem.basemap
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .primaryAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showBasemapGallery.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "map.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if showBasemapGallery {
***REMOVED******REMOVED******REMOVED******REMOVED***BasemapGallery(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapGalleryItems: basemapGalleryItems,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedBasemapGalleryItem: $selectedBasemapGalleryItem
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 300)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED***
***REMOVED***

struct BasemapGalleryExampleView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***BasemapGalleryExampleView()
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Extensions
