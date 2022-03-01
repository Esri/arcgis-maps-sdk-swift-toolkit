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
***REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?

***REMOVED***@Environment(\.verticalSizeClass)
***REMOVED***private var verticalSizeClass: UserInterfaceSizeClass?

***REMOVED******REMOVED***/ A list of bookmarks for display.
***REMOVED***var bookmarks: [Bookmark]

***REMOVED******REMOVED***/ If `true`, the device is in a compact-width or compact-height orientation.
***REMOVED******REMOVED***/ If `false`, the device is in a regular-width and regular-height orientation.
***REMOVED***private var isCompact: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .compact || verticalSizeClass == .compact
***REMOVED***

***REMOVED******REMOVED***/ Action to be performed when a bookmark is selected.
***REMOVED***var onSelectionChanged: ((Bookmark) -> Void)? = nil

***REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED***@State
***REMOVED***private var scrollViewContentHeight: CGFloat = .zero

***REMOVED******REMOVED***/ Sets a closure to perform when the bookmark selection changes.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - action: The closure to perform when the bookmark selection has changed.
***REMOVED***public func onSelectionChanged(
***REMOVED******REMOVED***perform action: @escaping (Bookmark) -> Void
***REMOVED***) -> BookmarksList {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onSelectionChanged = action
***REMOVED******REMOVED***return copy
***REMOVED***

***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if bookmarks.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("No bookmarks")
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "bookmark.slash")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bookmarks.sorted { $0.name <  $1.name ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id: \.viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) { bookmark in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onSelectionChanged?(bookmark)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(bookmark.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***GeometryReader { geometry -> Color in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scrollViewContentHeight = geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return .clear
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxHeight: isCompact ? .infinity : scrollViewContentHeight
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
