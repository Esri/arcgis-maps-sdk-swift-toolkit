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

***REMOVED***/ `Bookmarks` allows for a user to view and select from a set of bookmarks.
public struct Bookmarks: View {
***REMOVED******REMOVED***/ A list that displays bookmarks.
***REMOVED***private var bookmarksList: BookmarksList

***REMOVED******REMOVED***/ Determines if the bookmarks list is currently shown or not.
***REMOVED***@Binding
***REMOVED***private var isPresented: Bool

***REMOVED******REMOVED***/ User defined action to be performed when a bookmark is selected. Use this when you prefer to
***REMOVED******REMOVED***/ self-manage the response to a bookmark selection. Use either `onSelectionChangedActions`
***REMOVED******REMOVED***/ or `viewpoint` exclusively.
***REMOVED***var selectionChangedActions: ((Bookmark) -> Void)? = nil {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***bookmarksList.selectionChangedActions = selectionChangedActions
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Creates a `Bookmarks` component.
***REMOVED******REMOVED***/ - precondition: `bookmarks` or `map` is non-nil.
***REMOVED******REMOVED***/ - precondition: `viewpoint` is non-nil or the `selectionChangedActions` modifier is
***REMOVED******REMOVED***/ implemented.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: Determines if the bookmarks list is presented.
***REMOVED******REMOVED***/   - bookmarks: A list of bookmarks. Use this when displaying bookmarks defined at run-time.
***REMOVED******REMOVED***/   Use either `bookmarks` or `map` exclusively.
***REMOVED******REMOVED***/   - map: A web map authored with pre-existing bookmarks. Use either `map` or `bookmarks`
***REMOVED******REMOVED***/   exclusively.
***REMOVED******REMOVED***/   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected. Use
***REMOVED******REMOVED***/   either `viewpoint` or `selectionChangedActions` exclusively.
***REMOVED***public init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***bookmarks: [Bookmark]? = nil,
***REMOVED******REMOVED***map: Map? = nil,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***precondition((bookmarks != nil) || (map != nil))
***REMOVED******REMOVED***bookmarksList = BookmarksList(
***REMOVED******REMOVED******REMOVED***bookmarks: bookmarks,
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***selectionChangedActions: selectionChangedActions,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED***

***REMOVED***public var body: some View {
***REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***BookmarksHeader(isPresented: $isPresented)
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***bookmarksList
***REMOVED******REMOVED***
***REMOVED***

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
***REMOVED***
