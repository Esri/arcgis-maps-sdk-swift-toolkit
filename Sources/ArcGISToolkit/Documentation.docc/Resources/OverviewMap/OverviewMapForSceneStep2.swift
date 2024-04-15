import SwiftUI
import ArcGIS
import ArcGISToolkit

struct OverviewMapForSceneView: View {
    @State private var scene = Scene(basemapStyle: .arcGISImagery)
    
    @State private var viewpoint: Viewpoint?
    
    var body: some View {
        SceneView(scene: scene)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
    }
}
