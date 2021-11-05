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
***REMOVED******REMOVED***/ Set using the `basemapGalleryStyle` modifier.
***REMOVED***private var style: BasemapGalleryStyle = .automatic
***REMOVED***
***REMOVED******REMOVED***/ The size class used to determine if the basemap items should dispaly in a list or grid.
***REMOVED******REMOVED***/ If the size class is `.regular`, they display in a grid.  If it is `.compact`, they display in a list.
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass
***REMOVED***
***REMOVED***@State
***REMOVED***private var alertItem: AlertItem?

***REMOVED***public var body: some View {
***REMOVED******REMOVED***GalleryView()
***REMOVED******REMOVED******REMOVED***.alert(item: $alertItem) { alertItem in
***REMOVED******REMOVED******REMOVED******REMOVED***Alert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: Text(alertItem.title),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***message: Text(alertItem.message)
***REMOVED******REMOVED******REMOVED******REMOVED***)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelected: basemapGalleryItem == viewModel.currentBasemapGalleryItem
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Don't check spatial reference until user taps on it.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** At this point, we need to get errors from setting the basemap (in the model?).
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Error in the model, displayed in the gallery.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO:  this doesn't work until the basemap is tapped on once, then I assume
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO: it's loaded the basemap layers.  Figure this out.  (load base layers when bm loads?)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let loadError = basemapGalleryItem.loadBasemapsError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem = AlertItem(error: loadError)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("basemaps DON'T match (or error)!")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !showingBasemapLoadError,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   basemapGalleryItem.matchesSpatialReference(viewModel.geoModel?.spatialReference) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await basemapGalleryItem.updateSpatialReferenceStatus(for: viewModel.geoModel?.spatialReference)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if basemapGalleryItem.spatialReferenceStatus == .match ||
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapGalleryItem.spatialReferenceStatus == .unknown {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("basemap matches!")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.currentBasemapGalleryItem = basemapGalleryItem
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertItem = AlertItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***basemapSR: basemapGalleryItem.spatialReference,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoModelSR: viewModel.geoModel?.spatialReference
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Task bm don't match")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***

private struct BasemapGalleryItemRow: View {
***REMOVED***@ObservedObject var basemapGalleryItem: BasemapGalleryItem
***REMOVED***let isSelected: Bool
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if basemapGalleryItem.isLoading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   .progressViewStyle(CircularProgressViewStyle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()

***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ZStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let thumbnailImage = basemapGalleryItem.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: thumbnailImage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelected ? Color.accentColor: Color.clear,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 3.0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if basemapGalleryItem.loadBasemapsError != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "minus.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else if basemapGalleryItem.spatialReferenceStatus == .noMatch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "x.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Text(basemapGalleryItem.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.allowsHitTesting(
***REMOVED******REMOVED******REMOVED***!basemapGalleryItem.isLoading
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

struct AlertItem {
***REMOVED***var title: String = ""
***REMOVED***var message: String = ""
***REMOVED***

extension AlertItem: Identifiable {
***REMOVED***public var id: UUID { UUID() ***REMOVED***
***REMOVED***

***REMOVED*** TODO: add SR for basemap, if possible (SR property on basemap?)  Maybe that can speed up baselayer sr checking...
***REMOVED*** TODO: Cleanup all .tapGesture code, alert code, old error/alert stuff
***REMOVED*** TODO: Figure out common errors, so I don't need to rely on `Error` or `RuntimeError`.
extension AlertItem {
***REMOVED***init(basemapSR: SpatialReference?, geoModelSR: SpatialReference?) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: "Spatial Reference mismatch.",
***REMOVED******REMOVED******REMOVED***message: "The spatial reference of the basemap \(basemapSR?.description ?? "") does not match that of the GeoModel \(geoModelSR?.description ?? "")."
***REMOVED******REMOVED***)
***REMOVED***

***REMOVED***init(error: Error) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: "Error loading basemap.",
***REMOVED******REMOVED******REMOVED***message: "\(error.localizedDescription)"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
