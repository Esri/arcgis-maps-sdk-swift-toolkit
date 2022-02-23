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

struct BookmarksList: View {
    /// A list of bookmarks that will be displayed
    var bookmarks: [Bookmark]

    /// Determines if the bookmarks list is currently shown or not.
    @Binding
    var isPresented: Bool

    /// Actions to be performed when a bookmark is selected.
    var selectionChangedActions: ((Bookmark) -> Void)? = nil

    /// If *non-nil*, this viewpoint is updated when a bookmark is pressed.
    var viewpoint: Binding<Viewpoint?>?

    var body: some View {
        List {
            ForEach(bookmarks, id: \.viewpoint) { bookmark in
                Button {
                    isPresented = false
                    if let viewpoint = viewpoint {
                        viewpoint.wrappedValue = bookmark.viewpoint
                    } else if let actions = selectionChangedActions {
                        actions(bookmark)
                    } else {
                        fatalError("No viewpoint or action provided")
                    }
                } label: {
                    Text(bookmark.name)
                }
            }
        }
    }
}
