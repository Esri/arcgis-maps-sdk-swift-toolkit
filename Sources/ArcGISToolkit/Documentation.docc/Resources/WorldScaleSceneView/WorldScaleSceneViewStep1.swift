import ArcGIS
import ArcGISToolkit
import SwiftUI

struct WorldScaleExampleView: View {
    var body: some View {
        WorldScaleSceneView(
            clippingDistance: 400
        )
    }
}
