***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct OverviewMapForMapView: View {
***REMOVED***@StateObject private var dataModel = MapDataModel(
***REMOVED******REMOVED***map: Map(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***@State private var visibleArea: ArcGIS.Polygon?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: dataModel.map)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { visibleArea = $0 ***REMOVED***
***REMOVED***
***REMOVED***
