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
