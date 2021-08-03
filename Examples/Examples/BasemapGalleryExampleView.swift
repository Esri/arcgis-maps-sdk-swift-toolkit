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
***REMOVED******REMOVED***enum MapOrScene {
***REMOVED******REMOVED******REMOVED******REMOVED***/ The example shows a map view.
***REMOVED******REMOVED******REMOVED***case map
***REMOVED******REMOVED******REMOVED******REMOVED***/ The example shows a scene view.
***REMOVED******REMOVED******REMOVED***case scene
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***@State
***REMOVED******REMOVED***private var mapOrScene: MapOrScene = .map
***REMOVED***
***REMOVED***var basemapGalleryItems: [BasemapGalleryItem] = [
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISLightGray),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Light Gray",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap for the world featuring a light neutral background style with minimal colors as the base layer and labels as the reference layer.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISNova),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Nova",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap for the world featuring a dark background with glowing blue symbology inspired by science-fiction and futuristic themes.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISNewspaper),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Newspaper)",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap in black & white design with halftone patterns, red highlights, and stylized fonts to depict a unique \"newspaper\" styled theme.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISNavigationNight),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS NavigationNight",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap for the world featuring a 'dark mode' version of the `Basemap.Style.arcGISNavigation` style, using the same content.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISStreets),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Streets",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap for the world featuring a classic Esri street map style.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISTerrain),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Terrain",
***REMOVED******REMOVED******REMOVED***description: "A composite basemap with elevation hillshade (raster), minimal map content like water and land fill, water lines and roads (vector) as the base layers and minimal map content like populated place names, admin and water labels with boundary lines (vector) as the reference layer.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(style: .arcGISMidcentury),
***REMOVED******REMOVED******REMOVED***name: "ArcGIS Midcentury",
***REMOVED******REMOVED******REMOVED***description: "A vector basemap inspired by the art and advertising of the 1950's that presents a unique design option to the ArcGIS basemaps.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***)
***REMOVED***]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***BasemapGallery(basemaps: basemapGalleryItems)
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(basemapGalleryItems) { basemapGalleryItem in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(basemapGalleryItem.title)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***Picker("Map or Scene", selection: $mapOrScene, content: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Map").tag(MapOrScene.map)
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Scene").tag(MapOrScene.scene)
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.pickerStyle(SegmentedPickerStyle())
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***switch mapOrScene {
***REMOVED******REMOVED******REMOVED***case .map:
***REMOVED******REMOVED******REMOVED******REMOVED***OverviewMapForMapView()
***REMOVED******REMOVED******REMOVED***case .scene:
***REMOVED******REMOVED******REMOVED******REMOVED***OverviewMapForSceneView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

struct BasemapGalleryExampleView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***BasemapGalleryExampleView()
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Extensions
