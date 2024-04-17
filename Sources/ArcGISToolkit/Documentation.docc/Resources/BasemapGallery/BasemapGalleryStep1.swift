***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct BasemapGalleryExampleView: View {
***REMOVED***@State private var map: Map = {
***REMOVED******REMOVED***let map = Map(basemapStyle: .arcGISImagery)
***REMOVED******REMOVED***map.initialViewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED******REMOVED***scale: 1_000_000
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return map
***REMOVED***()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED***
***REMOVED***
