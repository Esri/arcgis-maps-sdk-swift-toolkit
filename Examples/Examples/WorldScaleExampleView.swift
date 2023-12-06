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

/// An example that utilizes the `WorldScaleSceneView` to show an augmented reality view
/// of your current location. Because this is an example that can be run from anywhere,
/// it places a red circle around your initial location which can be explored.
struct WorldScaleExampleView: View {
    @State private var scene: ArcGIS.Scene = {
        // Creates an elevation source from Terrain3D REST service.
        let elevationServiceURL = URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
        let elevationSource = ArcGISTiledElevationSource(url: elevationServiceURL)
        let surface = Surface()
        surface.addElevationSource(elevationSource)
        let scene = Scene()
        scene.baseSurface = surface
        scene.baseSurface.backgroundGrid.isVisible = false
        scene.baseSurface.navigationConstraint = .unconstrained
        scene.basemap = Basemap(style: .arcGISImagery)
        return scene
    }()
    
    /// Basemap opacity.
    @State private var opacity: Float = 1
    /// Graphics overlay to show a graphic around your initial location.
    @State private var graphicsOverlay = GraphicsOverlay()
    /// The location datasource that is used to access the device location.
    @State private var locationDatasSource = SystemLocationDataSource()
    
    var body: some View {
        VStack {
            WorldScaleSceneView { proxy in
                SceneView(scene: scene, graphicsOverlays: [graphicsOverlay])
                    .onSingleTapGesture { screen, _ in
                        print("Identifying...")
                        Task.detached {
                            let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
                            print("\(results.count) identify result(s).")
                        }
                    }
            }
            // A slider to adjust the basemap opacity.
            Slider(value: $opacity, in: 0...1.0)
                .padding(.horizontal)
        }
        .onChange(of: opacity) { opacity in
            guard let basemap = scene.basemap else { return }
            for layer in basemap.baseLayers {
                layer.opacity = opacity
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
            
            do {
                try await locationDatasSource.start()
            } catch {
                print("Failed to start location datasource: \(error.localizedDescription)")
            }
            
            // Retrieve initial location
            guard let initialLocation = await locationDatasSource.locations.first(where: { _ in true }) else { return }
            
            // Put a circle graphic around the initial location
            let circle = GeometryEngine.geodeticBuffer(around: initialLocation.position, distance: 20, distanceUnit: .meters, maxDeviation: 1, curveType: .geodesic)
            graphicsOverlay.addGraphic(Graphic(geometry: circle, symbol: SimpleLineSymbol(color: .red, width: 3)))
        }
    }
}
