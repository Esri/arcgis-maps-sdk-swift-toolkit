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
***REMOVED******REMOVED***/ The map displayed in the map view.
***REMOVED***let map: Map
***REMOVED***
***REMOVED******REMOVED***/ The view model for the basemap gallery.
***REMOVED***@ObservedObject
***REMOVED***var viewModel: BasemapGalleryViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether to show the basemap gallery.
***REMOVED***@State
***REMOVED***private var showBasemapGallery: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The initial viewpoint of the map.
***REMOVED***let initialViewpoint = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1_000_000
***REMOVED***)
***REMOVED***
***REMOVED***init() {
***REMOVED******REMOVED***self.map = Map(basemapStyle: .arcGISImagery)
***REMOVED******REMOVED***self.viewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***geoModel: self.map,
***REMOVED******REMOVED******REMOVED******REMOVED*** You can add your own basemaps by passing them in here:
***REMOVED******REMOVED******REMOVED***items: Self.initialBasemaps()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map, viewpoint: initialViewpoint)
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***if showBasemapGallery {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGallery(viewModel: viewModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.style(.automatic())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Basemap Gallery")
***REMOVED******REMOVED******REMOVED***.navigationBarItems(trailing: Toggle(isOn: $showBasemapGallery) {
***REMOVED******REMOVED******REMOVED******REMOVED***Image("basemap", label: Text("Show base map"))
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static private func initialBasemaps() -> [BasemapGalleryItem] {
***REMOVED******REMOVED***let identifiers = [
***REMOVED******REMOVED******REMOVED***"46a87c20f09e4fc48fa3c38081e0cae6",
***REMOVED******REMOVED******REMOVED***"f33a34de3a294590ab48f246e99958c9",
***REMOVED******REMOVED******REMOVED***"52bdc7ab7fb044d98add148764eaa30a",  ***REMOVED***<<== mismatched spatial reference
***REMOVED******REMOVED******REMOVED***"3a8d410a4a034a2ba9738bb0860d68c4"   ***REMOVED***<<== incorrect portal item type
***REMOVED******REMOVED***]
***REMOVED******REMOVED***
***REMOVED******REMOVED***return identifiers.map { identifier in
***REMOVED******REMOVED******REMOVED***let url = URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=\(identifier)")!
***REMOVED******REMOVED******REMOVED***return BasemapGalleryItem(basemap: Basemap(item: PortalItem(url: url)!))
***REMOVED***
***REMOVED***
***REMOVED***
