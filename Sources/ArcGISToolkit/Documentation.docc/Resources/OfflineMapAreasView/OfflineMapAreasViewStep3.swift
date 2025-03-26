import ArcGIS
import ArcGISToolkit
import SwiftUI

@MainActor
struct OfflineMapAreasExampleView: View {
    /// The map of the Naperville water network.
    @State private var onlineMap = Map(
        item: PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
        )
    )
    
    /// The selected map.
    @State private var selectedOfflineMap: Map?
    
    /// A Boolean value indicating whether the offline map areas view should be presented.
    @State private var isShowingOfflineMapAreasView = false
    
    var body: some View {
        NavigationStack {
            MapView(map: selectedOfflineMap ?? onlineMap)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("Menu") {
                            Button("Go Online") {
                                selectedOfflineMap = nil
                            }
                            .disabled(selectedOfflineMap == nil)
                            Button("Offline Maps") {
                                isShowingOfflineMapAreasView = true
                            }
                        }
                    }
                }
        }
    }
}
