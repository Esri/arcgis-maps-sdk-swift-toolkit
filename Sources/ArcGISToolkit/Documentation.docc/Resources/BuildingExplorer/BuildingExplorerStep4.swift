import ArcGIS
import ArcGISToolkit
import SwiftUI

struct BuildingExplorerExampleView: View {
    @State private var scene = Scene(url: URL(string: "https://www.arcgis.com/home/item.html?id=b7c387d599a84a50aafaece5ca139d44")!)!
    
    @State private var explorerIsVisible = false
    
    @State private var items: [BuildingExplorerItem] = []
    
    @State private var selection: BuildingExplorerItem?
    
    var body: some View {
        NavigationStack {
            LocalSceneViewReader { proxy in
                LocalSceneView(scene: scene)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Building Explorer", systemImage: "building") {
                                explorerIsVisible = true
                            }
                            .popover(isPresented: $explorerIsVisible) {
                                BuildingExplorer(
                                    scene: scene,
                                    items: $items,
                                    selection: $selection,
                                    localSceneViewProxy: proxy
                                )
                                .frame(idealWidth: 400, idealHeight: 500)
                                .presentationCompactAdaptation(.popover)
                            }
                        }
                    }
            }
        }
    }
}
