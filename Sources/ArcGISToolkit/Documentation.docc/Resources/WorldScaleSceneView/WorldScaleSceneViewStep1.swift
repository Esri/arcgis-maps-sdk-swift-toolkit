import SwiftUI
import ArcGIS
import ArcGISToolkit

struct WorldScaleExampleView: View {
    var body: some View {
        WorldScaleSceneView(
            clippingDistance: 400
        )
    }
}
