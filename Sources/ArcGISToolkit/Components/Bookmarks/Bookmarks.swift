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

***REMOVED***/ `Bookmarks` allows a user to view and select from a set of bookmarks.
public struct Bookmarks: View {
***REMOVED******REMOVED***/ A list of selectable bookmarks.
***REMOVED***@State
***REMOVED***private var bookmarks: [Bookmark] = []

***REMOVED******REMOVED***/ A map or scene containing bookmarks.
***REMOVED***private var geoModel: GeoModel?

***REMOVED******REMOVED***/ Indicates if bookmarks have loaded and are ready for display.
***REMOVED***@State
***REMOVED***private var geoModelIsLoaded = false

***REMOVED******REMOVED***/ Determines if the bookmarks list is currently shown or not.
***REMOVED***@Binding
***REMOVED***private var isPresented: Bool

***REMOVED******REMOVED***/ User defined action to be performed when a bookmark is selected.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Use this when you prefer to self-manage the response to a bookmark selection. Use either
***REMOVED******REMOVED***/ `onSelectionChanged` or `viewpoint` exclusively.
***REMOVED***var onSelectionChanged: ((Bookmark) -> Void)? = nil

***REMOVED******REMOVED***/ A bookmark that was selected.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Used to listen for a selection.
***REMOVED***@State
***REMOVED***private var selectedBookmark: Bookmark? = nil

***REMOVED******REMOVED***/ If non-`nil`, this viewpoint is updated when a bookmark is pressed.
***REMOVED***private var viewpoint: Binding<Viewpoint?>?

***REMOVED******REMOVED***/ Sets a closure to perform when the bookmark selection changes.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - action: The closure to perform when the bookmark selection has changed.
***REMOVED***public func onSelectionChanged(
***REMOVED******REMOVED***perform action: @escaping (Bookmark) -> Void
***REMOVED***) -> Bookmarks {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onSelectionChanged = action
***REMOVED******REMOVED***return copy
***REMOVED***

***REMOVED******REMOVED***/ Performs the necessary actions when a bookmark is selected.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This includes indicating that bookmarks should be set to a hidden state, and changing the viewpoint
***REMOVED******REMOVED***/ binding (if provided) or calling the closure provided by the `onSelectionChanged` modifier.
***REMOVED******REMOVED***/ `onSelectionChanged` modifier.
***REMOVED******REMOVED***/ - Parameter bookmark: The bookmark that was selected.
***REMOVED***func selectBookmark(_ bookmark: Bookmark?) {
***REMOVED******REMOVED***guard bookmark != nil else { return ***REMOVED***
***REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED***if let viewpoint = viewpoint {
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = bookmark!.viewpoint
***REMOVED*** else if let onSelectionChanged = onSelectionChanged {
***REMOVED******REMOVED******REMOVED***onSelectionChanged(bookmark!)
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: Determines if the bookmarks list is presented.
***REMOVED******REMOVED***/   - bookmarks: A list of bookmarks. Use this when displaying bookmarks defined at run-time.
***REMOVED******REMOVED***/   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
***REMOVED******REMOVED***/   Alternately, you can use the `.onSelectionChanged` modifier to handle bookmark selection.
***REMOVED***public init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***bookmarks: [Bookmark],
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.bookmarks = bookmarks
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED***

***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: Determines if the bookmarks list is presented.
***REMOVED******REMOVED***/   - mapOrScene: A `GeoModel` authored with pre-existing bookmarks.
***REMOVED******REMOVED***/   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
***REMOVED******REMOVED***/   Alternately, you can use the `.onSelectionChanged` modifier to handle bookmark selection.
***REMOVED***public init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***mapOrScene: GeoModel,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***geoModel = mapOrScene
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED***

***REMOVED***public var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***BookmarksHeader(isPresented: $isPresented)
***REMOVED******REMOVED******REMOVED***if geoModel == nil || geoModelIsLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED***BookmarksList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bookmarks: bookmarks,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedBookmark: $selectedBookmark.onChange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectBookmark($0)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***loading
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ A view that is shown while a `GeoModel` is loading.
***REMOVED***private var loading: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.trailing], 5)
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading")
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await geoModel?.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoModelIsLoaded = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bookmarks = geoModel?.bookmarks ?? []
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
