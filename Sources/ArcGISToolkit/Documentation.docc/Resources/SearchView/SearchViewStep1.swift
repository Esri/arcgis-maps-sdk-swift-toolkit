import SwiftUI
import ArcGIS
import ArcGISToolkit

struct SearchExampleView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    @State private var searchResultViewpoint: Viewpoint? = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1000000
    )
}
