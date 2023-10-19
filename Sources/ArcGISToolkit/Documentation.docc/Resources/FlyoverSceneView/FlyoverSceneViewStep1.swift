import SwiftUI
import ArcGIS
import ArcGISToolkit

struct FlyoverExampleView: View {
    var body: some View {
        FlyoverSceneView(
            initialLocation: Point(
                x: 4.4777,
                y: 51.9244,
                z: 1_000,
                spatialReference: .wgs84
            ),
            translationFactor: 1_000
        )
    }
}
