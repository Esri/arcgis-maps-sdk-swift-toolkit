***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct CompassExampleView: View {
***REMOVED***@State private var map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Compass(rotation: viewpoint?.rotation, mapViewProxy: proxy)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
