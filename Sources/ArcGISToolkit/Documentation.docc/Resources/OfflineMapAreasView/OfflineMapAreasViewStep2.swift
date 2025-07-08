import ArcGIS
import ArcGISToolkit
import SwiftUI

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
    
    var body: some View {
        NavigationStack {
            MapView(map: selectedOfflineMap ?? onlineMap)
        }
    }
}
