***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct OfflineMapAreasExampleView: View {
***REMOVED******REMOVED***/ The map of the Naperville water network.
***REMOVED***@State private var onlineMap = Map(
***REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
***REMOVED******REMOVED***)
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***MapView(map: onlineMap)
***REMOVED***
***REMOVED***
***REMOVED***
