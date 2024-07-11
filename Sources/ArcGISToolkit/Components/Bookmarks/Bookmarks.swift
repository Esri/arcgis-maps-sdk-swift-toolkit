***REMOVED*** Copyright 2022 Esri
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

***REMOVED***/ The `Bookmarks` component displays a list of bookmarks and allows the user to make a selection.
***REMOVED***/ You can initialize the component with an array of bookmarks or with a `GeoModel`
***REMOVED***/ containing bookmarks.
***REMOVED***/
***REMOVED***/ The map or scene will automatically pan and zoom to the selected bookmark when a `GeoViewProxy`
***REMOVED***/ is provided in the initializer. Alternatively, handle selection changes manually using the bound
***REMOVED***/ `selection` property.
***REMOVED***/
***REMOVED***/ The component will automatically hide itself when a selection is made.
***REMOVED***/
***REMOVED***/ @Image(source: Bookmarks, alt: "An image of the Bookmarks component.")
***REMOVED***/
***REMOVED***/ To see it in action, try out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [BookmarksExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/BookmarksExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `Bookmarks` component see the <doc:BookmarksTutorial>.
@MainActor
@preconcurrency
public struct Bookmarks: View {
***REMOVED******REMOVED***/ The data source used to initialize the view.
***REMOVED***enum BookmarkSource {
***REMOVED******REMOVED***case array([Bookmark])
***REMOVED******REMOVED***case geoModel(GeoModel)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The bookmark data source.
***REMOVED***let bookmarkSource: BookmarkSource
***REMOVED***
***REMOVED******REMOVED***/ The proxy to provide access to geo view operations.
***REMOVED***private let geoViewProxy: GeoViewProxy?
***REMOVED***
***REMOVED******REMOVED***/ An error that occurred while loading the geo model.
***REMOVED***@State private var loadingError: Error?
***REMOVED***
***REMOVED******REMOVED***/ Indicates if bookmarks have loaded and are ready for display.
***REMOVED***@State private var isGeoModelLoaded = false
***REMOVED***
***REMOVED******REMOVED***/ Determines if the bookmarks list is currently shown or not.
***REMOVED***@Binding private var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ The selected bookmark.
***REMOVED***private var selection: Binding<Bookmark?>?
***REMOVED***
***REMOVED******REMOVED***/ User defined action to be performed when a bookmark is selected.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Use this when you prefer to self-manage the response to a bookmark selection. Use either
***REMOVED******REMOVED***/ `onSelectionChanged(perform:)` or `viewpoint` exclusively.
***REMOVED***var selectionChangedAction: ((Bookmark) -> Void)? = nil
***REMOVED***
***REMOVED******REMOVED***/ If non-`nil`, this viewpoint is updated when a bookmark is selected.
***REMOVED***private var viewpoint: Binding<Viewpoint?>?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***BookmarksHeader(isPresented: $isPresented)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal, .top])
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***switch bookmarkSource {
***REMOVED******REMOVED******REMOVED***case .array(let array):
***REMOVED******REMOVED******REMOVED******REMOVED***makeList(bookmarks: array)
***REMOVED******REMOVED******REMOVED***case .geoModel(let geoModel):
***REMOVED******REMOVED******REMOVED******REMOVED***if isGeoModelLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeList(bookmarks: geoModel.bookmarks)
***REMOVED******REMOVED******REMOVED*** else if let loadingError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeErrorMessage(with: loadingError)
***REMOVED******REMOVED******REMOVED*** else if !isGeoModelLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeLoadingView(geoModel: geoModel)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED******REMOVED***.frame(idealWidth: 320, idealHeight: 428)
***REMOVED***
***REMOVED***

public extension Bookmarks {
***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: Determines if the bookmarks list is presented.
***REMOVED******REMOVED***/   - bookmarks: An array of bookmarks. Use this when displaying bookmarks defined at runtime.
***REMOVED******REMOVED***/   - selection: A selected Bookmark.
***REMOVED******REMOVED***/   - geoViewProxy: The proxy to provide access to geo view operations.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ When a `GeoViewProxy` is provided, the map or scene will automatically pan and zoom to the
***REMOVED******REMOVED***/ selected bookmark.
***REMOVED***init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***bookmarks: [Bookmark],
***REMOVED******REMOVED***selection: Binding<Bookmark?>,
***REMOVED******REMOVED***geoViewProxy: GeoViewProxy? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***bookmarkSource: .array(bookmarks),
***REMOVED******REMOVED******REMOVED***geoViewProxy: geoViewProxy,
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***selection: selection
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: Determines if the bookmarks list is presented.
***REMOVED******REMOVED***/   - geoModel: A `GeoModel` authored with pre-existing bookmarks.
***REMOVED******REMOVED***/   - selection: A selected Bookmark.
***REMOVED******REMOVED***/   - geoViewProxy: The proxy to provide access to geo view operations.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ When a `GeoViewProxy` is provided, the map or scene will automatically pan and zoom to the
***REMOVED******REMOVED***/ selected bookmark.
***REMOVED***init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***geoModel: GeoModel,
***REMOVED******REMOVED***selection: Binding<Bookmark?>,
***REMOVED******REMOVED***geoViewProxy: GeoViewProxy? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***bookmarkSource: .geoModel(geoModel),
***REMOVED******REMOVED******REMOVED***geoViewProxy: geoViewProxy,
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***selection: selection
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension Bookmarks {
***REMOVED******REMOVED***/ Performs the necessary actions when a bookmark is selected.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This includes indicating that bookmarks should be set to a hidden state, and changing the viewpoint
***REMOVED******REMOVED***/ binding (if provided) or calling the action provided by the `onSelectionChanged(perform:)` modifier.
***REMOVED******REMOVED***/ - Parameter bookmark: The bookmark that was selected.
***REMOVED***func selectBookmark(_ bookmark: Bookmark) {
***REMOVED******REMOVED***selection?.wrappedValue = bookmark
***REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let geoViewProxy, let viewpoint = bookmark.viewpoint {
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***await geoViewProxy.setViewpoint(viewpoint, duration: nil)
***REMOVED******REMOVED***
***REMOVED*** else if let viewpoint = viewpoint {
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = bookmark.viewpoint
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let selectionChangedAction {
***REMOVED******REMOVED******REMOVED***selectionChangedAction(bookmark)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes a view that is shown when the `GeoModel` failed to load.
***REMOVED***private func makeErrorMessage(with loadingError: Error) -> Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Error loading bookmarks: \(loadingError.localizedDescription)",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** An error message shown when a GeoModel failed to load.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The variable provides additional data.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes a view that shows a list of bookmarks.
***REMOVED******REMOVED***/ - Parameter bookmarks: The bookmarks to be shown.
***REMOVED***@ViewBuilder private func makeList(bookmarks: [Bookmark]) -> some View {
***REMOVED******REMOVED***if bookmarks.isEmpty {
***REMOVED******REMOVED******REMOVED***noBookmarks
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***List(bookmarks.sorted { $0.name <  $1.name ***REMOVED***, id: \.self, selection: selection) { bookmark in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** When 'init(isPresented:bookmarks:viewpoint:)' and
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** 'init(isPresented:geoModel:viewpoint:)' are removed, this
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** button can be replaced with 'Text' and the list's selection
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** mechanism and 'onChange(of: selection)' can be used instead.
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectBookmark(bookmark)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(bookmark.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Make the entire row tappable.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(bookmark == selection?.wrappedValue ? nil : Color.clear)
#endif
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes a view that is shown while a `GeoModel` is loading.
***REMOVED***private func makeLoadingView(geoModel: GeoModel) -> some View {
***REMOVED******REMOVED***return ProgressView()
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***.task(id: geoModel) {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await geoModel.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isGeoModelLoaded = true
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***loadingError = error
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view that is shown when no bookmarks are present.
***REMOVED***private var noBookmarks: some View {
***REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"No bookmarks",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating that no bookmarks are available for selection."
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "bookmark.slash")
***REMOVED***
***REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***

public extension Bookmarks /* Deprecated */ {
***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: Determines if the bookmarks list is presented.
***REMOVED******REMOVED***/   - bookmarks: An array of bookmarks. Use this when displaying bookmarks defined at runtime.
***REMOVED******REMOVED***/   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
***REMOVED******REMOVED***/ - Attention: Deprecated at 200.5.
***REMOVED***@available(*, deprecated, message: "Use 'init(isPresented:bookmarks:selection:geoViewProxy:)' instead.")
***REMOVED***init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***bookmarks: [Bookmark],
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***bookmarkSource: .array(bookmarks),
***REMOVED******REMOVED******REMOVED***geoViewProxy: nil,
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: Determines if the bookmarks list is presented.
***REMOVED******REMOVED***/   - geoModel: A `GeoModel` authored with pre-existing bookmarks.
***REMOVED******REMOVED***/   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
***REMOVED******REMOVED***/ - Attention: Deprecated at 200.5.
***REMOVED***@available(*, deprecated, message: "Use 'init(isPresented:geoModel:selection:geoViewProxy:)' instead.")
***REMOVED***init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***geoModel: GeoModel,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***bookmarkSource: .geoModel(geoModel),
***REMOVED******REMOVED******REMOVED***geoViewProxy: nil,
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets an action to perform when the bookmark selection changes.
***REMOVED******REMOVED***/ - Parameter action: The action to perform when the bookmark selection has changed.
***REMOVED******REMOVED***/ - Attention: Deprecated at 200.5.
***REMOVED***@available(*, deprecated)
***REMOVED***func onSelectionChanged(
***REMOVED******REMOVED***perform action: @escaping (Bookmark) -> Void
***REMOVED***) -> Bookmarks {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.selectionChangedAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
