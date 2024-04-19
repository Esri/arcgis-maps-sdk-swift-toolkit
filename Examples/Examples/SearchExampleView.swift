***REMOVED***
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct SearchExampleView: View {
***REMOVED******REMOVED***/ Provides search behavior customization.
***REMOVED***@State private var locatorSearchSource = SmartLocatorSearchSource(
***REMOVED******REMOVED***name: "My locator",
***REMOVED******REMOVED***maximumResults: 16,
***REMOVED******REMOVED***maximumSuggestions: 16
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED******REMOVED***/ The `GraphicsOverlay` used by the `SearchView` to display search results on the map.
***REMOVED***@State private var searchResultsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED******REMOVED***/ The height of the map view's attribution bar.
***REMOVED***@State private var attributionBarHeight = 0.0
***REMOVED***
***REMOVED******REMOVED***/ The map viewpoint used by the `SearchView` to pan/zoom the map
***REMOVED******REMOVED***/ to the extent of the search results.
***REMOVED***@State private var searchResultViewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1000000
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ Denotes whether the geoview is navigating. Used for the repeat search behavior.
***REMOVED***@State private var isGeoViewNavigating = false
***REMOVED***
***REMOVED******REMOVED***/ The current map/scene view extent. Used to allow repeat searches after panning/zooming the map.
***REMOVED***@State private var geoViewExtent: Envelope?
***REMOVED***
***REMOVED******REMOVED***/ The search area to be used for the current query.
***REMOVED***@State private var queryArea: Geometry?
***REMOVED***
***REMOVED******REMOVED***/ Defines the center for the search.
***REMOVED***@State private var queryCenter: Point?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: searchResultViewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: [searchResultsOverlay]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onAttributionBarHeightChanged { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { attributionBarHeight = newValue ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onNavigatingChanged { isGeoViewNavigating = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***queryCenter = $0.targetGeometry as? Point
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** For "Repeat Search Here" behavior, use the `geoViewExtent` and
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** `isGeoViewNavigating` modifiers on the `SearchView`.
***REMOVED******REMOVED******REMOVED******REMOVED***geoViewExtent = newValue.extent
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The visible area can be used to limit the results by
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** using the `queryArea` modifier on the `SearchView`.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***queryArea = newValue
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED***SearchView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sources: [locatorSearchSource],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $searchResultViewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoViewProxy: mapViewProxy
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.resultsOverlay(searchResultsOverlay)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.queryArea($queryArea)
***REMOVED******REMOVED******REMOVED******REMOVED***.queryCenter($queryCenter)
***REMOVED******REMOVED******REMOVED******REMOVED***.geoViewExtent($geoViewExtent)
***REMOVED******REMOVED******REMOVED******REMOVED***.isGeoViewNavigating($isGeoViewNavigating)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.leading, .top, .trailing])
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], 10 + attributionBarHeight)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
