***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct PopupExampleView: View {
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
***REMOVED***@State private var popup: Popup? {
***REMOVED******REMOVED***didSet { showPopup = popup != nil ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@State private var showPopup = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***MapView(map: dataModel.map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let identifyScreenPoint else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let identifyResult = try? await proxy.identifyLayers(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***screenPoint: identifyScreenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tolerance: 10,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***returnPopupsOnly: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***).first
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popup = identifyResult?.popups.first
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
