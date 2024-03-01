***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct SearchExampleView: View {
***REMOVED***let locatorSearchSource = SmartLocatorSearchSource(
***REMOVED******REMOVED***name: "My locator",
***REMOVED******REMOVED***maximumResults: 16,
***REMOVED******REMOVED***maximumSuggestions: 16
***REMOVED***)
***REMOVED***
***REMOVED***@StateObject private var dataModel = MapDataModel(
***REMOVED******REMOVED***map: Map(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED***@State private var searchResultViewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1000000
***REMOVED***)
***REMOVED***
