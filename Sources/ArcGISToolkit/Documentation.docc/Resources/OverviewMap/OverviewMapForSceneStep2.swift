import SwiftUI
import ArcGIS
import ArcGISToolkit

struct OverviewMapForSceneView: View {
    @StateObject private var dataModel = SceneDataModel(
        scene: Scene(basemapStyle: .arcGISImagery)
    )
    
    @State private var viewpoint: Viewpoint?
    
    var body: some View {
        SceneView(scene: dataModel.scene)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
    }
}
