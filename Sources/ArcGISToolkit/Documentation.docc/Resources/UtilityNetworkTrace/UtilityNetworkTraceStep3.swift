***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct UtilityNetworkTraceExampleView: View {
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED***@State var mapPoint: Point?
***REMOVED***
***REMOVED***@State var screenPoint: CGPoint?
***REMOVED***
***REMOVED***@State var resultGraphicsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED***@State var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: [resultGraphicsOverlay]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***let publicSample = try? await ArcGISCredential.publicSample
***REMOVED******REMOVED******REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(publicSample!)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
