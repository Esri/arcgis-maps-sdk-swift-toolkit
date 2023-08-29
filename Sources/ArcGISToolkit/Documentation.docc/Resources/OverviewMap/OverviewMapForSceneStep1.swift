import SwiftUI
import ArcGIS
import ArcGISToolkit

struct OverviewMapForSceneView: View {
    @StateObject private var dataModel = SceneDataModel(
        scene: Scene(basemapStyle: .arcGISImagery)
    )
    
    var body: some View {
        SceneView(scene: dataModel.scene)
    }
}
