import ArcGIS
import ArcGISToolkit
import CoreLocation
import SwiftUI

struct WorldScaleExampleView: View {
    @State private var scene: ArcGIS.Scene = {
        // Creates an elevation source from Terrain3D REST service.
        let elevationServiceURL = URL(
            string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
        )!
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
    
    /// The graphics overlay which shows a graphic around your initial location.
    @State private var graphicsOverlay = GraphicsOverlay()
    
    /// The world-tracking provider used by this example.
    @State private var provider = AppleWorldTracking(mode: .worldTracking)
    
    var body: some View {
        WorldScaleSceneView(provider: provider) { context in
            AppleWorldTrackingCameraFeedView(context: context)
        } sceneView: { _ in
            SceneView(scene: scene)
        }
        .task {
            let locationManager = CLLocationManager()
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            try? await provider.dataSource.start()
            
            // Retrieve initial location.
            guard let initialLocation = await provider.dataSource.locations.first(where: { @Sendable _ in true }) else { return }
            
            // Put a circle graphic around the initial location.
            let circle = GeometryEngine.geodeticBuffer(
                around: initialLocation.position,
                distance: 20,
                distanceUnit: .meters,
                maxDeviation: 1,
                curveType: .geodesic
            )
            graphicsOverlay.addGraphic(
                Graphic(
                    geometry: circle,
                    symbol: SimpleLineSymbol(
                        color: .red,
                        width: 3
                    )
                )
            )
        }
    }
}
