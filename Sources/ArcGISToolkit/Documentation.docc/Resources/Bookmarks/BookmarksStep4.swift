***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct BookmarksExampleView: View {
***REMOVED***@State private var bookmarksIsPresented = false
***REMOVED***
***REMOVED***@State private var map = Map(url: URL(string: "https:***REMOVED***www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
***REMOVED***
***REMOVED***@State private var selection: Bookmark?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.popover(isPresented: $bookmarksIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Bookmarks(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $bookmarksIsPresented,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoModel: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: $selection,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoViewProxy: mapViewProxy
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .primaryAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bookmarksIsPresented.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Show Bookmarks",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemImage: "bookmark"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
