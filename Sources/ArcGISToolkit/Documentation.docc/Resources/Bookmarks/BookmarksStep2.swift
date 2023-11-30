import ArcGIS
import ArcGISToolkit
import SwiftUI

struct BookmarksExampleView: View {
    /// The `Map` with predefined bookmarks.
    @State private var map = Map(url: URL(string: "https://www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
    
    /// Indicates if the `Bookmarks` component is shown or not.
    /// - Remark: This allows a developer to control when the `Bookmarks` component is
    /// shown/hidden, whether that be in a group of options or a standalone button.
    @State var showingBookmarks = false
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
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
                    }
                }
        }
    }
}
