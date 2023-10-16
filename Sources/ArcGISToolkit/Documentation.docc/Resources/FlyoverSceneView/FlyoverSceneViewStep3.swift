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
***REMOVED******REMOVED******REMOVED***initialLocation: Point(
***REMOVED******REMOVED******REMOVED******REMOVED***x: 4.4777,
***REMOVED******REMOVED******REMOVED******REMOVED***y: 51.9244,
***REMOVED******REMOVED******REMOVED******REMOVED***z: 1_000,
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000
***REMOVED******REMOVED***) { sceneViewProxy in
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screen, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task.detached {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let results = try await proxy.identifyLayers(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***screenPoint: screen,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tolerance: 20
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("\(results.count) identify result(s).")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
