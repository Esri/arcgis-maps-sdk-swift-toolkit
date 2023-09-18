import ArcGIS
import ArcGISToolkit
import SwiftUI

struct CompassExampleView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    @State private var viewpoint: Viewpoint?
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: map)
                .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
                .overlay(alignment: .topTrailing) {
                    Compass(rotation: viewpoint?.rotation, mapViewProxy: proxy)
                }
        }
    }
}
