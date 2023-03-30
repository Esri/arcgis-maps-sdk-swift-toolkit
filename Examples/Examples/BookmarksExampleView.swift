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
    /// The `Map` with predefined bookmarks.
    @State private var map = Map(url: URL(string: "https://www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
    
    /// Indicates if the `Bookmarks` component is shown or not.
    /// - Remark: This allows a developer to control when the `Bookmarks` component is
    /// shown/hidden, whether that be in a group of options or a standalone button.
    @State var showingBookmarks = false
    
    /// Allows for communication between the `Bookmarks` component and a `MapView` or
    /// `SceneView`.
    @State var viewpoint: Viewpoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map, viewpoint: viewpoint)
                .onViewpointChanged(kind: .centerAndScale) {
                    viewpoint = $0
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
                            // Display the `Bookmarks` component with the list of
                            // bookmarks in a map.
                            Bookmarks(
                                isPresented: $showingBookmarks,
                                mapOrScene: map
                            )
                            // In order to handle bookmark selection changes
                            // manually, use `onSelectionChanged(perform:)`.
                            .onSelectionChanged { bookmark in
                                if let viewpoint = bookmark.viewpoint {
                                    Task { await mapViewProxy.setViewpoint(viewpoint, duration: 1) }
                                }
                            }
                        }
                    }
                }
        }
    }
}
