import SwiftUI
import ArcGIS
import ArcGISToolkit

struct FlyoverExampleView: View {
    @State private var scene = Scene(
        item: PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: PortalItem.ID("7558ee942b2547019f66885c44d4f0b1")!
        )
    )
    
    var body: some View {
        FlyoverSceneView(
            initialLocation: Point(
                x: 4.4777,
                y: 51.9244,
                z: 1_000,
                spatialReference: .wgs84
            ),
            translationFactor: 1_000
        ) { _ in
            SceneView(scene: scene)
        }
    }
}
