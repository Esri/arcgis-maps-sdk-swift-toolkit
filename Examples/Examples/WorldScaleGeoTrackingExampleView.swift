// Copyright 2023 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS
import ArcGISToolkit
import CoreLocation

/// An example that utilizes the `WorldScaleGeoTrackingSceneView` to show an augmented reality view
/// of your current location. Because this is an example that can be run from anywhere,
/// it places a red circle around your initial location which can be explored.
struct WorldScaleGeoTrackingExampleView: View {
    @State private var scene: ArcGIS.Scene = {
        // Creates an elevation source from Terrain3D REST service.
        let elevationServiceURL = URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
        let elevationSource = ArcGISTiledElevationSource(url: elevationServiceURL)
        let surface = Surface()
        surface.addElevationSource(elevationSource)
        surface.backgroundGrid.isVisible = false
        surface.navigationConstraint = .unconstrained
        let scene = Scene(basemapStyle: .arcGISImagery)
        scene.baseSurface = surface
        scene.addOperationalLayer(.parcelsLayer)
        return scene
    }()
    
    /// The basemap opacity.
    @State private var opacity: Float = 1
    /// The graphics overlay which shows a graphic around your initial location.
    @State private var graphicsOverlay = GraphicsOverlay()
    /// The location datasource that is used to access the device location.
    @State private var locationDataSource = SystemLocationDataSource()
    
    var body: some View {
        VStack {
            WorldScaleGeoTrackingSceneView(locationDataSource: locationDataSource) { proxy in
                SceneView(scene: scene, graphicsOverlays: [graphicsOverlay])
                    .onSingleTapGesture { screen, _ in
                        print("Identifying...")
                        Task {
                            let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
                            print("\(results.count) identify result(s).")
                        }
                    }
            }
            // A slider to adjust the basemap opacity.
            Slider(value: $opacity, in: 0...1)
                .padding(.horizontal)
                .onChange(of: opacity) { opacity in
                    guard let basemap = scene.basemap else { return }
                    basemap.baseLayers.forEach { $0.opacity = opacity }
                }
        }
        .task {
            // Request when-in-use location authorization.
            // This is necessary for 2 reasons:
            // 1. Because we use location datasource to get the initial location in this example
            // in order to display a ring around the initial location.
            // 2. Because the `WorldScaleSceneView` utilizes a location datasource and that
            // datasource will not start until authorized.
            let locationManager = CLLocationManager()
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            // Retrieve initial location.
            guard let initialLocation = await locationDataSource.locations.first(where: { _ in true }) else { return }
            
            // Put a circle graphic around the initial location.
            let circle = GeometryEngine.geodeticBuffer(around: initialLocation.position, distance: 20, distanceUnit: .meters, maxDeviation: 1, curveType: .geodesic)
            graphicsOverlay.addGraphic(Graphic(geometry: circle, symbol: SimpleLineSymbol(color: .red, width: 3)))
        }
    }
}

private extension Layer {
    /// A feature layer with San Bernardino parcels data.
    static var parcelsLayer: FeatureLayer {
        let parcelsTable = ServiceFeatureTable(url: URL(string: "https://services.arcgis.com/aA3snZwJfFkVyDuP/ArcGIS/rest/services/Parcels_for_San_Bernardino_County/FeatureServer/0")!)
        let featureLayer = FeatureLayer(featureTable: parcelsTable)
        featureLayer.renderer = SimpleRenderer(symbol: SimpleLineSymbol(color: .cyan, width: 3))
        return featureLayer
    }
}
