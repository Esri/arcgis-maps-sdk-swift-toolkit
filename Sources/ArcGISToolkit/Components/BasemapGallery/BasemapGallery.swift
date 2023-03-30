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

***REMOVED***/ The `BasemapGallery` tool displays a collection of basemaps from either
***REMOVED***/ ArcGIS Online, a user-defined portal, or an array of `BasemapGalleryItem`s.
***REMOVED***/ When a new basemap is selected from the `BasemapGallery` and the optional
***REMOVED***/ `BasemapGalleryViewModel.geoModel` property is set, then the basemap of the
***REMOVED***/ `geoModel` is replaced with the basemap in the gallery.
public struct BasemapGallery: View {
***REMOVED******REMOVED***/ The view style of the gallery.
***REMOVED***public enum Style {
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a grid when there is an appropriate
***REMOVED******REMOVED******REMOVED***/ width available for the gallery to do so. Otherwise, the gallery will display as a list.
***REMOVED******REMOVED******REMOVED***/ Defaults to `125` when displayed as a list, `300` when displayed as a grid.
***REMOVED******REMOVED***case automatic
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a grid. Defaults to `300`.
***REMOVED******REMOVED***case grid
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a list. Defaults to `125`.
***REMOVED******REMOVED***case list
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BasemapGallery` with the given geo model and array of basemap gallery items.
***REMOVED******REMOVED***/ - Remark: If `items` is empty, ArcGIS Online's developer basemaps will
***REMOVED******REMOVED***/ be loaded and added to `items`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - items: A list of pre-defined base maps to display.
***REMOVED******REMOVED***/   - geoModel: A geo model.
***REMOVED***public init(
***REMOVED******REMOVED***items: [BasemapGalleryItem] = [],
***REMOVED******REMOVED***geoModel: GeoModel? = nil
***REMOVED***) {
***REMOVED******REMOVED***_viewModel = StateObject(wrappedValue: BasemapGalleryViewModel(geoModel: geoModel, items: items))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BasemapGallery` with the given geo model and portal.
***REMOVED******REMOVED***/ The portal will be used to retrieve basemaps.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - portal: The portal to use to load basemaps.
***REMOVED******REMOVED***/   - geoModel: A geo model.
***REMOVED***public init(
***REMOVED******REMOVED***portal: Portal,
***REMOVED******REMOVED***geoModel: GeoModel? = nil
***REMOVED***) {
***REMOVED******REMOVED***_viewModel = StateObject(wrappedValue: BasemapGalleryViewModel(geoModel, portal: portal))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `BasemapGalleryViewModel` manages the state
***REMOVED******REMOVED***/ of the `BasemapGallery`. The view observes `BasemapGalleryViewModel` for changes
***REMOVED******REMOVED***/ in state. The view updates the state of the `BasemapGalleryViewModel` in response to
***REMOVED******REMOVED***/ user action.
***REMOVED***@StateObject private var viewModel: BasemapGalleryViewModel
***REMOVED***
***REMOVED******REMOVED***/ The style of the basemap gallery. The gallery can be displayed as a list, grid, or automatically
***REMOVED******REMOVED***/ switch between the two based on-screen real estate. Defaults to ``BasemapGallery/Style/automatic``.
***REMOVED******REMOVED***/ Set using the `style` modifier.
***REMOVED***private var style: Style = .automatic
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ If `true`, the gallery will display as if the device is in a regular-width orientation.
***REMOVED******REMOVED***/ If `false`, the gallery will display as if the device is in a compact-width orientation.
***REMOVED***private var isRegularWidth: Bool {
***REMOVED******REMOVED***!(horizontalSizeClass == .compact && verticalSizeClass == .regular)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether to show an error alert.
***REMOVED***@State private var showErrorAlert = false
***REMOVED***
***REMOVED******REMOVED***/ The current alert item to display.
***REMOVED***@State private var alertItem: AlertItem?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***makeGalleryView()
***REMOVED******REMOVED******REMOVED******REMOVED***.onReceive(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.$spatialReferenceMismatchError.dropFirst(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***perform: { error in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let error = error else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem = AlertItem(spatialReferenceMismatchError: error)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showErrorAlert = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem?.title ?? "",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showErrorAlert,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***presenting: alertItem
***REMOVED******REMOVED******REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED*** message: { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.message)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: geometry.size.width,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height: geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

private extension BasemapGallery {
***REMOVED******REMOVED***/ Creates a gallery view.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery.
***REMOVED***func makeGalleryView() -> some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***switch style {
***REMOVED******REMOVED******REMOVED***case .automatic:
***REMOVED******REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeGridView()
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeListView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .grid:
***REMOVED******REMOVED******REMOVED******REMOVED***makeGridView()
***REMOVED******REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED******REMOVED***makeListView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The gallery view, displayed as a grid.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery grid.
***REMOVED***func makeGridView() -> some View {
***REMOVED******REMOVED***internalMakeGalleryView(
***REMOVED******REMOVED******REMOVED***columns: Array(
***REMOVED******REMOVED******REMOVED******REMOVED***repeating: GridItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.flexible(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .top
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***count: 3
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The gallery view, displayed as a list.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery list.
***REMOVED***func makeListView() -> some View {
***REMOVED******REMOVED***internalMakeGalleryView(
***REMOVED******REMOVED******REMOVED***columns: [
***REMOVED******REMOVED******REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.flexible(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .top
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The gallery view, displayed in the specified columns.
***REMOVED******REMOVED***/ - Parameter columns: The columns used to display the basemap items.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery with the specified columns.
***REMOVED***func internalMakeGalleryView(columns: [GridItem]) -> some View {
***REMOVED******REMOVED***LazyVGrid(columns: columns) {
***REMOVED******REMOVED******REMOVED***ForEach(viewModel.items) { item in
***REMOVED******REMOVED******REMOVED******REMOVED***BasemapGalleryCell(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***item: item,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelected: item == viewModel.currentItem
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let loadError = item.loadBasemapError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem = AlertItem(loadBasemapError: loadError)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showErrorAlert = true
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setCurrentItem(item)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Modifiers

public extension BasemapGallery {
***REMOVED******REMOVED***/ The style of the basemap gallery. Defaults to ``Style/automatic(listWidth:gridWidth:)``.
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

extension AlertItem {
***REMOVED******REMOVED***/ Creates an alert item based on an error generated loading a basemap.
***REMOVED******REMOVED***/ - Parameter loadBasemapError: The load basemap error.
***REMOVED***init(loadBasemapError: Error) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: "Error loading basemap.",
***REMOVED******REMOVED******REMOVED***message: "\((loadBasemapError as? ArcGISError)?.details ?? "The basemap failed to load for an unknown reason.")"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an alert item based on a spatial reference mismatch error.
***REMOVED******REMOVED***/ - Parameter spatialReferenceMismatchError: The error associated with the mismatch.
***REMOVED***init(spatialReferenceMismatchError: SpatialReferenceMismatchError) {
***REMOVED******REMOVED***let message: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch (spatialReferenceMismatchError.basemapSpatialReference, spatialReferenceMismatchError.geoModelSpatialReference) {
***REMOVED******REMOVED***case (.some(_), .some(_)):
***REMOVED******REMOVED******REMOVED***message = "The basemap has a spatial reference that is incompatible with the map."
***REMOVED******REMOVED***case (_, .none):
***REMOVED******REMOVED******REMOVED***message = "The map does not have a spatial reference."
***REMOVED******REMOVED***case (.none, _):
***REMOVED******REMOVED******REMOVED***message = "The basemap does not have a spatial reference."
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: "Spatial reference mismatch.",
***REMOVED******REMOVED******REMOVED***message: message
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
