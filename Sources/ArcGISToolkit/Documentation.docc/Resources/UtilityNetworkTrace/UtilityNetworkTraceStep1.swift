***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct UtilityNetworkTraceExampleView: View {
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED***@State private var mapPoint: Point?
***REMOVED***
***REMOVED***@State private var resultGraphicsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***
