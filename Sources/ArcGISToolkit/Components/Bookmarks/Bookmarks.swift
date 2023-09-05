***REMOVED*** Copyright 2022 Esri.

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

***REMOVED***/ The `Bookmarks` component will display a list of bookmarks and allow the user to select a
***REMOVED***/ bookmark and perform some action. You can create the component with either an array of
***REMOVED***/ `Bookmark` values, or with a `Map` or `Scene` containing the bookmarks to display.
***REMOVED***/
***REMOVED***/ `Bookmarks` can be configured to handle automated bookmark selection (zooming the map/scene to
***REMOVED***/ the bookmark’s viewpoint) by passing in a `Viewpoint` binding or the client can handle bookmark
***REMOVED***/ selection changes manually using ``onSelectionChanged(perform:)``.
***REMOVED***/
***REMOVED***/ | iPhone | iPad |
***REMOVED***/ | ------ | ---- |
***REMOVED***/ | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202765630-894bee44-a0c2-4435-86f4-c80c4cc4a0b9.png) | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202765729-91c52555-4677-4c2b-b62b-215e6c3790a6.png) |
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ - Can be configured to display bookmarks from a map or scene, or from an array of user-defined
***REMOVED***/ bookmarks.
***REMOVED***/ - Can be configured to automatically zoom the map or scene to a bookmark selection.
***REMOVED***/ - Can be configured to perform a user-defined action when a bookmark is selected.
***REMOVED***/ - Will automatically hide when a bookmark is selected.
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/ 
***REMOVED***/ If a `Viewpoint` binding is provided to the `Bookmarks` view, selecting a bookmark will set that
***REMOVED***/ viewpoint binding to the viewpoint of the bookmark. Selecting a bookmark will dismiss the
***REMOVED***/ `Bookmarks` view. If a `GeoModel` is provided, that geo model's bookmarks will be displayed to
***REMOVED***/ the user.
***REMOVED***/
***REMOVED***/ To see it in action, try out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [BookmarksExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/BookmarksExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `Bookmarks` component see the [Bookmarks Tutorial](https:***REMOVED***developers.arcgis.com/swift/toolkit-api-reference/tutorials/arcgistoolkit/bookmarkstutorial).
public struct Bookmarks: View {
***REMOVED******REMOVED***/ A list of selectable bookmarks.
***REMOVED***@State private var bookmarks: [Bookmark] = []
***REMOVED***
***REMOVED******REMOVED***/ A map or scene containing bookmarks.
***REMOVED***private var geoModel: GeoModel?
***REMOVED***
***REMOVED******REMOVED***/ Indicates if bookmarks have loaded and are ready for display.
***REMOVED***@State private var isGeoModelLoaded = false
***REMOVED***
***REMOVED******REMOVED***/ The height of the header content.
***REMOVED***@State private var headerHeight: CGFloat = .zero
***REMOVED***
***REMOVED******REMOVED***/ Determines if the bookmarks list is currently shown or not.
***REMOVED***@Binding private var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ The height of the list content.
***REMOVED***@State private var listHeight: CGFloat = .zero
***REMOVED***
***REMOVED******REMOVED***/ A bookmark that was selected.
***REMOVED***@State private var selectedBookmark: Bookmark? = nil
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
***REMOVED******REMOVED***/ Sets an action to perform when the bookmark selection changes.
***REMOVED******REMOVED***/ - Parameter action: The action to perform when the bookmark selection has changed.
***REMOVED***public func onSelectionChanged(
***REMOVED******REMOVED***perform action: @escaping (Bookmark) -> Void
***REMOVED***) -> Bookmarks {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.selectionChangedAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Performs the necessary actions when a bookmark is selected.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This includes indicating that bookmarks should be set to a hidden state, and changing the viewpoint
***REMOVED******REMOVED***/ binding (if provided) or calling the action provided by the `onSelectionChanged(perform:)` modifier.
***REMOVED******REMOVED***/ - Parameter bookmark: The bookmark that was selected.
***REMOVED***func selectBookmark(_ bookmark: Bookmark) {
***REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED***if let viewpoint = viewpoint {
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = bookmark.viewpoint
***REMOVED*** else if let onSelectionChanged = selectionChangedAction {
***REMOVED******REMOVED******REMOVED***onSelectionChanged(bookmark)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: Determines if the bookmarks list is presented.
***REMOVED******REMOVED***/   - bookmarks: An array of bookmarks. Use this when displaying bookmarks defined at runtime.
***REMOVED******REMOVED***/   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
***REMOVED******REMOVED***/   Alternately, you can use the `onSelectionChanged(perform:)` modifier to handle
***REMOVED******REMOVED***/   bookmark selection.
***REMOVED***public init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***bookmarks: [Bookmark],
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED******REMOVED***self.bookmarks = bookmarks
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: Determines if the bookmarks list is presented.
***REMOVED******REMOVED***/   - geoModel: A `GeoModel` authored with pre-existing bookmarks.
***REMOVED******REMOVED***/   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
***REMOVED******REMOVED***/   Alternately, you can use the `onSelectionChanged(perform:)` modifier to handle
***REMOVED******REMOVED***/   bookmark selection.
***REMOVED***public init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***geoModel: GeoModel,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.geoModel = geoModel
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***BookmarksHeader(isPresented: $isPresented)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal, .top])
***REMOVED******REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headerHeight = $0.height
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if geoModel == nil || isGeoModelLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BookmarksList(bookmarks: bookmarks)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSelectionChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectBookmark($0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***loadingView
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***listHeight = $0.height
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(idealHeight: headerHeight + listHeight)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view that is shown while a `GeoModel` is loading.
***REMOVED***private var loadingView: some View {
***REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await geoModel?.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bookmarks = geoModel?.bookmarks ?? []
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isGeoModelLoaded = true
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
