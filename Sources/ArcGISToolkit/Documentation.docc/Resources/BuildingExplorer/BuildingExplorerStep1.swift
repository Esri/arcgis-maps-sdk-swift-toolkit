import ArcGIS
import SwiftUI

struct BuildingExplorerExampleView: View {
    @State private var scene = Scene(url: URL(string: "https://www.arcgis.com/home/item.html?id=b7c387d599a84a50aafaece5ca139d44")!)!
        
    var body: some View {
        LocalSceneViewReader { proxy in
            LocalSceneView(scene: scene)
        }
    }
}
