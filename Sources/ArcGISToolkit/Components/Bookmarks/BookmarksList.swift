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
***REMOVED******REMOVED***if let bookmarks = bookmarks {
***REMOVED******REMOVED******REMOVED***return bookmarks
***REMOVED*** else if let map = map {
***REMOVED******REMOVED******REMOVED***return map.bookmarks
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Determines if the list is currently shown or not.
***REMOVED***@Binding
***REMOVED***var isPresented: Bool

***REMOVED******REMOVED***/ A map containing bookmarks.
***REMOVED***var map: Map?

***REMOVED******REMOVED***/ Indicates if bookmarks have loaded and are ready for display.
***REMOVED***@State
***REMOVED***var mapisLoaded = false

***REMOVED******REMOVED***/ User defined action to be performed when a bookmark is selected.
***REMOVED***var selectionChangedActions: ((Bookmark) -> Void)? = nil

***REMOVED******REMOVED***/ If *non-nil*, this viewpoint is updated when a bookmark is pressed.
***REMOVED***var viewpoint: Binding<Viewpoint?>?

***REMOVED******REMOVED***/ Performs the necessary actions when a bookmark is selected. This includes indicating that
***REMOVED******REMOVED***/ bookmarks should be set to a hidden state, and changing the viewpoint if the user provided a
***REMOVED******REMOVED***/ viewpoint or calling actions if the user implemented the `selectionChangedActions` modifier.
***REMOVED******REMOVED***/ - Parameter bookmark: The bookmark that was selected.
***REMOVED***func makeSelection(_ bookmark: Bookmark) {
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
***REMOVED******REMOVED******REMOVED***list
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***if mapisLoaded {
***REMOVED******REMOVED******REMOVED******REMOVED***list
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***loading
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension BookmarksList {
***REMOVED******REMOVED***/ A list that is shown once bookmarks have loaded.
***REMOVED***var list: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***ForEach(definedBookmarks, id: \.viewpoint) { bookmark in
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeSelection(bookmark)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(bookmark.name)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ A view that is shown while a web map is loading.
***REMOVED***var loading: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(CircularProgressViewStyle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loading")
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await map?.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapisLoaded = true
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED***
***REMOVED***
