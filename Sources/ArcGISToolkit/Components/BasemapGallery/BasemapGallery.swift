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

***REMOVED***/ The `BasemapGallery` tool displays a collection of images representing basemaps from
***REMOVED***/ ArcGIS Online, a user-defined portal, or an array of `Basemap`s.
***REMOVED***/ When a new basemap is selected from the `BasemapGallery` and the optional
***REMOVED***/ `BasemapGallery.geoModel` property is set, then the basemap of the geoModel is replaced
***REMOVED***/ with the basemap in the gallery.
public struct BasemapGallery: View {
***REMOVED******REMOVED***/ The view style of the gallery.
***REMOVED***public enum BasemapGalleryStyle {
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a grid when there is appropriate
***REMOVED******REMOVED******REMOVED***/ width available for the gallery to do so. Otherwise the gallery will display as a list.
***REMOVED******REMOVED***case automatic
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a grid.
***REMOVED******REMOVED***case grid
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a list.
***REMOVED******REMOVED***case list
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BasemapGallery`. Generates a list of appropriate, default basemaps.
***REMOVED******REMOVED***/ The given default basemaps require either an API key or named-user to be signed into the app.
***REMOVED******REMOVED***/ These basemaps are sourced from this PortalGroup:
***REMOVED******REMOVED***/ https:***REMOVED***www.arcgis.com/home/group.html?id=a25523e2241d4ff2bcc9182cc971c156).
***REMOVED******REMOVED***/ `BasemapmapGallery.currentBasemap` is set to the basemap of the given
***REMOVED******REMOVED***/ geoModel if not `nil`.
***REMOVED******REMOVED***/ - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
***REMOVED***public init(geoModel: GeoModel? = nil) {
***REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED***self.currentBasemap = geoModel?.basemap
***REMOVED******REMOVED***self.portal = Portal.arcGISOnline(loginRequired: false)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BasemapGallery`. Uses the given `portal` to retrieve basemaps.
***REMOVED******REMOVED***/ `BasemapmapGallery.currentBasemap` is set to the basemap of the given
***REMOVED******REMOVED***/ geoModel if not `nil`.
***REMOVED******REMOVED***/ - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
***REMOVED******REMOVED***/ - Parameter portal: The `GeoModel` we're selecting the basemap for.
***REMOVED***public init(
***REMOVED******REMOVED***geoModel: GeoModel? = nil,
***REMOVED******REMOVED***portal: Portal
***REMOVED***) {
***REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED***self.currentBasemap = geoModel?.basemap
***REMOVED******REMOVED***self.portal = portal
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BasemapGallery`. Uses the given list of basemap gallery items.
***REMOVED******REMOVED***/ `BasemapmapGallery.currentBasemap` is set to the basemap of the given
***REMOVED******REMOVED***/ geoModel if not `nil`.
***REMOVED******REMOVED***/ - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
***REMOVED******REMOVED***/ - Parameter basemapGalleryItems: The `GeoModel` we're selecting the basemap for.
***REMOVED***public init(
***REMOVED******REMOVED***geoModel: GeoModel? = nil,
***REMOVED******REMOVED***basemapGalleryItems: [BasemapGalleryItem] = []
***REMOVED***) {
***REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED***self.currentBasemap = geoModel?.basemap
***REMOVED******REMOVED***self._basemapGalleryItems = State(wrappedValue: basemapGalleryItems)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ If the `GeoModel` is not loaded when passed to the `BasemapGallery`, then the
***REMOVED******REMOVED***/ geoModel will be immediately loaded. The spatial reference of geoModel dictates which
***REMOVED******REMOVED***/ basemaps from the gallery are enabled.
***REMOVED******REMOVED***/ When an enabled basemap is selected by the user, the geoModel will have its
***REMOVED******REMOVED***/ basemap replaced with the selected basemap.
***REMOVED***public var geoModel: GeoModel? = nil
***REMOVED***
***REMOVED***@State
***REMOVED******REMOVED***/ Currently applied basemap on the associated `GeoModel`. This may be a basemap
***REMOVED******REMOVED***/ which does not exist in the gallery.
***REMOVED***public var currentBasemap: Basemap? = nil
***REMOVED***
***REMOVED******REMOVED***/ The `Portal` object, if set in the constructor of the `BasemapGallery`.
***REMOVED***public var portal: Portal? = nil

***REMOVED***@State
***REMOVED******REMOVED***/ The list of basemaps currently visible in the gallery. Items added or removed from this list will
***REMOVED******REMOVED***/ update the gallery.
***REMOVED***public var basemapGalleryItems: [BasemapGalleryItem] = []

***REMOVED***@State
***REMOVED***private var fetchBasemapsResult: Result<[BasemapGalleryItem]?, Error>? = .success([])

***REMOVED******REMOVED***/ The style of the basemap gallery. The gallery can be displayed as a list, grid, or automatically
***REMOVED******REMOVED***/ switch between the two based on screen real estate. Defaults to `automatic`.
***REMOVED******REMOVED***/ Set using the `basemapGalleryStyle` modifier.
***REMOVED***private var style: BasemapGalleryStyle = .automatic
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***switch style {
***REMOVED******REMOVED***case .automatic:
***REMOVED******REMOVED******REMOVED***if horizontalSizeClass == .regular {
***REMOVED******REMOVED******REMOVED******REMOVED***GridView()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED***ListView()
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .grid:
***REMOVED******REMOVED******REMOVED***GridView()
***REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED***ListView()
***REMOVED***
***REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***let result = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await portal?.fetchDeveloperBasemaps()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED******REMOVED***case .success(let basemaps):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let items = basemaps.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGalleryItem(basemap: $0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***_fetchBasemapsResult = State(wrappedValue: .success(items))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***_basemapGalleryItems = State(wrappedValue: items)
***REMOVED******REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self?.results = .failure(error)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self?.results = .success(nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Modifiers
***REMOVED***
***REMOVED******REMOVED***/ The style of the basemap gallery. Defaults to `.automatic`.
***REMOVED******REMOVED***/ - Parameter style: The `BasemapGalleryStyle` to use.
***REMOVED******REMOVED***/ - Returns: The `BasemapGallery`.
***REMOVED***public func basemapGalleryStyle(_ style: BasemapGalleryStyle) -> BasemapGallery {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.style = style
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

extension BasemapGallery {
***REMOVED***private func GridView() -> some View {
***REMOVED******REMOVED***let columns: [GridItem] = [
***REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top),
***REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top),
***REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top)
***REMOVED******REMOVED***]

***REMOVED******REMOVED***return GalleryView(columns)
***REMOVED***
***REMOVED***
***REMOVED***private func ListView() -> some View {
***REMOVED******REMOVED***let columns: [GridItem] = [
***REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top)
***REMOVED******REMOVED***]

***REMOVED******REMOVED***return GalleryView(columns)
***REMOVED***
***REMOVED***
***REMOVED***private func GalleryView(_ columns: [GridItem]) -> some View {
***REMOVED******REMOVED***return ScrollView {
***REMOVED******REMOVED******REMOVED***LazyVGrid(columns: columns, spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(basemapGalleryItems) { basemapGalleryItem in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGalleryItemRow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapGalleryItem: basemapGalleryItem,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentBasemap: currentBasemap
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoModel?.basemap = basemapGalleryItem.basemap
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentBasemap = basemapGalleryItem.basemap
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***

private struct BasemapGalleryItemRow: View {
***REMOVED***var basemapGalleryItem: BasemapGalleryItem
***REMOVED***var currentBasemap: Basemap? = nil
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if let thumbnailImage = basemapGalleryItem.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO: thumbnail will have to be loaded.
***REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: thumbnailImage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(basemapGalleryItem.name)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED***
***REMOVED***
***REMOVED***
