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
***REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED***OverviewMap.forSceneView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
