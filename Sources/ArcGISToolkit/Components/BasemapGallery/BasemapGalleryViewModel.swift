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

***REMOVED***/ Manages the state for a `BasemapGallery`.
@MainActor
public class BasemapGalleryViewModel: ObservableObject {
***REMOVED******REMOVED***/ Creates a `BasemapGalleryViewModel`. Uses the given array of basemap gallery items.
***REMOVED******REMOVED***/ - Remark: If `items` is empty, ArcGISOnline's developer basemaps will
***REMOVED******REMOVED***/ be loaded and added to `items`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - geoModel: The `GeoModel`.
***REMOVED******REMOVED***/   - items: A list of pre-defined base maps to display.
***REMOVED***public init(
***REMOVED******REMOVED***geoModel: GeoModel? = nil,
***REMOVED******REMOVED***items: [BasemapGalleryItem] = []
***REMOVED***) {
***REMOVED******REMOVED***self.items = items
***REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED***geoModelDidChange(nil)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ If the `GeoModel` is not loaded when passed to the `BasemapGalleryViewModel`, then
***REMOVED******REMOVED***/ the geoModel will be immediately loaded. The spatial reference of geoModel dictates which
***REMOVED******REMOVED***/ basemaps from the gallery are enabled. When an enabled basemap is selected by the user,
***REMOVED******REMOVED***/ the geoModel will have its basemap replaced with the selected basemap.
***REMOVED***public var geoModel: GeoModel? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***geoModelDidChange(oldValue)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The list of basemaps currently visible in the gallery. It is comprised of items passed into
***REMOVED******REMOVED***/ the `BasemapGalleryItem` constructor property.
***REMOVED***@Published
***REMOVED***public var items: [BasemapGalleryItem]
***REMOVED***
***REMOVED******REMOVED***/ The `BasemapGalleryItem` representing the `GeoModel`'s current base map. This may be a
***REMOVED******REMOVED***/ basemap which does not exist in the gallery.
***REMOVED***@Published
***REMOVED***public var currentItem: BasemapGalleryItem? = nil {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***guard let item = currentItem else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***geoModel?.basemap = item.basemap
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Handles changes to the `geoModel` property.
***REMOVED******REMOVED***/ - Parameter previousGeoModel: The previously set `geoModel`.
***REMOVED***func geoModelDidChange(_ previousGeoModel: GeoModel?) {
***REMOVED******REMOVED***guard let geoModel = geoModel else { return ***REMOVED***
***REMOVED******REMOVED***if geoModel.loadStatus != .loaded {
***REMOVED******REMOVED******REMOVED***Task { await load(geoModel: geoModel) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension BasemapGalleryViewModel {
***REMOVED******REMOVED***/ Loads the given `GeoModel` then sets `currentItem` to an item
***REMOVED******REMOVED***/ created with the geoModel's basemap.
***REMOVED******REMOVED***/ - Parameter geoModel: The `GeoModel` to load.
***REMOVED***func load(geoModel: GeoModel?) async {
***REMOVED******REMOVED***guard let geoModel = geoModel else { return ***REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await geoModel.load()
***REMOVED******REMOVED******REMOVED***if let basemap = geoModel.basemap {
***REMOVED******REMOVED******REMOVED******REMOVED***currentItem = BasemapGalleryItem(basemap: basemap)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***currentItem = nil
***REMOVED******REMOVED***
***REMOVED*** catch {***REMOVED***
***REMOVED***
***REMOVED***
