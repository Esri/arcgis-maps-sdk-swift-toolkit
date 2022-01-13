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
***REMOVED******REMOVED***case automatic(listWidth: CGFloat = 125, gridWidth: CGFloat = 300)
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a grid. Defaults to `300`.
***REMOVED******REMOVED***case grid(width: CGFloat = 300)
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a list. Defaults to `125`.
***REMOVED******REMOVED***case list(width: CGFloat = 125)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BasemapGallery`.
***REMOVED******REMOVED***/ - Parameter viewModel: The view model used by the `BasemapGallery`.
***REMOVED***public init(viewModel: BasemapGalleryViewModel? = nil) {
***REMOVED******REMOVED***self.viewModel = viewModel ?? BasemapGalleryViewModel()
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
***REMOVED******REMOVED***/ switch between the two based on-screen real estate. Defaults to ``BasemapGallery/Style/automatic``.
***REMOVED******REMOVED***/ Set using the `style` modifier.
***REMOVED***private var style: Style = .automatic()
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
***REMOVED******REMOVED***/ The width of the gallery, taking into account the horizontal and vertical size classes of the device.
***REMOVED***private var galleryWidth: CGFloat {
***REMOVED******REMOVED***switch style {
***REMOVED******REMOVED***case .list(let width):
***REMOVED******REMOVED******REMOVED***return width
***REMOVED******REMOVED***case .grid(let width):
***REMOVED******REMOVED******REMOVED***return width
***REMOVED******REMOVED***case .automatic(let listWidth, let gridWidth):
***REMOVED******REMOVED******REMOVED***return isRegularWidth ? gridWidth : listWidth
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether to show an error alert.
***REMOVED***@State
***REMOVED***private var showErrorAlert = false
***REMOVED***
***REMOVED******REMOVED***/ The current alert item to display.
***REMOVED***@State
***REMOVED***private var alertItem: AlertItem?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***makeGalleryView()
***REMOVED******REMOVED******REMOVED***.frame(width: galleryWidth)
***REMOVED******REMOVED******REMOVED***.onReceive(
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.$spatialReferenceMismatchError.dropFirst(),
***REMOVED******REMOVED******REMOVED******REMOVED***perform: { error in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let error = error else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem = AlertItem(spatialReferenceMismatchError: error)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED***alertItem?.title ?? "",
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showErrorAlert,
***REMOVED******REMOVED******REMOVED******REMOVED***presenting: alertItem) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.message)
***REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.updateCurrentItem(item)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Modifiers

public extension BasemapGallery {
***REMOVED******REMOVED***/ The style of the basemap gallery. Defaults to ``Style/automatic``.
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
***REMOVED******REMOVED******REMOVED***message: "\((loadBasemapError as? RuntimeError)?.failureReason ?? "The basemap failed to load for an unknown reason.")"
***REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***/ Creates an alert item based on a spatial reference mismatch.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - basemapSR: The basemap's spatial reference.
***REMOVED******REMOVED***/   - geoModelSR: The geomodel's spatial reference.
***REMOVED***init(spatialReferenceMismatchError: SpatialReferenceMismatchError) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: "Spatial reference mismatch.",
***REMOVED******REMOVED******REMOVED***message:
***REMOVED******REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED******REMOVED***The spatial reference of the basemap:
***REMOVED******REMOVED******REMOVED******REMOVED***\(spatialReferenceMismatchError.basemapSR?.description ?? "") does not match that of the geomodel:
***REMOVED******REMOVED******REMOVED******REMOVED***\(spatialReferenceMismatchError.geoModelSR?.description ?? "").
"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
