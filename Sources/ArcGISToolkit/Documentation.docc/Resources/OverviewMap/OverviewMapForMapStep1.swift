import SwiftUI
import ArcGIS
import ArcGISToolkit

struct OverviewMapForMapView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    var body: some View {
        MapView(map: map)
    }
}
