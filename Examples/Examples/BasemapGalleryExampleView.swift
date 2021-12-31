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
***REMOVED******REMOVED******REMOVED***geoModel: self.map
***REMOVED******REMOVED******REMOVED******REMOVED*** You can add your own basemaps by passing them in here:
***REMOVED******REMOVED******REMOVED******REMOVED***items: Self.initialBasemaps()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map, viewpoint: initialViewpoint)
***REMOVED******REMOVED******REMOVED***.navigationTitle("Basemap Gallery")
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItemGroup(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showBasemapGallery.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image("basemap")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.popover(isPresented: $showBasemapGallery) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if UIDevice.current.userInterfaceIdiom == .phone {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGallery(viewModel: viewModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle("Basemaps")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Done") { showBasemapGallery = false ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGallery(viewModel: viewModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***static private func initialBasemaps() -> [BasemapGalleryItem] {
***REMOVED******REMOVED***let identifiers = [
***REMOVED******REMOVED******REMOVED***"46a87c20f09e4fc48fa3c38081e0cae6",
***REMOVED******REMOVED******REMOVED***"f33a34de3a294590ab48f246e99958c9"
***REMOVED******REMOVED***]
***REMOVED******REMOVED***
***REMOVED******REMOVED***return identifiers.map { identifier in
***REMOVED******REMOVED******REMOVED***let url = URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=\(identifier)")!
***REMOVED******REMOVED******REMOVED***return BasemapGalleryItem(basemap: Basemap(item: PortalItem(url: url)!))
***REMOVED***
***REMOVED***
***REMOVED***
