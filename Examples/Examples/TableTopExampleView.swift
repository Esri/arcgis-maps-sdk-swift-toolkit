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
***REMOVED***

@available(macCatalyst, unavailable)
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
***REMOVED******REMOVED***scene.baseSurface.navigationConstraint = .unconstrained
***REMOVED******REMOVED***scene.baseSurface.opacity = 0
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
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***clippingDistance: 400
***REMOVED******REMOVED***) { proxy in
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screen, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Identifying...")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("\(results.count) identify result(s).")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
