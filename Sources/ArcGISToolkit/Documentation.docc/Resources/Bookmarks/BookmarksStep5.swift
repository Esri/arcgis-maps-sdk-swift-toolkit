import ArcGIS
import ArcGISToolkit
import SwiftUI

struct BookmarksExampleView: View {
    @State private var map = Map(url: URL(string: "https://www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
    
    @State var selectedBookmark: Bookmark?
    
    @State var showingBookmarks = false
    
    @State var viewpoint: Viewpoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map, viewpoint: viewpoint)
                .onViewpointChanged(kind: .centerAndScale) {
                    viewpoint = $0
                }
                .task(id: selectedBookmark) {
                    if let selectedBookmark, let viewpoint = selectedBookmark.viewpoint {
                        await mapViewProxy.setViewpoint(viewpoint)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingBookmarks.toggle()
                        } label: {
                            Label(
                                "Show Bookmarks",
                                systemImage: "bookmark"
                            )
                        }
                        .popover(isPresented: $showingBookmarks) {
                            Bookmarks(
                                isPresented: $showingBookmarks,
                                geoModel: map
                            )
                            .onSelectionChanged { selectedBookmark = $0 }
                        }
                    }
                }
        }
    }
}
