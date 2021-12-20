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
***REMOVED***/ `BasemapGallery.geoModel` property is set, then the basemap of the geoModel is replaced
***REMOVED***/ with the basemap in the gallery.
public struct BasemapGallery: View {
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

***REMOVED******REMOVED***/ A Boolean value indicating whether the error alert should be shown.
***REMOVED***@State
***REMOVED***private var showErrorAlert = false
***REMOVED***
***REMOVED******REMOVED***/ The current alert item to display.
***REMOVED***@State
***REMOVED***private var alertItem: AlertItem?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***makeGalleryView()
***REMOVED******REMOVED******REMOVED***.frame(width: 300)
***REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED***alertItem?.title ?? "",
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showErrorAlert,
***REMOVED******REMOVED******REMOVED******REMOVED***presenting: alertItem) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.message)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension BasemapGallery {
***REMOVED******REMOVED***/ The gallery view, displayed in the specified columns.
***REMOVED******REMOVED***/ - Parameter columns: The columns used to display the basemap items.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery with the specified columns.
***REMOVED***func makeGalleryView() -> some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***let columns = Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)
***REMOVED******REMOVED******REMOVED***LazyVGrid(columns: columns) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.items) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGalleryCell(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***item: item,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelected: item == viewModel.currentItem
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let loadError = item.loadBasemapsError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem = AlertItem(loadBasemapError: loadError)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showErrorAlert = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.currentItem = item
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
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
***REMOVED******REMOVED***/ Creates an alert item based on an error generated loading a basemap.
***REMOVED******REMOVED***/ - Parameter loadBasemapError: The load basemap error.
***REMOVED***init(loadBasemapError: Error) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: "Error loading basemap.",
***REMOVED******REMOVED******REMOVED***message: "\((loadBasemapError as? RuntimeError)?.failureReason ?? "The basemap failed to load for an unknown reason.")"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
