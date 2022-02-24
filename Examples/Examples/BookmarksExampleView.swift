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
***REMOVED******REMOVED***/ The map displayed in the map view.
***REMOVED***private let map = Map(basemapStyle: .arcGISImagery)

***REMOVED******REMOVED***/ A web map with predefined bookmarks.
***REMOVED***private let webMap = Map(url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!

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
***REMOVED******REMOVED******REMOVED******REMOVED*** Show the bookmarks control as a button.
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showingBookmarks.toggle()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemName: showingBookmarks ? "bookmark.fill" : "bookmark"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .leading], 10)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Show the bookmarks control as an option within a group
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .primaryAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Menu {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showingBookmarks.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Show Bookmarks",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemImage: "bookmark"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("More Options")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***label: { Label("Options", systemImage: "ellipsis") ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Let the bookmarks component control viewpoint changes:
***REMOVED******REMOVED******REMOVED******REMOVED***Bookmarks(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showingBookmarks,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bookmarks: sampleBookmarks,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED***)

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Or control viewpoint changes yourself:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Bookmarks(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showingBookmarks,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map: webMap
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSelectionChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0.viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension BookmarksExampleView {
***REMOVED***var sampleBookmarks: [Bookmark] {
***REMOVED******REMOVED***[
***REMOVED******REMOVED******REMOVED***Bookmark(
***REMOVED******REMOVED******REMOVED******REMOVED***name: "Yosemite National Park",
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: -119.538330,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 37.865101,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale: 250_000
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***Bookmark(
***REMOVED******REMOVED******REMOVED******REMOVED***name: "Zion National Park",
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: -113.028770,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 37.297817,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale: 250_000
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***Bookmark(
***REMOVED******REMOVED******REMOVED******REMOVED***name: "Yellowstone National Park",
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: -110.584663,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 44.429764,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale: 375_000
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***Bookmark(
***REMOVED******REMOVED******REMOVED******REMOVED***name: "Grand Canyon National Park",
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: -112.1129,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 36.1069,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale: 375_000
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED***]
***REMOVED***
***REMOVED***
