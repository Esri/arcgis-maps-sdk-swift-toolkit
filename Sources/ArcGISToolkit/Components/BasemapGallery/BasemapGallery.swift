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
***REMOVED***public init(viewModel: BasemapGalleryViewModel? = nil) {
***REMOVED******REMOVED***if let viewModel = viewModel {
***REMOVED******REMOVED******REMOVED***self.viewModel = viewModel
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***self.viewModel = BasemapGalleryViewModel()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ObservedObject
***REMOVED***public var viewModel: BasemapGalleryViewModel
***REMOVED***
***REMOVED******REMOVED***/ The style of the basemap gallery. The gallery can be displayed as a list, grid, or automatically
***REMOVED******REMOVED***/ switch between the two based on screen real estate. Defaults to `automatic`.
***REMOVED******REMOVED***/ Set using the `basemapGalleryStyle` modifier.
***REMOVED***private var style: BasemapGalleryStyle = .automatic
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass

***REMOVED***public var body: some View {
***REMOVED******REMOVED***GalleryView()
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.fetchBasemaps()
***REMOVED******REMOVED******REMOVED***
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
***REMOVED***@ViewBuilder
***REMOVED***private func GalleryView() -> some View {
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
***REMOVED***
***REMOVED***
***REMOVED***private func GridView() -> some View {
***REMOVED******REMOVED***let columns: [GridItem] = [
***REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top),
***REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top),
***REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top)
***REMOVED******REMOVED***]

***REMOVED******REMOVED***return InternalGalleryView(columns)
***REMOVED***
***REMOVED***
***REMOVED***private func ListView() -> some View {
***REMOVED******REMOVED***let columns: [GridItem] = [
***REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top)
***REMOVED******REMOVED***]

***REMOVED******REMOVED***return InternalGalleryView(columns)
***REMOVED***
***REMOVED***
***REMOVED***private func InternalGalleryView(_ columns: [GridItem]) -> some View {
***REMOVED******REMOVED***return ScrollView {
***REMOVED******REMOVED******REMOVED***LazyVGrid(columns: columns, spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.basemapGalleryItems) { basemapGalleryItem in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGalleryItemRow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapGalleryItem: basemapGalleryItem,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentItem: viewModel.currentBasemapGalleryItem
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.currentBasemapGalleryItem = basemapGalleryItem
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***

private struct BasemapGalleryItemRow: View {
***REMOVED***var basemapGalleryItem: BasemapGalleryItem
***REMOVED***var currentItem: BasemapGalleryItem?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack (alignment: .center) {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if let thumbnailImage = basemapGalleryItem.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: thumbnailImage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapGalleryItem == currentItem ? Color.accentColor: Color.clear,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 3.0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Text(basemapGalleryItem.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
