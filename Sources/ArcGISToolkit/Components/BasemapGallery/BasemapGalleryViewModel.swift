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
public class BasemapGalleryViewModel: ObservableObject {
***REMOVED***public init(
***REMOVED******REMOVED***geoModel: GeoModel? = nil,
***REMOVED******REMOVED***portal: Portal? = nil,
***REMOVED******REMOVED***basemapGalleryItems: [BasemapGalleryItem] = []
***REMOVED***) {
***REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED***self.portal = portal
***REMOVED******REMOVED***self.basemapGalleryItems = basemapGalleryItems
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates a `BasemapGalleryViewModel`. Generates a list of appropriate, default basemaps.
***REMOVED******REMOVED******REMOVED***/ The given default basemaps require either an API key or named-user to be signed into the app.
***REMOVED******REMOVED******REMOVED***/ These basemaps are sourced from this PortalGroup:
***REMOVED******REMOVED******REMOVED***/ https:***REMOVED***www.arcgis.com/home/group.html?id=a25523e2241d4ff2bcc9182cc971c156).
***REMOVED******REMOVED******REMOVED***/ `BasemapGalleryViewModel.currentBasemap` is set to the basemap of the given
***REMOVED******REMOVED******REMOVED***/ geoModel if not `nil`.
***REMOVED******REMOVED******REMOVED***/ - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
***REMOVED******REMOVED***public init(geoModel: GeoModel? = nil) {
***REMOVED******REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED******REMOVED***self.currentBasemap = geoModel?.basemap
***REMOVED******REMOVED******REMOVED***self.portal = Portal.arcGISOnline(loginRequired: false)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates a `BasemapGalleryViewModel`. Uses the given `portal` to retrieve basemaps.
***REMOVED******REMOVED******REMOVED***/ `BasemapGalleryViewModel.currentBasemap` is set to the basemap of the given
***REMOVED******REMOVED******REMOVED***/ geoModel if not `nil`.
***REMOVED******REMOVED******REMOVED***/ - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
***REMOVED******REMOVED******REMOVED***/ - Parameter portal: The `GeoModel` we're selecting the basemap for.
***REMOVED******REMOVED***public init(
***REMOVED******REMOVED******REMOVED***geoModel: GeoModel? = nil,
***REMOVED******REMOVED******REMOVED***portal: Portal
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED******REMOVED***self.currentBasemap = geoModel?.basemap
***REMOVED******REMOVED******REMOVED***self.portal = portal
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates a `BasemapGalleryViewModel`. Uses the given list of basemap gallery items.
***REMOVED******REMOVED******REMOVED***/ `BasemapGalleryViewModel.currentBasemap` is set to the basemap of the given
***REMOVED******REMOVED******REMOVED***/ geoModel if not `nil`.
***REMOVED******REMOVED******REMOVED***/ - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
***REMOVED******REMOVED******REMOVED***/ - Parameter basemapGalleryItems: The `GeoModel` we're selecting the basemap for.
***REMOVED******REMOVED***public init(
***REMOVED******REMOVED******REMOVED***geoModel: GeoModel? = nil,
***REMOVED******REMOVED******REMOVED***basemapGalleryItems: [BasemapGalleryItem] = []
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED******REMOVED***self.currentBasemap = geoModel?.basemap
***REMOVED******REMOVED******REMOVED***self.basemapGalleryItems = basemapGalleryItems
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ If the `GeoModel` is not loaded when passed to the `BasemapGalleryViewModel`, then
***REMOVED******REMOVED***/ the geoModel will be immediately loaded. The spatial reference of geoModel dictates which
***REMOVED******REMOVED***/ basemaps from the gallery are enabled. When an enabled basemap is selected by the user,
***REMOVED******REMOVED***/ the geoModel will have its basemap replaced with the selected basemap.
***REMOVED***public var geoModel: GeoModel? = nil
***REMOVED***
***REMOVED******REMOVED***/ The `Portal` object, if any.
***REMOVED***public var portal: Portal? = nil

***REMOVED***@Published
***REMOVED******REMOVED***/ The list of basemaps currently visible in the gallery. Items added or removed from this list will
***REMOVED******REMOVED***/ update the gallery.
***REMOVED***public var basemapGalleryItems: [BasemapGalleryItem] = []
***REMOVED***
***REMOVED******REMOVED***/ Currently applied basemap on the associated `GeoModel`. This may be a basemap
***REMOVED******REMOVED***/ which does not exist in the gallery.
***REMOVED***public var currentBasemap: Basemap? {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***guard let geoModel = geoModel else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***try await geoModel.load()
***REMOVED******REMOVED******REMOVED***return geoModel.basemap
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The currently executing async task.  `currentTask` should be cancelled
***REMOVED******REMOVED***/ prior to starting another async task.
***REMOVED***private var currentTask: Task<Void, Never>? = nil
***REMOVED***
***REMOVED******REMOVED***/ Updates suggestions list asynchronously.
***REMOVED***public func fetchBasemaps() async -> Void {
***REMOVED******REMOVED***guard let portal = portal else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***currentTask?.cancel()
***REMOVED******REMOVED***currentTask = fetchBasemapsTask(portal)
***REMOVED******REMOVED***await currentTask?.value
***REMOVED***
***REMOVED***

extension BasemapGalleryViewModel {
***REMOVED***private func fetchBasemapsTask(_ portal: Portal) -> Task<(), Never> {
***REMOVED******REMOVED***let task = Task(operation: {
***REMOVED******REMOVED******REMOVED***let basemapResults = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await portal.fetchDeveloperBasemaps()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***DispatchQueue.main.async { [weak self] in
***REMOVED******REMOVED******REMOVED******REMOVED***switch basemapResults {
***REMOVED******REMOVED******REMOVED******REMOVED***case .success(let basemaps):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self?.basemapGalleryItems = basemaps.map { BasemapGalleryItem(basemap: $0) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***case .failure(_):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self?.basemapGalleryItems = []
***REMOVED******REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self?.basemapGalleryItems = []
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED******REMOVED***return task
***REMOVED***
***REMOVED***

extension BasemapGalleryViewModel {
***REMOVED***
