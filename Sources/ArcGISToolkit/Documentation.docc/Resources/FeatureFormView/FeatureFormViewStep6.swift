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
***REMOVED***@State private var featureForm: FeatureForm? {
***REMOVED******REMOVED***didSet { showFeatureForm = featureForm != nil ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@State private var showFeatureForm = false
***REMOVED***
***REMOVED***@State private var floatingPanelDetent: FloatingPanelDetent = .full
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***MapView(map: dataModel.map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let identifyScreenPoint else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let identifyResult = try? await proxy.identifyLayers(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***screenPoint: identifyScreenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tolerance: 10
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.first(where: { result in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = result.geoElements.first as? ArcGISFeature,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   (feature.table?.layer as? FeatureLayer)?.featureFormDefinition != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = identifyResult?.geoElements.first as? ArcGISFeature,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm = FeatureForm(feature: feature, definition: formDefinition)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $floatingPanelDetent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showFeatureForm
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let featureForm {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FeatureFormView(featureForm: featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal])
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
