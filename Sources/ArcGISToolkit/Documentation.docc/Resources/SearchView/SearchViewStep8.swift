***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct SearchExampleView: View {
***REMOVED***@State private var locatorSearchSource = SmartLocatorSearchSource(
***REMOVED******REMOVED***name: "My locator",
***REMOVED******REMOVED***maximumResults: 16,
***REMOVED******REMOVED***maximumSuggestions: 16
***REMOVED***)
***REMOVED***
***REMOVED***@State private var map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State private var searchResultsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED***@State private var searchResultViewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1000000
***REMOVED***)
***REMOVED***
***REMOVED***@State private var isGeoViewNavigating = false
***REMOVED***
***REMOVED***@State private var geoViewExtent: Envelope?
***REMOVED***
***REMOVED***@State private var queryArea: Geometry?
***REMOVED***
***REMOVED***@State private var queryCenter: Point?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: searchResultViewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: [searchResultsOverlay]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onNavigatingChanged { isGeoViewNavigating = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***queryCenter = $0.targetGeometry as? Point
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***geoViewExtent = newValue.extent
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED***SearchView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sources: [locatorSearchSource],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $searchResultViewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoViewProxy: mapViewProxy
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.resultsOverlay(searchResultsOverlay)
***REMOVED******REMOVED******REMOVED******REMOVED***.queryCenter($queryCenter)
***REMOVED******REMOVED******REMOVED******REMOVED***.geoViewExtent($geoViewExtent)
***REMOVED******REMOVED******REMOVED******REMOVED***.isGeoViewNavigating($isGeoViewNavigating)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.leading, .top, .trailing])
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
