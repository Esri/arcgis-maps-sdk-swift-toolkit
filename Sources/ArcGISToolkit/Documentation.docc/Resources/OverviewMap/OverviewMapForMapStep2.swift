import SwiftUI
import ArcGIS
import ArcGISToolkit

struct OverviewMapForMapView: View {
    @StateObject private var dataModel = MapDataModel(
        map: Map(basemapStyle: .arcGISImagery)
    )
    
    @State private var viewpoint: Viewpoint?
    
    @State private var visibleArea: ArcGIS.Polygon?
    
    var body: some View {
        MapView(map: dataModel.map)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .onVisibleAreaChanged { visibleArea = $0 }
    }
}
