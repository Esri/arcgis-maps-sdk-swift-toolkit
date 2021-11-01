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

***REMOVED*** TODO: once user taps on a map (or maybe in the view model setter for current item)
***REMOVED*** TODO: then check if SRs match and don't set basemap if they don't.  Figure out
***REMOVED*** TODO: how to then gray out the item in the gallery.

struct BasemapGalleryExampleView: View {
***REMOVED***var basemapGalleryItems: [BasemapGalleryItem] = [
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***name: "OpenStreetMap (Blueprint)",
***REMOVED******REMOVED******REMOVED***description: "OpenStreetMap (OSM) is a collaborative project to create a free editable map of the world. This vector basemap is based on the Daylight map distribution of OSM data and is hosted by Esri. It presents the map in a cartographic style is like a blueprint technical drawing.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=f33a34de3a294590ab48f246e99958c9")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***name: "National Geographic Style Map",
***REMOVED******REMOVED******REMOVED***description: "This vector web map provides a detailed view of the world featuring beautiful political boundaries, labeling, and background that highlights the differences in the physical characteristics of the land.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=9e557abc61ce41c9b8ec8b15800c20d3")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***name: "Firefly Imagery Hybrid",
***REMOVED******REMOVED******REMOVED***description: "This map features an alternative view of the World Imagery map designed to be used as a neutral imagery basemap, with de-saturated colors, that is useful for overlaying other brightly styled layers.  The map also includes a reference layer.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***name: nil,
***REMOVED******REMOVED******REMOVED***description: "This web map features satellite imagery for the world and high-resolution aerial imagery for many areas. It uses WGS84 Geographic, version 2 tiling scheme.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=4a3922d6d15f405d8c2b7a448a7fbad2")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***name: "Human Geography Dark Label",
***REMOVED******REMOVED******REMOVED***description: "This (v2) vector tile layer provides a detailed basemap for the world, featuring a dark monochromatic style with content adjusted to support Human Geography information. This map is designed for use with Human Geography Dark Detail and Base layers.",
***REMOVED******REMOVED******REMOVED***thumbnail: nil
***REMOVED******REMOVED***),
***REMOVED***]
***REMOVED***
***REMOVED***let geoModel: GeoModel = Map(basemapStyle: .arcGISNova)
***REMOVED******REMOVED***let geoModel: GeoModel = Scene(basemapStyle: .arcGISNova)

***REMOVED***@ObservedObject
***REMOVED***var viewModel = BasemapGalleryViewModel()
***REMOVED***
***REMOVED***@State
***REMOVED***var showBasemapGallery: Bool = true  ***REMOVED*** NOTE: Set to false when BasemapGallery is back in the navigation stack.
***REMOVED***
***REMOVED***let initialViewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1000000
***REMOVED***)
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass
***REMOVED***
***REMOVED***var galleryWidth: CGFloat {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***if horizontalSizeClass == .regular {
***REMOVED******REMOVED******REMOVED******REMOVED***return 300.0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED***return 150.0
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED***MapView(map: geoModel as! Map, viewpoint: initialViewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED***SceneView(scene: geoModel as! ArcGIS.Scene, viewpoint: initialViewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .trailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if showBasemapGallery {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGallery(viewModel: viewModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.basemapGalleryStyle(.automatic)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: galleryWidth)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SetupViewModel()
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.navigationTitle("Basemap Gallery")
***REMOVED******REMOVED***.navigationBarItems(trailing: Button {
***REMOVED******REMOVED******REMOVED***showBasemapGallery.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***HStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: UIImage(named: "basemap")!)
***REMOVED******REMOVED******REMOVED******REMOVED***Text(showBasemapGallery ? "Hide Basemaps" : "Show Basemaps")
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***private func SetupViewModel() {
***REMOVED******REMOVED***viewModel.geoModel = geoModel
***REMOVED******REMOVED***viewModel.basemapGalleryItems = basemapGalleryItems
***REMOVED******REMOVED***viewModel.portal = Portal.arcGISOnline(isLoginRequired: false)
***REMOVED***
***REMOVED***
