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
    /// A list of selectable bookmarks.
    var bookmarks: [Bookmark]?

    /// A list of bookmarks derived either directly from `bookmarks` or from `map`.
    private var definedBookmarks: [Bookmark] {
        var result: [Bookmark] = []
        if let bookmarks = bookmarks {
            result = bookmarks
        } else if let map = map {
            result = map.bookmarks
        } else {
            return []
        }
        return result.sorted { $0.name < $1.name }
    }

    /// Determines if the list is currently shown or not.
    @Binding
    var isPresented: Bool

    /// A map containing bookmarks.
    var map: Map?

    /// Indicates if bookmarks have loaded and are ready for display.
    @State
    var mapIsLoaded = false

    /// User defined action to be performed when a bookmark is selected.
    var selectionChangedActions: ((Bookmark) -> Void)? = nil

    /// If non-`nil`, this viewpoint is updated when a bookmark is pressed.
    var viewpoint: Binding<Viewpoint?>?

    /// Performs the necessary actions when a bookmark is selected.
    ///
    /// This includes indicating that bookmarks should be set to a hidden state, and changing the viewpoint
    /// if the user provided a viewpoint or calling actions if the user implemented the
    /// `selectionChangedActions` modifier.
    /// - Parameter bookmark: The bookmark that was selected.
    func selectBookmark(_ bookmark: Bookmark) {
        isPresented = false
        if let viewpoint = viewpoint {
            viewpoint.wrappedValue = bookmark.viewpoint
        } else if let actions = selectionChangedActions {
            actions(bookmark)
        } else {
            fatalError("No viewpoint or action provided")
        }
    }

    var body: some View {
        if map == nil {
            bookmarkList
        } else {
            if mapIsLoaded {
                bookmarkList
            } else {
                loading
            }
        }
    }
}

private extension BookmarksList {
    /// The minimum height of a bookmark list item.
    ///
    /// This number will be larger when them item's name consumes 2+ lines of text.
    private var minimumRowHeight: Double {
        44
    }

    /// A list that is shown once bookmarks have loaded.
    private var bookmarkList: some View {
        List {
            if definedBookmarks.isEmpty {
                Label {
                    Text("No bookmarks")
                } icon: {
                    Image(systemName: "bookmark.slash")
                }
                .foregroundColor(.primary)
            } else {
                ForEach(definedBookmarks, id: \.viewpoint) { bookmark in
                    Button {
                        selectBookmark(bookmark)
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
                max(1, definedBookmarks.count)),
            maxHeight: .infinity
        )
    }

    /// A view that is shown while a web map is loading.
    private var loading: some View {
        VStack {
            Spacer()
            HStack {
                ProgressView()
                    .padding([.trailing], 5)
                Text("Loading")
            }.task {
                do {
                    try await map?.load()
                    print(map?.bookmarks.count)
                    mapIsLoaded = true
                } catch {
                    print(error.localizedDescription)
                }
            }
            Spacer()
        }
        .padding()
    }
}
