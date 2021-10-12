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

import Swift
***REMOVED***
***REMOVED***
import Combine

***REMOVED***/ Manages the state for a `BasemapGallery`.
@MainActor
public class BasemapGalleryViewModel: ObservableObject {
***REMOVED******REMOVED***/ Creates a `BasemapGalleryViewModel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - currentBasemap: The `Basemap` currently used by a `GeoModel`.
***REMOVED******REMOVED***/   - portal: The `Portal` to load base maps from.
***REMOVED******REMOVED***/   - basemapGalleryItems: A list of pre-defined base maps to display.
***REMOVED***public init(
***REMOVED******REMOVED***geoModel: GeoModel? = nil,
***REMOVED******REMOVED***portal: Portal? = nil,
***REMOVED******REMOVED***basemapGalleryItems: [BasemapGalleryItem] = []
***REMOVED***) {
***REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED***self.portal = portal
***REMOVED******REMOVED***self.basemapGalleryItems.append(contentsOf: basemapGalleryItems)
***REMOVED******REMOVED***
***REMOVED******REMOVED***loadGeoModel()
***REMOVED******REMOVED***fetchBasemaps()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ If the `GeoModel` is not loaded when passed to the `BasemapGalleryViewModel`, then
***REMOVED******REMOVED***/ the geoModel will be immediately loaded. The spatial reference of geoModel dictates which
***REMOVED******REMOVED***/ basemaps from the gallery are enabled. When an enabled basemap is selected by the user,
***REMOVED******REMOVED***/ the geoModel will have its basemap replaced with the selected basemap.
***REMOVED***public var geoModel: GeoModel? = nil {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***loadGeoModel()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Portal` object, if any.  Setting the portal will automatically fetch it's base maps
***REMOVED******REMOVED***/ and add them to the `basemapGalleryItems` array.
***REMOVED***public var portal: Portal? = nil {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***fetchBasemaps()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The list of basemaps currently visible in the gallery. Items added or removed from this list will
***REMOVED******REMOVED***/ update the gallery.
***REMOVED***@Published
***REMOVED***public var basemapGalleryItems: [BasemapGalleryItem] = []
***REMOVED***
***REMOVED******REMOVED***/ `BasemapGalleryItem` representing the `GeoModel`'s current base map. This may be a
***REMOVED******REMOVED***/ basemap which does not exist in the gallery.
***REMOVED***@Published
***REMOVED***public var currentBasemapGalleryItem: BasemapGalleryItem? = nil {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***guard let item = currentBasemapGalleryItem else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***geoModel?.basemap = item.basemap
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** TODO: write tests to check on loading stuff, setting portal and other props, etc.
***REMOVED******REMOVED*** TODO: Change type of `Task<Void, Never>` so I don't need to wrap operation in a Result.
***REMOVED***
***REMOVED******REMOVED***/ The currently executing async task for fetching basemaps from the portal.
***REMOVED******REMOVED***/ `fetchBasemapTask` should be cancelled prior to starting another async task.
***REMOVED***private var fetchBasemapTask: Task<Void, Never>? = nil
***REMOVED***
***REMOVED******REMOVED***/ Fetches the basemaps from `portal`.
***REMOVED***private func fetchBasemaps() {
***REMOVED******REMOVED***fetchBasemapTask?.cancel()
***REMOVED******REMOVED***fetchBasemapTask = fetchBasemapsTask(portal)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The currently executing async task for loading `geoModel`.
***REMOVED******REMOVED***/ `loadGeoModelTask` should be cancelled prior to starting another async task.
***REMOVED***private var loadGeoModelTask: Task<Void, Never>? = nil
***REMOVED***
***REMOVED******REMOVED***/ Loads `geoModel`.
***REMOVED***private func loadGeoModel() {
***REMOVED******REMOVED***loadGeoModelTask?.cancel()
***REMOVED******REMOVED***loadGeoModelTask = loadGeoModelTask(geoModel)
***REMOVED***
***REMOVED***

extension BasemapGalleryViewModel {
***REMOVED***private func fetchBasemapsTask(_ portal: Portal?) -> Task<(), Never>? {
***REMOVED******REMOVED***guard let portal = portal else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return Task(operation: {
***REMOVED******REMOVED******REMOVED***let basemapResults = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await portal.developerBasemaps
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch basemapResults {
***REMOVED******REMOVED******REMOVED***case .success(let basemaps):
***REMOVED******REMOVED******REMOVED******REMOVED***basemaps.forEach { basemap in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await basemap.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let loadableImage = basemap.item?.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await loadableImage.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapGalleryItems.append(BasemapGalleryItem(basemap: basemap))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(_), .none:
***REMOVED******REMOVED******REMOVED******REMOVED***basemapGalleryItems = []
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***private func loadGeoModelTask(_ geoModel: GeoModel?) -> Task<(), Never>? {
***REMOVED******REMOVED***guard let geoModel = geoModel else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return Task(operation: {
***REMOVED******REMOVED******REMOVED***let loadResult = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await geoModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch loadResult {
***REMOVED******REMOVED******REMOVED***case .success(_):
***REMOVED******REMOVED******REMOVED******REMOVED***if let basemap = geoModel.basemap {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentBasemapGalleryItem = BasemapGalleryItem(basemap: basemap)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fallthrough
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(_), .none:
***REMOVED******REMOVED******REMOVED******REMOVED***currentBasemapGalleryItem = nil
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED***
***REMOVED***
