import SwiftUI
import ArcGIS
import ArcGISToolkit

struct OverviewMapForMapView: View {
    @StateObject private var dataModel = MapDataModel(
        map: Map(basemapStyle: .arcGISImagery)
    )
    
    var body: some View {
        MapView(map: dataModel.map)
    }
}
