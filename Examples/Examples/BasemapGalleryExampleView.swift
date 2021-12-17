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
***REMOVED***let map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED******REMOVED***/ The view model for the basemap gallery.
***REMOVED***@ObservedObject
***REMOVED***var viewModel = BasemapGalleryViewModel()
***REMOVED***
***REMOVED******REMOVED***/ `true` if the basemap gallery should be displayed; `false` otherwise.
***REMOVED***@State
***REMOVED***private var showBasemapGallery: Bool = true
***REMOVED***
***REMOVED******REMOVED***/ The initial viewpoint of the map.
***REMOVED***let initialViewpoint = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1_000_000
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED***MapView(map: map, viewpoint: initialViewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if showBasemapGallery {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGallery(viewModel: viewModel)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SetupViewModel()
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.navigationTitle("Basemap Gallery")
***REMOVED******REMOVED***.navigationBarItems(trailing: Button {
***REMOVED******REMOVED******REMOVED***showBasemapGallery.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image("basemap", label: Text("Basemaps"))
***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***private func SetupViewModel() {
***REMOVED******REMOVED***viewModel.geoModel = map
***REMOVED******REMOVED***viewModel.basemapGalleryItems.append(
***REMOVED******REMOVED******REMOVED***contentsOf: BasemapGalleryExampleView.initialBasemaps()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static private func initialBasemaps() -> [BasemapGalleryItem] {
***REMOVED******REMOVED***let itemURLs: [URL] = [
***REMOVED******REMOVED******REMOVED***URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!,
***REMOVED******REMOVED******REMOVED***URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=f33a34de3a294590ab48f246e99958c9")!
***REMOVED******REMOVED***]
***REMOVED******REMOVED***
***REMOVED******REMOVED***return itemURLs.map {
***REMOVED******REMOVED******REMOVED***BasemapGalleryItem(basemap: Basemap(item: PortalItem(url: $0)!))
***REMOVED***
***REMOVED***
***REMOVED***
