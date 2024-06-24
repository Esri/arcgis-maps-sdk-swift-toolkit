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
    
    /// The location datasource that is used to access the device location.
    @State private var locationDataSource = SystemLocationDataSource()
    
    var body: some View {
        WorldScaleSceneView(
            clippingDistance: 400
        ) { _ in
            SceneView(scene: scene)
        }
        .task {
            let locationManager = CLLocationManager()
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            try? await locationDataSource.start()
            
            // Retrieve initial location.
            guard let initialLocation = await locationDataSource.locations.first(where: { _ in true }) else { return }
        }
    }
}
