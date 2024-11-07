***REMOVED*** Copyright 2023 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***Toolkit
import CoreLocation
***REMOVED***

***REMOVED***/ An example that utilizes the `WorldScaleSceneView` to show an augmented reality view
***REMOVED***/ of your current location. Because this is an example that can be run from anywhere,
***REMOVED***/ it places a red circle around your initial location which can be explored.
@available(macCatalyst, unavailable)
struct WorldScaleExampleView: View {
***REMOVED***@State private var scene: ArcGIS.Scene = {
***REMOVED******REMOVED******REMOVED*** Creates an elevation source from Terrain3D REST service.
***REMOVED******REMOVED***let elevationServiceURL = URL(string: "https:***REMOVED***elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
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
***REMOVED******REMOVED***/ The graphics overlay which shows a graphic around your initial location and marker symbols.
***REMOVED***@State private var graphicsOverlay: GraphicsOverlay = {
***REMOVED******REMOVED***let graphicsOverlay = GraphicsOverlay()
***REMOVED******REMOVED***let markerImage = UIImage(named: "RedMarker")!
***REMOVED******REMOVED***let markerSymbol = PictureMarkerSymbol(image: markerImage)
***REMOVED******REMOVED***markerSymbol.height = 150
***REMOVED******REMOVED***
***REMOVED******REMOVED***graphicsOverlay.renderer = SimpleRenderer(symbol: markerSymbol)
***REMOVED******REMOVED***graphicsOverlay.sceneProperties.surfacePlacement = .absolute
***REMOVED******REMOVED***return graphicsOverlay
***REMOVED***()
***REMOVED******REMOVED***/ The location datasource that is used to access the device location.
***REMOVED***@State private var locationDataSource = SystemLocationDataSource()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***WorldScaleSceneView { proxy in
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene, graphicsOverlays: [graphicsOverlay])
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screen, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Identifying...")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("\(results.count) identify result(s).")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.calibrationButtonAlignment(.bottomLeading)
***REMOVED******REMOVED***.onSingleTapGesture { _, scenePoint in
***REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(Graphic(geometry: scenePoint))
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED*** Request when-in-use location authorization.
***REMOVED******REMOVED******REMOVED******REMOVED*** This is necessary for 2 reasons:
***REMOVED******REMOVED******REMOVED******REMOVED*** 1. Because we use location datasource to get the initial location in this example
***REMOVED******REMOVED******REMOVED******REMOVED*** in order to display a ring around the initial location.
***REMOVED******REMOVED******REMOVED******REMOVED*** 2. Because the `WorldScaleSceneView` utilizes a location datasource and that
***REMOVED******REMOVED******REMOVED******REMOVED*** datasource will not start until authorized.
***REMOVED******REMOVED******REMOVED***let locationManager = CLLocationManager()
***REMOVED******REMOVED******REMOVED***if locationManager.authorizationStatus == .notDetermined {
***REMOVED******REMOVED******REMOVED******REMOVED***locationManager.requestWhenInUseAuthorization()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***try? await locationDataSource.start()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Retrieve initial location.
***REMOVED******REMOVED******REMOVED***guard let initialLocation = await locationDataSource.locations.first(where: { @Sendable _ in true ***REMOVED***) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Put a circle graphic around the initial location.
***REMOVED******REMOVED******REMOVED***let circle = GeometryEngine.geodeticBuffer(around: initialLocation.position, distance: 20, distanceUnit: .meters, maxDeviation: 1, curveType: .geodesic)
***REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(Graphic(geometry: circle, symbol: SimpleLineSymbol(color: .red, width: 3)))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Stop the location data source after the initial location is retrieved.
***REMOVED******REMOVED******REMOVED***await locationDataSource.stop()
***REMOVED***
***REMOVED***
***REMOVED***
