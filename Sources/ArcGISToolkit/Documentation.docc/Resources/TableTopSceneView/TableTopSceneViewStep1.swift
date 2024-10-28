import SwiftUI
import ArcGIS
import ArcGISToolkit

struct TableTopExampleView: View {
    private let anchorPoint = Point(
        x: -122.68350326165559,
        y: 45.53257485106716,
        spatialReference: .wgs84
    )
    
    var body: some View {
        TableTopSceneView(
            anchorPoint: anchorPoint,
            translationFactor: 400,
            clippingDistance: 400
        )
    }
}
