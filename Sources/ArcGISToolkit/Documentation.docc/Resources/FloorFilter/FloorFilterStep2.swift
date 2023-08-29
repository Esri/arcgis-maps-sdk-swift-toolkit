***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct FloorFilterExampleView: View {
***REMOVED***private var floorFilterAlignment: Alignment { .bottomLeading ***REMOVED***
***REMOVED***
***REMOVED***@State private var map = Map(
***REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID("b4b599a43a474d33946cf0df526426f5")!
***REMOVED******REMOVED***)
***REMOVED***)
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
***REMOVED***
***REMOVED***
