***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct TableTopExampleView: View {
***REMOVED***@State private var scene: ArcGIS.Scene = {
***REMOVED******REMOVED******REMOVED*** Creates a scene layer from buildings REST service.
***REMOVED******REMOVED***let buildingsURL = URL(string: "https:***REMOVED***tiles.arcgis.com/tiles/P3ePLMYs2RVChkJx/arcgis/rest/services/DevA_BuildingShells/SceneServer")!
***REMOVED******REMOVED***let buildingsLayer = ArcGISSceneLayer(url: buildingsURL)
***REMOVED******REMOVED******REMOVED*** Creates an elevation source from Terrain3D REST service.
***REMOVED******REMOVED***let elevationServiceURL = URL(string: "https:***REMOVED***elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
***REMOVED******REMOVED***let elevationSource = ArcGISTiledElevationSource(url: elevationServiceURL)
***REMOVED******REMOVED***let surface = Surface()
***REMOVED******REMOVED***surface.addElevationSource(elevationSource)
***REMOVED******REMOVED***let scene = Scene()
***REMOVED******REMOVED***scene.baseSurface = surface
***REMOVED******REMOVED***scene.addOperationalLayer(buildingsLayer)
***REMOVED******REMOVED***return scene
***REMOVED***()
***REMOVED***
***REMOVED***private let anchorPoint = Point(
***REMOVED******REMOVED***x: -122.68350326165559,
***REMOVED******REMOVED***y: 45.53257485106716,
***REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***TableTopSceneView(
***REMOVED******REMOVED******REMOVED***anchorPoint: anchorPoint,
***REMOVED******REMOVED******REMOVED***translationFactor: 400,
***REMOVED******REMOVED******REMOVED***clippingDistance: 400
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED***
***REMOVED***
***REMOVED***
