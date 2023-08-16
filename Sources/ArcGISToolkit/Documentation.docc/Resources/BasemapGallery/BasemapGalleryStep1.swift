import SwiftUI
import ArcGIS
import ArcGISToolkit

struct BasemapGalleryExampleView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    let initialViewpoint = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1_000_000
    )
    
    var body: some View {
        MapView(map: map, viewpoint: initialViewpoint)
    }
}
