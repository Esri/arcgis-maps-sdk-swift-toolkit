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
***REMOVED***Toolkit
***REMOVED***

struct BookmarksExampleView: View {
***REMOVED******REMOVED***/ Represents the number of bookmarks added during runtime.
***REMOVED***@State
***REMOVED***private var bookmarksAdded = 0

***REMOVED******REMOVED***/ A web map with predefined bookmarks.
***REMOVED***private let map = Map(url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!

***REMOVED******REMOVED***/ Indicates if the bookmarks list is shown or not.
***REMOVED******REMOVED***/ - Remark: This allows a developer to control how the bookmarks menu is shown/hidden,
***REMOVED******REMOVED***/ whether that be in a group of options or a standalone button.
***REMOVED***@State
***REMOVED***var showingBookmarks = false

***REMOVED***@State
***REMOVED***var viewpoint: Viewpoint? = nil

***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map, viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onSingleTapGesture { _, point in
***REMOVED******REMOVED******REMOVED******REMOVED***let newBookmark = Bookmark(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: "Added bookmark \(bookmarksAdded + 1)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***center: point,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale: viewpoint?.targetScale ?? 10_000
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***map.addBookmark(newBookmark)
***REMOVED******REMOVED******REMOVED******REMOVED***bookmarksAdded += 1
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .primaryAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showingBookmarks.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Show Bookmarks",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemImage: "bookmark"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.popover(isPresented: $showingBookmarks) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the Bookmarks view with a pre-defined list of bookmarks.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Passing in a viewpoint binding will allow the Bookmarks
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** view to handle bookmark selection.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Bookmarks(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showingBookmarks,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapOrScene: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Or control viewpoint changes yourself:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Bookmarks(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showingBookmarks,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapOrScene: map
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSelectionChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0.viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
