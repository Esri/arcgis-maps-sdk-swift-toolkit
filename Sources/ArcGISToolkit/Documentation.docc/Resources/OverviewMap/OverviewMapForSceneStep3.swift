import SwiftUI
import ArcGIS
import ArcGISToolkit

struct OverviewMapForSceneView: View {
    @State private var scene = Scene(basemapStyle: .arcGISImagery)
    
    @State private var viewpoint: Viewpoint?
    
    var body: some View {
        SceneView(scene: scene)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .overlay(alignment: .topTrailing) {
                OverviewMap.forSceneView(
                    with: viewpoint
                )
                .frame(width: 200, height: 132)
                .padding()
            }
    }
}
