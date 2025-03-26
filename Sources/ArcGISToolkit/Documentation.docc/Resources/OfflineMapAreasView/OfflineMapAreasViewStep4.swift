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
***REMOVED******REMOVED***/ The selected map.
***REMOVED***@State private var selectedOfflineMap: Map?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the offline map areas view should be presented.
***REMOVED***@State private var isShowingOfflineMapAreasView = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***MapView(map: selectedOfflineMap ?? onlineMap)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .topBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Menu("Menu") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Go Online") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedOfflineMap = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(selectedOfflineMap == nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Offline Maps") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowingOfflineMapAreasView = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isShowingOfflineMapAreasView) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OfflineMapAreasView(onlineMap: onlineMap, selection: $selectedOfflineMap)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
