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

/// `Bookmarks` allows a user to view and select from a set of bookmarks.
public struct Bookmarks: View {
    /// A list of selectable bookmarks.
    @State
    private var bookmarks: [Bookmark] = []

    /// A map or scene containing bookmarks.
    private var geoModel: GeoModel?

    /// Indicates if bookmarks have loaded and are ready for display.
    @State
    var geoModelIsLoaded = false

    /// Determines if the bookmarks list is currently shown or not.
    @Binding
    private var isPresented: Bool

    /// A bookmark that was selected.
    ///
    /// Used to listen for a selection.
    @State
    var selectedBookmark: Bookmark? = nil

    /// User defined action to be performed when a bookmark is selected. Use this when you prefer to
    /// self-manage the response to a bookmark selection. Use either `onSelectionChangedActions`
    /// or `viewpoint` exclusively.
    var selectionChangedActions: ((Bookmark) -> Void)? = nil

    /// If non-`nil`, this viewpoint is updated when a bookmark is pressed.
    var viewpoint: Binding<Viewpoint?>?

    /// Sets a closure to perform when the viewpoint of the `MapView` or `SceneView` changes.
    /// - Parameters:
    ///   - action: The closure to perform when the bookmark selection has changed.
    public func onSelectionChanged(
        perform action: @escaping (Bookmark) -> Void
    ) -> Bookmarks {
        var copy = self
        copy.selectionChangedActions = action
        return copy
    }

    /// Performs the necessary actions when a bookmark is selected.
    ///
    /// This includes indicating that bookmarks should be set to a hidden state, and changing the viewpoint
    /// if the user provided a viewpoint or calling actions if the user implemented the
    /// `selectionChangedActions` modifier.
    /// - Parameter bookmark: The bookmark that was selected.
    func selectBookmark(_ bookmark: Bookmark?) {
        guard bookmark != nil else { return }
        isPresented = false
        if let viewpoint = viewpoint {
            viewpoint.wrappedValue = bookmark!.viewpoint
        } else if let actions = selectionChangedActions {
            actions(bookmark!)
        } else {
            fatalError("No viewpoint or action provided")
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
        self.bookmarks = bookmarks
        self.viewpoint = viewpoint
        _isPresented = isPresented
    }

    /// Creates a `Bookmarks` component.
    /// - precondition: `viewpoint` is non-nil or the `selectionChangedActions` modifier is
    /// implemented.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - mapOrScene: A `GeoModel` authored with pre-existing bookmarks.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected. Use
    ///   either `viewpoint` or `selectionChangedActions` exclusively.
    public init(
        isPresented: Binding<Bool>,
        mapOrScene: GeoModel,
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        geoModel = mapOrScene
        self.viewpoint = viewpoint
        _isPresented = isPresented
    }

    public var body: some View {
        Group {
            BookmarksHeader(isPresented: $isPresented)
            if geoModel == nil || geoModelIsLoaded {
                BookmarksList(
                    bookmarks: bookmarks,
                    selectedBookmark: $selectedBookmark.onChange {
                        selectBookmark($0)
                    }
                )
            } else {
                loading
            }
        }
    }

    /// A view that is shown while a `GeoModel` is loading.
    private var loading: some View {
        VStack {
            Spacer()
            HStack {
                ProgressView()
                    .padding([.trailing], 5)
                Text("Loading")
            }.task {
                do {
                    try await geoModel?.load()
                    geoModelIsLoaded = true
                    bookmarks = geoModel?.bookmarks ?? []
                } catch {
                    print(error.localizedDescription)
                }
            }
            Spacer()
        }
        .padding()
    }
}
