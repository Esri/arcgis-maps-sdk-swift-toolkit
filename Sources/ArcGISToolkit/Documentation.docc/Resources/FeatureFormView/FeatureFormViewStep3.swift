***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct FeatureFormExampleView: View {
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID("9f3a674e998f461580006e626611f9ad")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***
***REMOVED***@StateObject private var dataModel = MapDataModel(
***REMOVED******REMOVED***map: makeMap()
***REMOVED***)
***REMOVED***
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***
***REMOVED***@State private var featureForm: FeatureForm?
***REMOVED***
***REMOVED***@State private var showFeatureForm = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***MapView(map: dataModel.map)
***REMOVED***
***REMOVED***
***REMOVED***
