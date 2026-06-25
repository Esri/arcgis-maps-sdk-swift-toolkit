import ArcGIS
import ArcGISToolkit
import SwiftUI

struct WorldScaleExampleView: View {
    /// The world-tracking provider used by this example.
    @State private var provider = AppleWorldTracking(mode: .worldTracking)
    
    var body: some View {
        WorldScaleSceneView(provider: provider) { context in

        } sceneView: { _ in

        }
    }
}
