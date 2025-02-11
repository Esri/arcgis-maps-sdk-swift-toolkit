***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct FloorFilterExampleView: View {
***REMOVED***private var floorFilterAlignment: Alignment { .bottomLeading ***REMOVED***
***REMOVED***
***REMOVED***@State private var isMapLoaded = false
***REMOVED***
***REMOVED***@State private var isNavigating = false
***REMOVED***
***REMOVED***@State private var map = Map(
***REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID("b4b599a43a474d33946cf0df526426f5")!
***REMOVED******REMOVED***)
***REMOVED***)
***REMOVED***
***REMOVED***@State private var mapLoadError = false
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED***x: -117.19496,
***REMOVED******REMOVED******REMOVED***y: 34.05713,
***REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED***),
***REMOVED******REMOVED***scale: 100_000
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map, viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED***.onNavigatingChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***isNavigating = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: floorFilterAlignment) {
***REMOVED******REMOVED******REMOVED******REMOVED***if isMapLoaded,
***REMOVED******REMOVED******REMOVED******REMOVED***   let floorManager = map.floorManager {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FloorFilter(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: floorFilterAlignment,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isNavigating: $isNavigating
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: 400,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxHeight: 400
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal], 10)
***REMOVED******REMOVED******REMOVED*** else if mapLoadError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Map load error!",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemImage: "exclamationmark.triangle"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxHeight: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .center
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isMapLoaded = true
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapLoadError = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
