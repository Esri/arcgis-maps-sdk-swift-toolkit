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

***REMOVED***/ The bookmarks component allows for a user to select and navigate to defined set of "bookmarked"
***REMOVED***/ locations.
public struct Bookmarks: View {
***REMOVED***private var bookmarks: [Bookmark]

***REMOVED******REMOVED***/ Determines if the bookmarks list is currently shown or not.
***REMOVED***@Binding
***REMOVED***private var isPresented: Bool

***REMOVED***private var viewpoint: Binding<Viewpoint?>?

***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED***public init(
***REMOVED******REMOVED***_ bookmarks: [Bookmark],
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.bookmarks = bookmarks
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED***

***REMOVED***var selectionChangedActions: ((Bookmark) -> Void)? = nil

***REMOVED******REMOVED***/ Sets a closure to perform when the viewpoint of the map view changes.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - kind: The kind of viewpoint passed to the `action` closure.
***REMOVED******REMOVED***/   - action: The closure to perform when the viewpoint has changed.
***REMOVED***public func onSelectionChanged(
***REMOVED******REMOVED***perform action: @escaping (Bookmark) -> Void
***REMOVED***) -> Bookmarks {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.selectionChangedActions = action
***REMOVED******REMOVED***return copy
***REMOVED***

***REMOVED***public var body: some View {
***REMOVED******REMOVED***if isPresented {
***REMOVED******REMOVED******REMOVED***FloatingPanel {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(bookmarks, id: \.viewpoint) { bookmark in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let viewpoint = viewpoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = bookmark.viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectionChangedActions?(bookmark)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(bookmark.name)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
