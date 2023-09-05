***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct ScalebarExampleView: View {
***REMOVED***@State private var spatialReference: SpatialReference?
***REMOVED***
***REMOVED***@State private var unitsPerPoint: Double?
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***private let alignment: Alignment = .bottomLeading
***REMOVED***
***REMOVED***@State private var map = Map(basemapStyle: .arcGISTopographic)
***REMOVED***
***REMOVED***private let maxWidth: Double = 175.0
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.onSpatialReferenceChanged { spatialReference = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onUnitsPerPointChanged { unitsPerPoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED***
***REMOVED***
