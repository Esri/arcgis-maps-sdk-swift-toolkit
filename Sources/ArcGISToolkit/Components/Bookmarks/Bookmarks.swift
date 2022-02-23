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

/// `Bookmarks` allows for a user to view and select from a set of bookmarks.
public struct Bookmarks: View {
    /// A list that displays bookmarks.
    private var bookmarksList: BookmarksList

    /// Determines if the bookmarks list is currently shown or not.
    @Binding
    var isPresented: Bool

    /// User defined actions to be performed when a bookmark is selected.
    var selectionChangedActions: ((Bookmark) -> Void)? = nil {
        didSet {
            bookmarksList.selectionChangedActions = selectionChangedActions
        }
    }

    /// Creates a `Bookmarks` component.
    /// - precondition: `bookmarks` or `map` is non-nil.
    public init(
        isPresented: Binding<Bool>,
        bookmarks: [Bookmark]? = nil,
        map: Map? = nil,
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        precondition((bookmarks != nil) || (map != nil))
        bookmarksList = BookmarksList(
            bookmarks: bookmarks,
            isPresented: isPresented,
            map: map,
            selectionChangedActions: selectionChangedActions,
            viewpoint: viewpoint
        )
        _isPresented = isPresented
    }

    /// Sets a closure to perform when the viewpoint of the map view changes.
    /// - Parameters:
    ///   - kind: The kind of viewpoint passed to the `action` closure.
    ///   - action: The closure to perform when the viewpoint has changed.
    public func onSelectionChanged(
        perform action: @escaping (Bookmark) -> Void
    ) -> Bookmarks {
        var copy = self
        copy.selectionChangedActions = action
        return copy
    }

    public var body: some View {
        EmptyView()
            .sheet(isPresented: $isPresented) {
                BookmarksHeader(isPresented: $isPresented)
                Divider()
                bookmarksList
            }
    }
}
