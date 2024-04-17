// Copyright 2023 Esri
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

/// A view that displays the Bookmarks component initialized with a GeoModel containing bookmarks.
struct BookmarksTestCase1View: View {
    /// The `Map` with predefined bookmarks.
    @State private var map = Map(url: URL(string: "https://www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
    
    /// The last selected bookmark.
    @State private var selection: Bookmark?
    
    /// Indicates if the `Bookmarks` component is shown or not.
    /// - Remark: This allows a developer to control when the `Bookmarks` component is
    /// shown/hidden, whether that be in a group of options or a standalone button.
    @State private var showingBookmarks = false
    
    var body: some View {
        MapView(map: map, viewpoint: selection?.viewpoint)
            .sheet(isPresented: $showingBookmarks) {
                Bookmarks(
                    isPresented: $showingBookmarks,
                    geoModel: map,
                    selection: $selection
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bookmarks") {
                        showingBookmarks.toggle()
                    }
                }
                
                if let selection {
                    ToolbarItem(placement: .bottomBar) {
                        Text(selection.name)
                    }
                }
            }
    }
}
