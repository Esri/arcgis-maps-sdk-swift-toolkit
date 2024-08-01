***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct UtilityNetworkTraceExampleView: View {
***REMOVED***@State private var activeDetent: FloatingPanelDetent = .half
***REMOVED***
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED***@State private var mapPoint: Point?
***REMOVED***
***REMOVED***@State private var resultGraphicsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED***@State private var screenPoint: CGPoint?
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: [resultGraphicsOverlay]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, mapPoint in
***REMOVED******REMOVED******REMOVED******REMOVED***self.screenPoint = screenPoint
***REMOVED******REMOVED******REMOVED******REMOVED***self.mapPoint = mapPoint
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***let publicSample = try? await ArcGISCredential.publicSample
***REMOVED******REMOVED******REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(publicSample!)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: Color(uiColor: .systemGroupedBackground),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $activeDetent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .trailing,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: .constant(true)
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkTrace(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay: $resultGraphicsOverlay,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: $mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***screenPoint: $screenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapViewProxy: mapViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanelDetent($activeDetent)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***

private extension ArcGISCredential {
***REMOVED***static var publicSample: ArcGISCredential {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***try await TokenCredential.credential(
***REMOVED******REMOVED******REMOVED******REMOVED***for: URL(string: "https:***REMOVED***sampleserver7.arcgisonline.com/portal/sharing/rest")!,
***REMOVED******REMOVED******REMOVED******REMOVED***username: "viewer01",
***REMOVED******REMOVED******REMOVED******REMOVED***password: "I68VGU^nMurF"
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
