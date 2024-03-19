***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct BasemapGalleryExampleView: View {
***REMOVED***@State private var map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State private var showBasemapGallery = false
***REMOVED***
***REMOVED***let initialViewpoint = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1_000_000
***REMOVED***)
***REMOVED***
***REMOVED***@State private var basemaps = makeBasemapGalleryItems()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map, viewpoint: initialViewpoint)
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $showBasemapGallery) {
***REMOVED******REMOVED******REMOVED******REMOVED***BasemapGallery(items: basemaps, geoModel: map)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.style(.grid(maxItemWidth: 100))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private static func makeBasemapGalleryItems() -> [BasemapGalleryItem] {
***REMOVED******REMOVED***let identifiers = [
***REMOVED******REMOVED******REMOVED***"46a87c20f09e4fc48fa3c38081e0cae6",
***REMOVED******REMOVED******REMOVED***"f33a34de3a294590ab48f246e99958c9"
***REMOVED******REMOVED***]
***REMOVED******REMOVED***
***REMOVED******REMOVED***return identifiers.map { identifier in
***REMOVED******REMOVED******REMOVED***let url = URL(string: "https:***REMOVED***www.arcgis.com/home/item.html?id=\(identifier)")!
***REMOVED******REMOVED******REMOVED***return BasemapGalleryItem(basemap: Basemap(item: PortalItem(url: url)!))
***REMOVED***
***REMOVED***
***REMOVED***
