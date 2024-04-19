import SwiftUI
import ArcGIS
import ArcGISToolkit

struct OverviewMapForSceneView: View {
    @State private var scene = Scene(basemapStyle: .arcGISImagery)
    
    var body: some View {
        SceneView(scene: scene)
    }
}
