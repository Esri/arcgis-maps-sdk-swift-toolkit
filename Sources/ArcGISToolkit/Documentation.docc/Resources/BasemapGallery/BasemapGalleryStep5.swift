import SwiftUI
import ArcGIS
import ArcGISToolkit

struct BasemapGalleryExampleView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    @State private var showBasemapGallery = false
    
    let initialViewpoint = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1_000_000
    )
    
    @State private var basemaps = initialBasemaps()
    
    var body: some View {
        MapView(map: map, viewpoint: initialViewpoint)
            .sheet(isPresented: $showBasemapGallery) {
                VStack(alignment: .trailing) {
                    doneButton
                        .padding()
                    BasemapGallery(items: basemaps, geoModel: map)
                        .style(.grid(maxItemWidth: 100))
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $showBasemapGallery) {
                        Image("basemap", label: Text("Show base map"))
                    }
                }
            }
    }
    
    private var doneButton: some View {
        Button {
            showBasemapGallery.toggle()
        } label: {
            Text("Done")
        }
    }
    
    private static func initialBasemaps() -> [BasemapGalleryItem] {
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
