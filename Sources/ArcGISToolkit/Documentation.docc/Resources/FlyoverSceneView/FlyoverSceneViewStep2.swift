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
            initialLatitude: 45.54605,
            initialLongitude: -122.69033,
            initialAltitude: 500,
            translationFactor: 1_000
        ) { _ in
            SceneView(scene: scene)
        }
    }
}
