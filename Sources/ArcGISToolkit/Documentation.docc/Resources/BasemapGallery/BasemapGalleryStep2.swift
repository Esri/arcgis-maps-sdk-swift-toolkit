import ArcGIS
import ArcGISToolkit
import SwiftUI

struct BasemapGalleryExampleView: View {
    @State private var basemaps = makeBasemapGalleryItems()
    
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
    
    private static func makeBasemapGalleryItems() -> [BasemapGalleryItem] {
        let identifiers = [
            "46a87c20f09e4fc48fa3c38081e0cae6",
            "f33a34de3a294590ab48f246e99958c9"
        ]
        
        return identifiers.map { identifier in
            let url = URL(string: "https://www.arcgis.com/home/item.html?id=\(identifier)")!
            return BasemapGalleryItem(basemap: Basemap(item: PortalItem(url: url)!))
        }
    }
}
