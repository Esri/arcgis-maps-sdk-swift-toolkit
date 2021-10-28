***REMOVED***.

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
import Combine
***REMOVED***
***REMOVED***Toolkit

struct SearchExampleView: View {
***REMOVED******REMOVED***/ The `SearchViewModel` used to define behavior of the `SearchView`.
***REMOVED***@ObservedObject
***REMOVED***var searchViewModel = SearchViewModel()
***REMOVED***
***REMOVED***let map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED******REMOVED***/ The map viewpoint used by the `SearchView` to pan/zoom the map
***REMOVED******REMOVED***/ to the extent of the search results.
***REMOVED***@State
***REMOVED***var searchResultViewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1000000
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The `GraphicsOverlay` used by the `SearchView` to display search results on the map.
***REMOVED***@State
***REMOVED***var searchResultsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED***@State
***REMOVED***private var isNavigating: Bool = false

***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***viewpoint: searchResultViewpoint,
***REMOVED******REMOVED******REMOVED***graphicsOverlays: [searchResultsOverlay]
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onNavigatingChanged { isNavigating = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.queryCenter = $0.targetGeometry as? Point
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Reset `searchResultViewpoint` here when the user pans/zooms
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** the map, so if the user commits the same search with the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** same result, the Map will pan/zoom to the result.  Otherwise
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** `searchResultViewpoint` doesn't change which doesn't
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** redraw the map with the new viewpoint.
***REMOVED******REMOVED******REMOVED******REMOVED***searchResultViewpoint = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Setting `searchViewModel.queryArea` will limit the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** results to `queryArea`.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.queryArea = newValue

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** For "Repeat Search Here" behavior, set the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** `searchViewModel.extent` property when navigating.
***REMOVED******REMOVED******REMOVED******REMOVED***if isNavigating || searchViewModel.geoViewExtent == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.geoViewExtent = newValue.extent
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***SearchView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel: searchViewModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $searchResultViewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resultsOverlay: searchResultsOverlay
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.searchBarWidth(360.0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear() {
***REMOVED******REMOVED******REMOVED******REMOVED***setupSearchViewModel()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets up any desired customization on `searchViewModel`.
***REMOVED***private func setupSearchViewModel() {
***REMOVED******REMOVED***let smartLocator = SmartLocatorSearchSource(
***REMOVED******REMOVED******REMOVED***name: "My locator",
***REMOVED******REMOVED******REMOVED***maximumResults: 16,
***REMOVED******REMOVED******REMOVED***maximumSuggestions: 16
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***searchViewModel.sources = [smartLocator]
***REMOVED***
***REMOVED***
