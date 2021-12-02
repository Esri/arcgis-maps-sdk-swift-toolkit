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

***REMOVED***/ The `BasemapGallery` tool displays a collection  basemaps from
***REMOVED***/ ArcGIS Online, a user-defined portal, or an array of `Basemap`s.
***REMOVED***/ When a new basemap is selected from the `BasemapGallery` and the optional
***REMOVED***/ `BasemapGallery.geoModel` property is set, then the basemap of the geoModel is replaced
***REMOVED***/ with the basemap in the gallery.
public struct BasemapGallery: View {
***REMOVED******REMOVED***/ The view style of the gallery.
***REMOVED***public enum Style {
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a grid when there is appropriate
***REMOVED******REMOVED******REMOVED***/ width available for the gallery to do so. Otherwise the gallery will display as a list.
***REMOVED******REMOVED***case automatic
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a grid.
***REMOVED******REMOVED***case grid
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a list.
***REMOVED******REMOVED***case list
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BasemapGallery`.
***REMOVED******REMOVED***/ - Parameter viewModel: The view model used by the `BasemapGallery`.
***REMOVED***public init(viewModel: BasemapGalleryViewModel? = nil) {
***REMOVED******REMOVED***if let viewModel = viewModel {
***REMOVED******REMOVED******REMOVED***self.viewModel = viewModel
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***self.viewModel = BasemapGalleryViewModel()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `BasemapGalleryViewModel` manages the state
***REMOVED******REMOVED***/ of the `BasemapGallery`. The view observes `BasemapGalleryViewModel` for changes
***REMOVED******REMOVED***/ in state. The view updates the state of the `BasemapGalleryViewModel` in response to
***REMOVED******REMOVED***/ user action.
***REMOVED***@ObservedObject
***REMOVED***public var viewModel: BasemapGalleryViewModel
***REMOVED***
***REMOVED******REMOVED***/ The style of the basemap gallery. The gallery can be displayed as a list, grid, or automatically
***REMOVED******REMOVED***/ switch between the two based on screen real estate. Defaults to `automatic`.
***REMOVED******REMOVED***/ Set using the `style` modifier.
***REMOVED***private var style: Style = .automatic
***REMOVED***
***REMOVED******REMOVED***/ The size class used to determine if the basemap items should dispaly in a list or grid.
***REMOVED******REMOVED***/ If the size class is `.regular`, they display in a grid. If it is `.compact`, they display in a list.
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ `true` if the horizontal size class is `.regular`, `false` if it's `.compact`.
***REMOVED***private var isRegularWidth: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .regular
***REMOVED***

***REMOVED******REMOVED***/ The width of the gallery, taking into account the horizontal size class of the device.
***REMOVED***private var galleryWidth: CGFloat? {
***REMOVED******REMOVED***isRegularWidth ? 300 : 150
***REMOVED***

***REMOVED******REMOVED***/ The current alert item to display.
***REMOVED***@State
***REMOVED***private var alertItem: AlertItem?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***GalleryView()
***REMOVED******REMOVED******REMOVED***.frame(width: galleryWidth)
***REMOVED******REMOVED******REMOVED***.onReceive(
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.$spatialReferenceMismatchError.dropFirst(),
***REMOVED******REMOVED******REMOVED******REMOVED***perform: { error in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let error = error else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem = AlertItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapSR: error.basemapSR,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoModelSR: error.geoModelSR
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.alert(item: $alertItem) { alertItem in
***REMOVED******REMOVED******REMOVED******REMOVED***Alert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: Text(alertItem.title),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***message: Text(alertItem.message)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension BasemapGallery {
***REMOVED******REMOVED***/ The gallery view, either displayed as a grid or a list depending on `BasemapGallery.style`.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery.
***REMOVED***@ViewBuilder
***REMOVED***func GalleryView() -> some View {
***REMOVED******REMOVED***switch style {
***REMOVED******REMOVED***case .automatic:
***REMOVED******REMOVED******REMOVED***if isRegularWidth {
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
***REMOVED******REMOVED***/ The gallery view, displayed as a grid.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery grid.
***REMOVED***func GridView() -> some View {
***REMOVED******REMOVED***InternalGalleryView(
***REMOVED******REMOVED******REMOVED***[
***REMOVED******REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top),
***REMOVED******REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top),
***REMOVED******REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top)
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The gallery view, displayed as a list.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery list.
***REMOVED***func ListView() -> some View {
***REMOVED******REMOVED***InternalGalleryView(
***REMOVED******REMOVED******REMOVED***[
***REMOVED******REMOVED******REMOVED******REMOVED***.init(.flexible(), spacing: 8.0, alignment: .top)
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The gallery view, displayed in the specified columns.
***REMOVED******REMOVED***/ - Parameter columns: The columns used to display the basemap items.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery with the specified columns.
***REMOVED***func InternalGalleryView(_ columns: [GridItem]) -> some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***LazyVGrid(columns: columns, spacing: 4) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.basemapGalleryItems) { basemapGalleryItem in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGalleryItemRow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapGalleryItem: basemapGalleryItem,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelected: basemapGalleryItem == viewModel.currentBasemapGalleryItem
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let loadError = basemapGalleryItem.loadBasemapsError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem = AlertItem(loadBasemapError: loadError)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.updateCurrentBasemapGalleryItem(basemapGalleryItem)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***

***REMOVED***/ A row or grid element representing a basemap gallery item.
private struct BasemapGalleryItemRow: View {
***REMOVED***@ObservedObject var basemapGalleryItem: BasemapGalleryItem
***REMOVED***let isSelected: Bool
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***ZStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the thumbnail, if available.
***REMOVED******REMOVED******REMOVED******REMOVED***if let thumbnailImage = basemapGalleryItem.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: thumbnailImage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelected ? Color.accentColor: Color.clear,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 3.0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display an image representing either a load basemap error
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** or a spatial reference mismatch error.
***REMOVED******REMOVED******REMOVED******REMOVED***if basemapGalleryItem.loadBasemapsError != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "minus.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED*** else if basemapGalleryItem.spatialReferenceStatus == .noMatch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "x.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display a progress view if the item is loading.
***REMOVED******REMOVED******REMOVED******REMOVED***if basemapGalleryItem.isLoading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(CircularProgressViewStyle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Display the name of the item.
***REMOVED******REMOVED******REMOVED***Text(basemapGalleryItem.name)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED***
***REMOVED******REMOVED***.allowsHitTesting(
***REMOVED******REMOVED******REMOVED***!basemapGalleryItem.isLoading
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Modifiers

public extension BasemapGallery {
***REMOVED******REMOVED***/ The style of the basemap gallery. Defaults to `.automatic`.
***REMOVED******REMOVED***/ - Parameter style: The `Style` to use.
***REMOVED******REMOVED***/ - Returns: The `BasemapGallery`.
***REMOVED***func style(
***REMOVED******REMOVED***_ newStyle: Style
***REMOVED***) -> BasemapGallery {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.style = newStyle
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

***REMOVED*** MARK: AlertItem

***REMOVED***/ An item used to populate a displayed alert.
struct AlertItem {
***REMOVED***var title: String = ""
***REMOVED***var message: String = ""
***REMOVED***

extension AlertItem: Identifiable {
***REMOVED***public var id: UUID { UUID() ***REMOVED***
***REMOVED***

extension AlertItem {
***REMOVED******REMOVED***/ Creates an alert item based on a spatial reference mismatch.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - basemapSR: The basemap's spatial reference.
***REMOVED******REMOVED***/   - geoModelSR: The geomodel's spatial reference.
***REMOVED***init(basemapSR: SpatialReference?, geoModelSR: SpatialReference?) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: "Spatial reference mismatch.",
***REMOVED******REMOVED******REMOVED***message: "The spatial reference of the basemap: \(basemapSR?.description ?? "") does not match that of the geomodel: \(geoModelSR?.description ?? "")."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an alert item based on an error generated loading a basemap.
***REMOVED******REMOVED***/ - Parameter loadBasemapError: The load basemap error.
***REMOVED***init(loadBasemapError: RuntimeError) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: "Error loading basemap.",
***REMOVED******REMOVED******REMOVED***message: "\(loadBasemapError.failureReason ?? "")"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
