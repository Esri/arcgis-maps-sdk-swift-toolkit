import ArcGIS
import ArcGISToolkit
import SwiftUI

struct BasemapGalleryExampleView: View {
    @State private var map: Map = {
        let map = Map(basemapStyle: .arcGISImagery)
        map.initialViewpoint = Viewpoint(
            center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
            scale: 1_000_000
        )
        return map
    }()
    
    var body: some View {
        MapView(map: map)
    }
}
