// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import SwiftUI

struct BookmarksExampleView: View {
    /// Represents the number of bookmarks added during runtime.
    @State
    private var bookmarksAdded = 0

    /// A web map with predefined bookmarks.
    private let map = Map(url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!

    /// Indicates if the bookmarks list is shown or not.
    /// - Remark: This allows a developer to control how the bookmarks menu is shown/hidden,
    /// whether that be in a group of options or a standalone button.
    @State
    var showingBookmarks = false

    @State
    var viewpoint: Viewpoint? = nil

    var body: some View {
        MapView(map: map, viewpoint: viewpoint)
            .onViewpointChanged(kind: .centerAndScale) {
                viewpoint = $0
            }
            .onSingleTapGesture { _, point in
                let newBookmark = Bookmark(
                    name: "Added bookmark \(bookmarksAdded + 1)",
                    viewpoint: Viewpoint(
                        center: point,
                        scale: viewpoint?.targetScale ?? 10_000
                    )
                )
                map.addBookmark(newBookmark)
                bookmarksAdded += 1
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
                        // Let the bookmarks component control viewpoint changes:
                        Bookmarks(
                            isPresented: $showingBookmarks,
                            mapOrScene: map,
                            viewpoint: $viewpoint
                        )
                        // Or control viewpoint changes yourself:
//                        Bookmarks(
//                            isPresented: $showingBookmarks,
//                            mapOrScene: map
//                        )
//                        .onSelectionChanged {
//                            viewpoint = $0.viewpoint
//                        }
                    }
                }
            }
    }
}
