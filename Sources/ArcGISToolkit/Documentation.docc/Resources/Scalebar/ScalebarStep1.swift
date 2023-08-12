import ArcGIS
import ArcGISToolkit
import SwiftUI

struct ScalebarExampleView: View {
    @State private var map = Map(basemapStyle: .arcGISTopographic)
    
    var body: some View {
        MapView(map: map)
    }
}
