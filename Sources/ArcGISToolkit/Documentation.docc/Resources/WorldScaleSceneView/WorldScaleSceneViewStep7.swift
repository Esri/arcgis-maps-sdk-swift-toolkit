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
***REMOVED******REMOVED***/ The location datasource that is used to access the device location.
***REMOVED***@State private var locationDataSource = SystemLocationDataSource()
***REMOVED***
***REMOVED******REMOVED***/ The graphics overlay which shows a graphic around your initial location.
***REMOVED***@State private var graphicsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***WorldScaleSceneView(
***REMOVED******REMOVED******REMOVED***clippingDistance: 400
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene, graphicsOverlays: [graphicsOverlay])
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***let locationManager = CLLocationManager()
***REMOVED******REMOVED******REMOVED***if locationManager.authorizationStatus == .notDetermined {
***REMOVED******REMOVED******REMOVED******REMOVED***locationManager.requestWhenInUseAuthorization()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***try? await locationDataSource.start()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Retrieve initial location.
***REMOVED******REMOVED******REMOVED***guard let initialLocation = await locationDataSource.locations.first(where: { _ in true ***REMOVED***) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Put a circle graphic around the initial location.
***REMOVED******REMOVED******REMOVED***let circle = GeometryEngine.geodeticBuffer(
***REMOVED******REMOVED******REMOVED******REMOVED***around: initialLocation.position,
***REMOVED******REMOVED******REMOVED******REMOVED***distance: 20,
***REMOVED******REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED******REMOVED***maxDeviation: 1,
***REMOVED******REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(
***REMOVED******REMOVED******REMOVED******REMOVED***Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometry: circle,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol: SimpleLineSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: .red,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 3
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Stop the location datasource after the initial location is retrieved.
***REMOVED******REMOVED******REMOVED***await locationDataSource.stop()
***REMOVED***
***REMOVED***
***REMOVED***
