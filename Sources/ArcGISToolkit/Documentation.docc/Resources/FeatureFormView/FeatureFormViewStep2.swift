***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct FeatureFormExampleView: View {
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID("f72207ac170a40d8992b7a3507b44fad")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***
***REMOVED***@State private var featureForm: FeatureForm?
***REMOVED***
***REMOVED***@State private var featureFormIsPresented = false
***REMOVED***
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED***@State private var submissionError: Text?
***REMOVED***
