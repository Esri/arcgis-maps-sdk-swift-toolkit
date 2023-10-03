***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct WorldScaleExampleView: View {
***REMOVED***@State private var scene: ArcGIS.Scene = {
***REMOVED******REMOVED******REMOVED*** Creates an elevation source from Terrain3D REST service.
***REMOVED******REMOVED******REMOVED***let elevationServiceURL = URL(string: "https:***REMOVED***elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
***REMOVED******REMOVED******REMOVED***let elevationSource = ArcGISTiledElevationSource(url: elevationServiceURL)
***REMOVED******REMOVED******REMOVED***let surface = Surface()
***REMOVED******REMOVED******REMOVED***surface.addElevationSource(elevationSource)
***REMOVED******REMOVED***let scene = Scene()
***REMOVED******REMOVED******REMOVED***scene.baseSurface = surface
***REMOVED******REMOVED***scene.baseSurface.backgroundGrid.isVisible = false
***REMOVED******REMOVED******REMOVED***scene.baseSurface.navigationConstraint = .unconstrained
***REMOVED******REMOVED***scene.basemap = Basemap(style: .arcGISImagery)
***REMOVED******REMOVED***scene.addOperationalLayer(.canyonCountyParcels)
***REMOVED******REMOVED***return scene
***REMOVED***()
***REMOVED***
***REMOVED***@State private var opacity: Float = 1
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***WorldScaleSceneView { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screen, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Identifying...")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task.detached {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("\(results.count) identify result(s).")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Slider(value: $opacity, in: 0...1.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED***
***REMOVED******REMOVED***.onChange(of: opacity) { opacity in
***REMOVED******REMOVED******REMOVED***guard let basemap = scene.basemap else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***for layer in basemap.baseLayers {
***REMOVED******REMOVED******REMOVED******REMOVED***layer.opacity = opacity
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension FeatureTable {
***REMOVED***static var canyonCountyParcels: ServiceFeatureTable {
***REMOVED******REMOVED***ServiceFeatureTable(url: URL(string: "https:***REMOVED***services6.arcgis.com/gcOKRHSENxBrmPoN/arcgis/rest/services/Parcels/FeatureServer/6")!)
***REMOVED***
***REMOVED***

extension Layer {
***REMOVED***static var canyonCountyParcels: FeatureLayer {
***REMOVED******REMOVED***let fl = FeatureLayer(featureTable: .canyonCountyParcels)
***REMOVED******REMOVED***fl.renderer = SimpleRenderer(symbol: SimpleLineSymbol(color: .yellow, width: 3))
***REMOVED******REMOVED***return fl
***REMOVED***
***REMOVED***
