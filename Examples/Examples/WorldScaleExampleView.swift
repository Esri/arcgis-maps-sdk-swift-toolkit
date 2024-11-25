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

import ArcGIS
import ArcGISToolkit
import CoreLocation
import SwiftUI

/// An example that utilizes the `WorldScaleSceneView` to show an augmented reality view
/// of your current location. Because this is an example that can be run from anywhere,
/// it places a red circle around your initial location which can be explored.
@available(macCatalyst, unavailable)
struct WorldScaleExampleView: View {
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
        scene.baseSurface.opacity = 0
        return scene
    }()
    /// The graphics overlay which shows a graphic around your initial location and marker symbols.
    @State private var graphicsOverlay: GraphicsOverlay = {
        let graphicsOverlay = GraphicsOverlay()
        let markerImage = UIImage(named: "RedMarker")!
        let markerSymbol = PictureMarkerSymbol(image: markerImage)
        markerSymbol.height = 150
        
        graphicsOverlay.renderer = SimpleRenderer(symbol: markerSymbol)
        graphicsOverlay.sceneProperties.surfacePlacement = .absolute
        return graphicsOverlay
    }()
    /// The location datasource that is used to access the device location.
    @State private var locationDataSource = SystemLocationDataSource()
    
    var body: some View {
        WorldScaleSceneView { proxy in
            SceneView(scene: scene, graphicsOverlays: [graphicsOverlay])
                .onSingleTapGesture { screen, _ in
                    print("Identifying...")
                    Task {
                        let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
                        print("\(results.count) identify result(s).")
                    }
                }
        }
        .calibrationButtonAlignment(.bottomLeading)
        .onSingleTapGesture { _, scenePoint in
            graphicsOverlay.addGraphic(Graphic(geometry: scenePoint))
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
            
            try? await locationDataSource.start()
            
            // Retrieve initial location.
            guard let initialLocation = await locationDataSource.locations.first(where: { @Sendable _ in true }) else { return }
            
            // Put a circle graphic around the initial location.
            let circle = GeometryEngine.geodeticBuffer(around: initialLocation.position, distance: 20, distanceUnit: .meters, maxDeviation: 1, curveType: .geodesic)
            graphicsOverlay.addGraphic(Graphic(geometry: circle, symbol: SimpleLineSymbol(color: .red, width: 3)))
            
            // Stop the location data source after the initial location is retrieved.
            await locationDataSource.stop()
        }
    }
}
