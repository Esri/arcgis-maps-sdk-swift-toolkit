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

***REMOVED***/ `BookmarksList` displays a list of selectable bookmarks.
struct BookmarksList: View {
***REMOVED******REMOVED***/ A list of selectable bookmarks.
***REMOVED***var bookmarks: [Bookmark]?

***REMOVED******REMOVED***/ A list of bookmarks derived either directly from `bookmarks` or from `map`.
***REMOVED***private var definedBookmarks: [Bookmark] {
***REMOVED******REMOVED***var result: [Bookmark] = []
***REMOVED******REMOVED***if let bookmarks = bookmarks {
***REMOVED******REMOVED******REMOVED***result = bookmarks
***REMOVED*** else if let map = map {
***REMOVED******REMOVED******REMOVED***result = map.bookmarks
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return []
***REMOVED***
***REMOVED******REMOVED***return result.sorted { $0.name < $1.name ***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Determines if the list is currently shown or not.
***REMOVED***@Binding
***REMOVED***var isPresented: Bool

***REMOVED******REMOVED***/ A map containing bookmarks.
***REMOVED***var map: Map?

***REMOVED******REMOVED***/ Indicates if bookmarks have loaded and are ready for display.
***REMOVED***@State
***REMOVED***var mapIsLoaded = false

***REMOVED******REMOVED***/ User defined action to be performed when a bookmark is selected.
***REMOVED***var selectionChangedActions: ((Bookmark) -> Void)? = nil

***REMOVED******REMOVED***/ If non-`nil`, this viewpoint is updated when a bookmark is pressed.
***REMOVED***var viewpoint: Binding<Viewpoint?>?

***REMOVED******REMOVED***/ Performs the necessary actions when a bookmark is selected.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This includes indicating that bookmarks should be set to a hidden state, and changing the viewpoint
***REMOVED******REMOVED***/ if the user provided a viewpoint or calling actions if the user implemented the
***REMOVED******REMOVED***/ `selectionChangedActions` modifier.
***REMOVED******REMOVED***/ - Parameter bookmark: The bookmark that was selected.
***REMOVED***func selectBookmark(_ bookmark: Bookmark) {
***REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED***if let viewpoint = viewpoint {
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = bookmark.viewpoint
***REMOVED*** else if let actions = selectionChangedActions {
***REMOVED******REMOVED******REMOVED***actions(bookmark)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***fatalError("No viewpoint or action provided")
***REMOVED***
***REMOVED***

***REMOVED***var body: some View {
***REMOVED******REMOVED***if map == nil {
***REMOVED******REMOVED******REMOVED***bookmarkList
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***if mapIsLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED***bookmarkList
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***loading
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension BookmarksList {
***REMOVED******REMOVED***/ The minimum height of a bookmark list item.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This number will be larger when them item's name consumes 2+ lines of text.
***REMOVED***private var minimumRowHeight: Double {
***REMOVED******REMOVED***44
***REMOVED***

***REMOVED******REMOVED***/ A list that is shown once bookmarks have loaded.
***REMOVED***private var bookmarkList: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***if bookmarks?.isEmpty ?? true {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("No bookmarks")
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "bookmark.slash")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(definedBookmarks, id: \.viewpoint) { bookmark in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectBookmark(bookmark)
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(bookmark.name)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED***minHeight: minimumRowHeight,
***REMOVED******REMOVED******REMOVED***idealHeight: minimumRowHeight * Double(
***REMOVED******REMOVED******REMOVED******REMOVED***max(1, definedBookmarks.count)),
***REMOVED******REMOVED******REMOVED***maxHeight: .infinity
***REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***/ A view that is shown while a web map is loading.
***REMOVED***private var loading: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.trailing], 5)
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading")
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await map?.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapIsLoaded = true
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
