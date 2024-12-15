***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct LocationButtonExampleView: View {
***REMOVED***@State private var map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State private var locationDisplay = {
***REMOVED******REMOVED***let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
***REMOVED******REMOVED***locationDisplay.autoPanMode = .recenter
***REMOVED******REMOVED***locationDisplay.initialZoomScale = 40_000
***REMOVED******REMOVED***return locationDisplay
***REMOVED***()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.locationDisplay(locationDisplay)
***REMOVED***
***REMOVED***
