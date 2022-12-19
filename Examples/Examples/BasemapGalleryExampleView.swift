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
***REMOVED******REMOVED***/ The data model containing the `Map` displayed in the `MapView`.
***REMOVED***@StateObject private var dataModel = MapDataModel(
***REMOVED******REMOVED***map: Map(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether to show the basemap gallery.
***REMOVED***@State private var showBasemapGallery = false
***REMOVED***
***REMOVED******REMOVED***/ The initial viewpoint of the map.
***REMOVED***let initialViewpoint = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1_000_000
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The initial list of basemaps.
***REMOVED***private let basemaps = initialBasemaps()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: dataModel.map, viewpoint: initialViewpoint)
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***if showBasemapGallery {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGallery(items: basemaps, geoModel: dataModel.map)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.style(.automatic())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Basemap Gallery")
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Toggle(isOn: $showBasemapGallery) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image("basemap", label: Text("Show base map"))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private static func initialBasemaps() -> [BasemapGalleryItem] {
***REMOVED******REMOVED***let identifiers = [
***REMOVED******REMOVED******REMOVED***"46a87c20f09e4fc48fa3c38081e0cae6",
***REMOVED******REMOVED******REMOVED***"f33a34de3a294590ab48f246e99958c9",
***REMOVED******REMOVED******REMOVED***"52bdc7ab7fb044d98add148764eaa30a",  ***REMOVED*** <<== mismatched spatial reference
***REMOVED******REMOVED******REMOVED***"3a8d410a4a034a2ba9738bb0860d68c4"   ***REMOVED*** <<== incorrect portal item type
***REMOVED******REMOVED***]
***REMOVED******REMOVED***
***REMOVED******REMOVED***return identifiers.map { identifier in
***REMOVED******REMOVED******REMOVED***let url = URL(string: "https:***REMOVED***www.arcgis.com/home/item.html?id=\(identifier)")!
***REMOVED******REMOVED******REMOVED***return BasemapGalleryItem(basemap: Basemap(item: PortalItem(url: url)!))
***REMOVED***
***REMOVED***
***REMOVED***
