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
***REMOVED***
***REMOVED***Toolkit
import CoreLocation

***REMOVED***/ An example that utilizes the `WorldScaleSceneView` to show an augmented reality view
***REMOVED***/ of your current location. Because this is an example that can be run from anywhere,
***REMOVED***/ it places a red circle around your initial location which can be explored.
struct WorldScaleExampleView: View {
***REMOVED***@State private var scene: ArcGIS.Scene = {
***REMOVED******REMOVED******REMOVED*** Creates an elevation source from Terrain3D REST service.
***REMOVED******REMOVED***let elevationServiceURL = URL(string: "https:***REMOVED***elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
***REMOVED******REMOVED***let elevationSource = ArcGISTiledElevationSource(url: elevationServiceURL)
***REMOVED******REMOVED***let surface = Surface()
***REMOVED******REMOVED***surface.addElevationSource(elevationSource)
***REMOVED******REMOVED***let scene = Scene()
***REMOVED******REMOVED***scene.baseSurface = surface
***REMOVED******REMOVED***scene.baseSurface.backgroundGrid.isVisible = false
***REMOVED******REMOVED***scene.baseSurface.navigationConstraint = .unconstrained
***REMOVED******REMOVED***scene.basemap = Basemap(style: .arcGISImagery)
***REMOVED******REMOVED***return scene
***REMOVED***()
***REMOVED***
***REMOVED******REMOVED***/ Basemap opacity.
***REMOVED***@State private var opacity: Float = 1
***REMOVED******REMOVED***/ Graphics overlay to show a graphic around your initial location.
***REMOVED***@State private var graphicsOverlay = GraphicsOverlay()
***REMOVED******REMOVED***/ The location datasource that is used to access the device location.
***REMOVED***@State private var locationDatasSource = SystemLocationDataSource()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***WorldScaleSceneView { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED***SceneView(scene: scene, graphicsOverlays: [graphicsOverlay])
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screen, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Identifying...")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task.detached {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("\(results.count) identify result(s).")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** A slider to adjust the basemap opacity.
***REMOVED******REMOVED******REMOVED***Slider(value: $opacity, in: 0...1.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED***
***REMOVED******REMOVED***.onChange(of: opacity) { opacity in
***REMOVED******REMOVED******REMOVED***guard let basemap = scene.basemap else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***for layer in basemap.baseLayers {
***REMOVED******REMOVED******REMOVED******REMOVED***layer.opacity = opacity
***REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await locationDatasSource.start()
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print("Failed to start location datasource: \(error.localizedDescription)")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Retrieve initial location
***REMOVED******REMOVED******REMOVED***guard let initialLocation = await locationDatasSource.locations.first(where: { _ in true ***REMOVED***) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Put a circle graphic around the initial location
***REMOVED******REMOVED******REMOVED***let circle = GeometryEngine.geodeticBuffer(around: initialLocation.position, distance: 20, distanceUnit: .meters, maxDeviation: 1, curveType: .geodesic)
***REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(Graphic(geometry: circle, symbol: SimpleLineSymbol(color: .red, width: 3)))
***REMOVED***
***REMOVED***
***REMOVED***
