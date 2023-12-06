import SwiftUI
import ArcGIS
import ArcGISToolkit

struct FlyoverExampleView: View {
    var body: some View {
        FlyoverSceneView(
            initialLatitude: 45.54605,
            initialLongitude: -122.69033,
            initialAltitude: 500,
            translationFactor: 1_000
        )
    }
}
