***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct FlyoverExampleView: View {
***REMOVED***@State private var scene = Scene(
***REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: PortalItem.ID("7558ee942b2547019f66885c44d4f0b1")!
***REMOVED******REMOVED***)
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLatitude: 45.54605,
***REMOVED******REMOVED******REMOVED***initialLongitude: -122.69033,
***REMOVED******REMOVED******REMOVED***initialAltitude: 500,
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED***
***REMOVED***
***REMOVED***
