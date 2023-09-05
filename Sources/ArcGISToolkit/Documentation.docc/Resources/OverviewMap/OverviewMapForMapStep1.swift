***REMOVED***
***REMOVED***
***REMOVED***Toolkit

struct OverviewMapForMapView: View {
***REMOVED***@StateObject private var dataModel = MapDataModel(
***REMOVED******REMOVED***map: Map(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: dataModel.map)
***REMOVED***
***REMOVED***
