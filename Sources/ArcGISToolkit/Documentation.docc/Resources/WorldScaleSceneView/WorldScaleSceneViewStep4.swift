***REMOVED***
***REMOVED***Toolkit
import CoreLocation
***REMOVED***

struct WorldScaleExampleView: View {
***REMOVED***@State private var scene: ArcGIS.Scene = {
***REMOVED******REMOVED******REMOVED*** Creates an elevation source from Terrain3D REST service.
***REMOVED******REMOVED***let elevationServiceURL = URL(
***REMOVED******REMOVED******REMOVED***string: "https:***REMOVED***elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
***REMOVED******REMOVED***)!
***REMOVED******REMOVED***let elevationSource = ArcGISTiledElevationSource(url: elevationServiceURL)
***REMOVED******REMOVED***let surface = Surface()
***REMOVED******REMOVED***surface.addElevationSource(elevationSource)
***REMOVED******REMOVED***surface.backgroundGrid.isVisible = false
***REMOVED******REMOVED***surface.navigationConstraint = .unconstrained
***REMOVED******REMOVED***let scene = Scene(basemapStyle: .arcGISImagery)
***REMOVED******REMOVED***scene.baseSurface = surface
***REMOVED******REMOVED***scene.baseSurface.opacity = 0
***REMOVED******REMOVED***return scene
***REMOVED***()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***WorldScaleSceneView(
***REMOVED******REMOVED******REMOVED***clippingDistance: 400
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***let locationManager = CLLocationManager()
***REMOVED******REMOVED******REMOVED***if locationManager.authorizationStatus == .notDetermined {
***REMOVED******REMOVED******REMOVED******REMOVED***locationManager.requestWhenInUseAuthorization()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
