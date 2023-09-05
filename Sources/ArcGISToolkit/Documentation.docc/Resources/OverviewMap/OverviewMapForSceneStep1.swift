***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct OverviewMapForSceneView: View {
***REMOVED***@StateObject private var dataModel = SceneDataModel(
***REMOVED******REMOVED***scene: Scene(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***SceneView(scene: dataModel.scene)
***REMOVED***
***REMOVED***
