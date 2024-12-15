import ArcGIS
import ArcGISToolkit
import SwiftUI

struct LocationButtonExampleView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    var body: some View {
        MapView(map: map)
    }
}
