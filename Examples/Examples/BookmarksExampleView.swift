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
***REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?

***REMOVED***@Environment(\.verticalSizeClass)
***REMOVED***private var verticalSizeClass: UserInterfaceSizeClass?

***REMOVED******REMOVED***/ A web map with predefined bookmarks.
***REMOVED***private let map = Map(url: URL(string: "https:***REMOVED***www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!

***REMOVED******REMOVED***/ Indicates if the `Bookmarks` component is shown or not.
***REMOVED******REMOVED***/ - Remark: This allows a developer to control when the `Bookmarks` component is
***REMOVED******REMOVED***/ shown/hidden, whether that be in a group of options or a standalone button.
***REMOVED***@State
***REMOVED***var showingBookmarks = false

***REMOVED******REMOVED***/ Allows for communication between the `Bookmarks` component and a `MapView` or
***REMOVED******REMOVED***/ `SceneView`.
***REMOVED***@State
***REMOVED***var viewpoint: Viewpoint? = nil

***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map, viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the `Bookmarks` components with a pre-defined
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** list of bookmarks. Passing in a `Viewpoint` binding
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** will allow the `Bookmarks` component to handle
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** bookmark selection.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Bookmarks(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showingBookmarks,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapOrScene: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environment(\.horizontalSizeClass, horizontalSizeClass)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environment(\.verticalSizeClass, verticalSizeClass)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the `Bookmarks` component with the list of
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** bookmarks in a map.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Bookmarks(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showingBookmarks,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapOrScene: map
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** In order to handle bookmark selection changes
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** manually, use `onSelectionChanged(perform:)`.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSelectionChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0.viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environment(\.horizontalSizeClass, horizontalSizeClass)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environment(\.verticalSizeClass, verticalSizeClass)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
