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

/// The bookmarks component allows for a user to select and navigate to defined set of "bookmarked"
/// locations.
public struct Bookmarks: View {
    private var bookmarks: [Bookmark]

    /// Determines if the bookmarks list is currently shown or not.
    @Binding
    private var isPresented: Bool

    private var viewpoint: Binding<Viewpoint?>?

    /// Creates a `Bookmarks` component.
    public init(
        _ bookmarks: [Bookmark],
        isPresented: Binding<Bool>,
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        self.bookmarks = bookmarks
        self.viewpoint = viewpoint
        _isPresented = isPresented
    }

    /// Actions to be performed when a bookmark is selected.
    var selectionChangedActions: ((Bookmark) -> Void)? = nil

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
        if isPresented {
            FloatingPanel {
                ForEach(bookmarks, id: \.viewpoint) { bookmark in
                    Button {
                        isPresented = false
                        if let viewpoint = viewpoint {
                            viewpoint.wrappedValue = bookmark.viewpoint
                        } else {
                            selectionChangedActions?(bookmark)
                        }
                    } label: {
                        Text(bookmark.name)
                    }
                }
            }
        }
    }
}
