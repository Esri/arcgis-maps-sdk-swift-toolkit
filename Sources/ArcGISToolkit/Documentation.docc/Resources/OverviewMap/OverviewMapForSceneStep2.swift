***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct OverviewMapForSceneView: View {
***REMOVED***@State private var scene = Scene(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED***
***REMOVED***
