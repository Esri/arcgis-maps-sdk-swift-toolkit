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
import SwiftUI

/// `BookmarksList` displays a list of selectable bookmarks.
struct BookmarksList: View {
    /// A list of bookmarks for display.
    var bookmarks: [Bookmark]

    /// The minimum height of a bookmark list item.
    ///
    /// This number will be larger when them item's name consumes 2+ lines of text.
    private var minimumRowHeight: Double {
        44
    }

    /// A bookmark that was selected.
    ///
    /// Indicates to the parent that a selection was made.
    @Binding
    var selectedBookmark: Bookmark?

    var body: some View {
        List {
            if bookmarks.isEmpty {
                Label {
                    Text("No bookmarks")
                } icon: {
                    Image(systemName: "bookmark.slash")
                }
                .foregroundColor(.primary)
            } else {
                ForEach(
                    bookmarks.sorted { $0.name <  $1.name },
                    id: \.viewpoint
                ) { bookmark in
                    Button {
                        selectedBookmark = bookmark
                    } label: {
                        Text(bookmark.name)
                    }
                }
            }
        }
        .listStyle(.plain)
        .frame(
            minHeight: minimumRowHeight,
            idealHeight: minimumRowHeight * Double(
                max(1, bookmarks.count)),
            maxHeight: .infinity
        )
    }
}
