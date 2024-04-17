// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import SwiftUI

struct BookmarksExampleView: View {
    /// Indicates whether the `Bookmarks` component is presented or not.
    @State private var bookmarksIsPresented = false
    
    /// The `Map` with predefined bookmarks.
    @State private var map = Map(url: URL(string: "https://www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
    
    /// The selected bookmark.
    @State private var selectedBookmark: Bookmark?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            bookmarksIsPresented = true
                        } label: {
                            Label(
                                "Show Bookmarks",
                                systemImage: "bookmark"
                            )
                        }
                        .popover(isPresented: $bookmarksIsPresented) {
                            Bookmarks(
                                isPresented: $bookmarksIsPresented,
                                geoModel: map,
                                selection: $selectedBookmark,
                                geoViewProxy: mapViewProxy
                            )
                        }
                    }
                }
        }
    }
}
