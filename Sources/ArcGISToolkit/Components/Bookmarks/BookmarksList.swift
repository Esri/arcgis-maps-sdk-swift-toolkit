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
***REMOVED******REMOVED***/ A list of bookmarks for display.
***REMOVED***var bookmarks: [Bookmark]

***REMOVED******REMOVED***/ The minimum height of a bookmark list item.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This number will be larger when them item's name consumes 2+ lines of text.
***REMOVED***private var minimumRowHeight: Double {
***REMOVED******REMOVED***44
***REMOVED***

***REMOVED******REMOVED***/ A bookmark that was selected.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Indicates to the parent that a selection was made.
***REMOVED***@Binding
***REMOVED***var selectedBookmark: Bookmark?

***REMOVED***var body: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***if bookmarks.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("No bookmarks")
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "bookmark.slash")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bookmarks.sorted { $0.name <  $1.name ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id: \.viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED***) { bookmark in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedBookmark = bookmark
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
***REMOVED******REMOVED******REMOVED******REMOVED***max(1, bookmarks.count)),
***REMOVED******REMOVED******REMOVED***maxHeight: .infinity
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
