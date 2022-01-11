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
***REMOVED******REMOVED***/ The size class used to determine if the basemap items should dispaly in a list or grid.
***REMOVED******REMOVED***/ If the size class is `.regular`, they display in a grid. If it is `.compact`, they display in a list.
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ `true` if the horizontal size class is `.regular`, `false` if it's not.
***REMOVED***private var isRegularWidth: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .regular
***REMOVED***

***REMOVED******REMOVED***/ The width of the gallery, taking into account the horizontal size class of the device.
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
***REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED***alertItem?.title ?? "",
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showErrorAlert,
***REMOVED******REMOVED******REMOVED******REMOVED***presenting: alertItem) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.message)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension BasemapGallery {
***REMOVED******REMOVED***/ The gallery view.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery.
***REMOVED***func makeGalleryView() -> some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***switch style {
***REMOVED******REMOVED******REMOVED***case .automatic:
***REMOVED******REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeGridView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else {
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
***REMOVED******REMOVED******REMOVED***Array(
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
***REMOVED******REMOVED******REMOVED***[
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
***REMOVED***func internalMakeGalleryView(_ columns: [GridItem]) -> some View {
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.currentItem = item
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
***REMOVED***
