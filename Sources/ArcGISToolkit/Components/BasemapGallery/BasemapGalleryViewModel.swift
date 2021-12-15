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
***REMOVED******REMOVED***/ Creates a `BasemapGalleryViewModel`
***REMOVED******REMOVED***/ - Remark: The ArcGISOnline's developer basemaps will
***REMOVED******REMOVED***/ be loaded and added to `basemapGalleryItems`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - geoModel: The `GeoModel`.
***REMOVED***public convenience init(_ geoModel: GeoModel? = nil) {
***REMOVED******REMOVED***self.init(geoModel, basemapGalleryItems: [])
***REMOVED***

***REMOVED******REMOVED***/ Creates a `BasemapGalleryViewModel`. Uses the given list of basemap gallery items.
***REMOVED******REMOVED***/ - Remark: If `basemapGalleryItems` is empty, ArcGISOnline's developer basemaps will
***REMOVED******REMOVED***/ be loaded and added to `basemapGalleryItems`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - geoModel: The `GeoModel`.
***REMOVED******REMOVED***/   - basemapGalleryItems: A list of pre-defined base maps to display.
***REMOVED***public init(
***REMOVED******REMOVED***_ geoModel: GeoModel? = nil,
***REMOVED******REMOVED***basemapGalleryItems: [BasemapGalleryItem]
***REMOVED***) {
***REMOVED******REMOVED***self.basemapGalleryItems.append(contentsOf: basemapGalleryItems)
***REMOVED******REMOVED***
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED*** Using `defer` allows the property `didSet` observers to be called.
***REMOVED******REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ If the `GeoModel` is not loaded when passed to the `BasemapGalleryViewModel`, then
***REMOVED******REMOVED***/ the geoModel will be immediately loaded. The spatial reference of geoModel dictates which
***REMOVED******REMOVED***/ basemaps from the gallery are enabled. When an enabled basemap is selected by the user,
***REMOVED******REMOVED***/ the geoModel will have its basemap replaced with the selected basemap.
***REMOVED***public var geoModel: GeoModel? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***guard let geoModel = geoModel else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***Task { await load(geoModel: geoModel) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The list of basemaps currently visible in the gallery. It is comprised of items passed into
***REMOVED******REMOVED***/ the `BasemapGalleryItem` constructor property.
***REMOVED***@Published
***REMOVED***public var basemapGalleryItems: [BasemapGalleryItem] = []
***REMOVED***
***REMOVED******REMOVED***/ The `BasemapGalleryItem` representing the `GeoModel`'s current base map. This may be a
***REMOVED******REMOVED***/ basemap which does not exist in the gallery.
***REMOVED***@Published
***REMOVED***public var currentBasemapGalleryItem: BasemapGalleryItem? = nil {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***guard let item = currentBasemapGalleryItem else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***geoModel?.basemap = item.basemap
***REMOVED***
***REMOVED***
***REMOVED***

private extension BasemapGalleryViewModel {
***REMOVED******REMOVED***/ Loads the given `GeoModel` then sets `currentBasemapGalleryItem` to an item
***REMOVED******REMOVED***/ created with the geoModel's basemap.
***REMOVED******REMOVED***/ - Parameter geoModel: The `GeoModel` to load.
***REMOVED***func load(geoModel: GeoModel?) async {
***REMOVED******REMOVED***guard let geoModel = geoModel else { return ***REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await geoModel.load()
***REMOVED******REMOVED******REMOVED***if let basemap = geoModel.basemap {
***REMOVED******REMOVED******REMOVED******REMOVED***currentBasemapGalleryItem = BasemapGalleryItem(basemap: basemap)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED***currentBasemapGalleryItem = nil
***REMOVED******REMOVED***
***REMOVED*** catch { ***REMOVED***
***REMOVED***
***REMOVED***
