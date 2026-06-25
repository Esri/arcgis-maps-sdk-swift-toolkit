import ArcGIS
import ArcGISToolkit
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
        return scene
    }()
    
    /// The world-tracking provider used by this example.
    @State private var provider = AppleWorldTracking(mode: .worldTracking)
    
    var body: some View {
        WorldScaleSceneView(provider: provider) { context in
            AppleWorldTrackingCameraFeedView(context: context)
        } sceneView: { _ in
            SceneView(scene: scene)
        }
    }
}
