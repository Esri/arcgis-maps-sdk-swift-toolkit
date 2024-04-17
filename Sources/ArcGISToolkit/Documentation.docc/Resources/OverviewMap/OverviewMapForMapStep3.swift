import SwiftUI
import ArcGIS
import ArcGISToolkit

struct OverviewMapForMapView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    @State private var viewpoint: Viewpoint?
    
    @State private var visibleArea: ArcGIS.Polygon?
    
    var body: some View {
        MapView(map: map)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .onVisibleAreaChanged { visibleArea = $0 }
            .overlay(alignment: .topTrailing) {
                OverviewMap.forMapView(
                    with: viewpoint,
                    visibleArea: visibleArea
                )
                .frame(width: 200, height: 132)
                .padding()
            }
    }
}
