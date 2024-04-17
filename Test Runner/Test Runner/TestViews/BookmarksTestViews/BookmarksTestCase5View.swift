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

/// A view that displays the Bookmarks component initialized with bookmarks.
struct BookmarksTestCase5View: View {
    @State private var bookmarks = [Bookmark(name: "Bookmark 1")]
    
    /// The `Map` with no predefined bookmarks.
    @State private var map = Map(basemapStyle: .arcGISCommunity)
    
    var body: some View {
        MapView(map: map)
            .sheet(isPresented: .constant(true)) {
                Bookmarks(
                    isPresented: .constant(true),
                    bookmarks: bookmarks,
                    selection: .constant(nil)
                )
                Button("Add New") {
                    bookmarks.append(Bookmark(name: "Bookmark \(bookmarks.count + 1)"))
                }
            }
    }
}
