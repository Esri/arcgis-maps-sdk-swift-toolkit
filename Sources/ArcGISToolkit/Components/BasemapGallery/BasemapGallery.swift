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

***REMOVED******REMOVED***/ The current alert item to display.
***REMOVED***@State
***REMOVED***private var alertItem: AlertItem?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***GalleryView()
***REMOVED******REMOVED******REMOVED***.frame(width: 300)
***REMOVED******REMOVED******REMOVED***.alert(item: $alertItem) { alertItem in
***REMOVED******REMOVED******REMOVED******REMOVED***Alert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: Text(alertItem.title),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***message: Text(alertItem.message)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension BasemapGallery {
***REMOVED******REMOVED***/ The gallery view, displayed in the specified columns.
***REMOVED******REMOVED***/ - Parameter columns: The columns used to display the basemap items.
***REMOVED******REMOVED***/ - Returns: A view representing the basemap gallery with the specified columns.
***REMOVED***func GalleryView() -> some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***let columns = Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)
***REMOVED******REMOVED******REMOVED***LazyVGrid(columns: columns) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.basemapGalleryItems) { basemapGalleryItem in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGalleryItemRow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapGalleryItem: basemapGalleryItem,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelected: basemapGalleryItem == viewModel.currentBasemapGalleryItem
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let loadError = basemapGalleryItem.loadBasemapsError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem = AlertItem(loadBasemapError: loadError)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.currentBasemapGalleryItem = basemapGalleryItem
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
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display a progress view if the item is loading.
***REMOVED******REMOVED******REMOVED******REMOVED***if basemapGalleryItem.isLoading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(CircularProgressViewStyle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
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
***REMOVED***init(loadBasemapError: RuntimeError) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: "Error loading basemap.",
***REMOVED******REMOVED******REMOVED***message: "\(loadBasemapError.failureReason ?? "")"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
