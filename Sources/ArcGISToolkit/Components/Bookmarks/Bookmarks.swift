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
    private var isPresented: Bool

    /// User defined action to be performed when a bookmark is selected. Use this when you prefer to
    /// self-manage the response to a bookmark selection. Use either `onSelectionChangedActions`
    /// or `viewpoint` exclusively.
    var selectionChangedActions: ((Bookmark) -> Void)? = nil {
        didSet {
            bookmarksList.selectionChangedActions = selectionChangedActions
        }
    }

    /// Creates a `Bookmarks` component.
    /// - precondition: `viewpoint` is non-nil or the `selectionChangedActions` modifier is
    /// implemented.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - bookmarks: A list of bookmarks. Use this when displaying bookmarks defined at run-time.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected. Use
    ///   either `viewpoint` or `selectionChangedActions` exclusively.
    public init(
        isPresented: Binding<Bool>,
        bookmarks: [Bookmark],
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        bookmarksList = BookmarksList(
            bookmarks: bookmarks,
            isPresented: isPresented,
            viewpoint: viewpoint
        )
        _isPresented = isPresented
    }

    /// Creates a `Bookmarks` component.
    /// - precondition: `viewpoint` is non-nil or the `selectionChangedActions` modifier is
    /// implemented.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - map: A web map authored with pre-existing bookmarks.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected. Use
    ///   either `viewpoint` or `selectionChangedActions` exclusively.
    public init(
        isPresented: Binding<Bool>,
        map: Map,
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        bookmarksList = BookmarksList(
            isPresented: isPresented,
            map: map,
            viewpoint: viewpoint
        )
        _isPresented = isPresented
    }

    public var body: some View {
        Group {
            BookmarksHeader(isPresented: $isPresented)
            Divider()
            bookmarksList
        }
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
}
