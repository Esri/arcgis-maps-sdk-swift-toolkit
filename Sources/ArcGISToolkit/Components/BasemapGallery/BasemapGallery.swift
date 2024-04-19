***REMOVED***
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

***REMOVED***/ The `BasemapGallery` displays a collection of basemaps from ArcGIS Online, a user-defined
***REMOVED***/ portal, or an array of ``BasemapGalleryItem`` objects. When a new basemap is selected from the
***REMOVED***/ `BasemapGallery` and a geo model was provided when the basemap gallery was created, the
***REMOVED***/ basemap of the `geoModel` is replaced with the basemap in the gallery.
***REMOVED***/
***REMOVED***/ | iPhone | iPad |
***REMOVED***/ | ------ | ---- |
***REMOVED***/ | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/205385086-cb9bc0a0-3c46-484d-aefa-8878c7112a3e.png) | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/205384854-79f25efe-25f4-4330-a487-b64b528a9daf.png) |
***REMOVED***/
***REMOVED***/ > Note: `BasemapGallery` uses metered ArcGIS basemaps by default, so you will need to configure
***REMOVED***/ an API key. See [Security and authentication documentation](https:***REMOVED***developers.arcgis.com/documentation/mapping-apis-and-services/security/#api-keys)
***REMOVED***/ for more information.
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ - Can be configured to use a list, grid, or automatic layout. When using an
***REMOVED***/ automatic layout, list or grid presentation is chosen based on the horizontal size class of the
***REMOVED***/ environment.
***REMOVED***/ - Displays basemaps from a portal or a custom collection. If neither a custom portal or array of
***REMOVED***/ basemaps is provided, the list of basemaps will be loaded from ArcGIS Online.
***REMOVED***/ - Displays a representation of the map or scene's current basemap if that basemap exists in the
***REMOVED***/ gallery.
***REMOVED***/ - Displays a name and thumbnail for each basemap.
***REMOVED***/ - Can be configured to automatically change the basemap of a geo model based on user selection.
***REMOVED***/
***REMOVED***/ `BasemapGallery` has the following helper class: ``BasemapGalleryItem``
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ Selecting a basemap with a spatial reference that does not match that of the geo model
***REMOVED***/ will display an error. It will also display an error if a provided base map cannot be loaded. If
***REMOVED***/ a `GeoModel` is provided to the `BasemapGallery`, selecting an item in the gallery will set that
***REMOVED***/ basemap on the geo model.
***REMOVED***/
***REMOVED***/ To see it in action, try out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [BasemapGalleryExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/BasemapGalleryExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `BasemapGallery` see the <doc:BasemapGalleryTutorial>.
public struct BasemapGallery: View {
***REMOVED******REMOVED***/ The view style of the gallery.
***REMOVED***public enum Style {
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a grid when there is an appropriate
***REMOVED******REMOVED******REMOVED***/ width available for the gallery to do so. Otherwise, the gallery will display as a list.
***REMOVED******REMOVED******REMOVED***/ When displayed as a grid, `maxGridItemWidth` sets the maximum width of a grid item.
***REMOVED******REMOVED***case automatic(maxGridItemWidth: CGFloat = 300)
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a grid.
***REMOVED******REMOVED***case grid(maxItemWidth: CGFloat = 300)
***REMOVED******REMOVED******REMOVED***/ The `BasemapGallery` will display as a list.
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
***REMOVED***private var style: Style = .automatic()
***REMOVED***
***REMOVED***@Environment(\.isPortraitOrientation) var isPortraitOrientation
***REMOVED***
***REMOVED******REMOVED***/ If `true`, the gallery will display as if the device is in a regular-width orientation.
***REMOVED******REMOVED***/ If `false`, the gallery will display as if the device is in a compact-width orientation.
***REMOVED***private var isRegularWidth: Bool {
***REMOVED******REMOVED***!isPortraitOrientation
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
***REMOVED******REMOVED******REMOVED***makeGalleryView(geometry.size.width)
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
***REMOVED******REMOVED***/ - Parameter containerWidth: The width of the container holding the gallery.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery.
***REMOVED***func makeGalleryView(_ containerWidth: CGFloat) -> some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***switch style {
***REMOVED******REMOVED******REMOVED***case .automatic(let maxGridItemWidth):
***REMOVED******REMOVED******REMOVED******REMOVED***if isRegularWidth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeGridView(containerWidth, maxGridItemWidth)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeListView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .grid(let maxItemWidth):
***REMOVED******REMOVED******REMOVED******REMOVED***makeGridView(containerWidth, maxItemWidth)
***REMOVED******REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED******REMOVED***makeListView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The gallery view, displayed as a grid.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - containerWidth: The width of the container holding the grid view.
***REMOVED******REMOVED***/   - maxItemWidth: The maximum allowable width for an item in the grid. Defaults to `300`.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery grid.
***REMOVED***func makeGridView(_ containerWidth: CGFloat, _ maxItemWidth: CGFloat) -> some View {
***REMOVED******REMOVED***internalMakeGalleryView(
***REMOVED******REMOVED******REMOVED***columns: Array(
***REMOVED******REMOVED******REMOVED******REMOVED***repeating: GridItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.flexible(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .top
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***count: max(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***1,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Int((containerWidth / maxItemWidth).rounded(.down))
***REMOVED******REMOVED******REMOVED******REMOVED***)
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
***REMOVED******REMOVED***/ The style of the basemap gallery. Defaults to ``Style/automatic(maxGridItemWidth:)``.
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
***REMOVED******REMOVED******REMOVED***title: String.basemapFailedToLoadTitle,
***REMOVED******REMOVED******REMOVED***message: (loadBasemapError as? ArcGISError)?.details ?? String.basemapFailedToLoadFallbackError
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
***REMOVED******REMOVED******REMOVED***message = String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "The basemap has a spatial reference that is incompatible with the map.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** A label indicating the spatial reference of the chosen basemap doesn't
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** match the spatial reference of the map.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case (_, .none):
***REMOVED******REMOVED******REMOVED***message = String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "The map does not have a spatial reference.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating the map doesn't have a spatial reference."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case (.none, _):
***REMOVED******REMOVED******REMOVED***message = String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "The basemap does not have a spatial reference.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating the chosen basemap doesn't have a spatial reference."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Spatial reference mismatch.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** A label indicating the spatial reference of the chosen basemap doesn't
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** match the spatial reference of the map or scene.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***message: message
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension String {
***REMOVED***static let basemapFailedToLoadFallbackError = String(
***REMOVED******REMOVED***localized: "The basemap failed to load for an unknown reason.",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** An error to be displayed when a basemap chosen from the basemap gallery fails to
***REMOVED******REMOVED******REMOVED******REMOVED*** load for an unknown reason.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED***)
***REMOVED***
***REMOVED***static let basemapFailedToLoadTitle = String(
***REMOVED******REMOVED***localized: "Error loading basemap.",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "An error to be displayed when a basemap chosen from the basemap gallery fails to load."
***REMOVED***)
***REMOVED***
