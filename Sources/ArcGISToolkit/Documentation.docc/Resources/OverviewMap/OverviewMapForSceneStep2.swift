***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct OverviewMapForSceneView: View {
***REMOVED***@StateObject private var dataModel = SceneDataModel(
***REMOVED******REMOVED***scene: Scene(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***SceneView(scene: dataModel.scene)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED***
***REMOVED***
