import ArcGIS
import ArcGISToolkit
import SwiftUI

struct CompassExampleView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: map)
        }
    }
}
