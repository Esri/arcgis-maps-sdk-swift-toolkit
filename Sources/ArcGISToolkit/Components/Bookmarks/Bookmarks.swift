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

/// The `Bookmarks` component will display a list of bookmarks and allow the user to select a
/// bookmark and perform some action. You can create the component with either an array of
/// `Bookmark` values, or with a `Map` or `Scene` containing the bookmarks to display.
///
/// `Bookmarks` can be configured to handle automated bookmark selection (zooming the map/scene to
/// the bookmark’s viewpoint) by passing in a `Viewpoint` binding or the client can handle bookmark
/// selection changes manually using ``onSelectionChanged(perform:)``.
///
/// | iPhone | iPad |
/// | ------ | ---- |
/// | ![image](https://user-images.githubusercontent.com/3998072/202765630-894bee44-a0c2-4435-86f4-c80c4cc4a0b9.png) | ![image](https://user-images.githubusercontent.com/3998072/202765729-91c52555-4677-4c2b-b62b-215e6c3790a6.png) |
///
/// **Features**
///
/// - Can be configured to display bookmarks from a map or scene, or from an array of user-defined
/// bookmarks.
/// - Can be configured to automatically zoom the map or scene to a bookmark selection.
/// - Can be configured to perform a user-defined action when a bookmark is selected.
/// - Will automatically hide when a bookmark is selected.
///
/// **Behavior**
/// 
/// If a `Viewpoint` binding is provided to the `Bookmarks` view, selecting a bookmark will set that
/// viewpoint binding to the viewpoint of the bookmark. Selecting a bookmark will dismiss the
/// `Bookmarks` view. If a `GeoModel` is provided, that geo model's bookmarks will be displayed to
/// the user.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [BookmarksExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/BookmarksExampleView.swift)
/// in the project. To learn more about using the `Bookmarks` component see the [Bookmarks Tutorial](https://developers.arcgis.com/swift/toolkit-api-reference/tutorials/arcgistoolkit/bookmarkstutorial).
public struct Bookmarks: View {
    /// A list of selectable bookmarks.
    @State private var bookmarks: [Bookmark]
    
    /// An error that occurred while loading the geo model.
    @State private var loadingError: Error?
    
    /// Determines if the bookmarks list is currently shown or not.
    @Binding private var isPresented: Bool
    
    /// The selected bookmark.
    @State private var selectedBookmark: Bookmark? = nil
    
    /// A map or scene model containing bookmarks.
    private var geoModel: GeoModel?
    
    /// User defined action to be performed when a bookmark is selected.
    ///
    /// Use this when you prefer to self-manage the response to a bookmark selection. Use either
    /// `onSelectionChanged(perform:)` or `viewpoint` exclusively.
    var selectionChangedAction: ((Bookmark) -> Void)? = nil
    
    /// If non-`nil`, this viewpoint is updated when a bookmark is selected.
    private var viewpoint: Binding<Viewpoint?>?
    
    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - bookmarks: An array of bookmarks. Use this when displaying bookmarks defined at runtime.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
    ///   Alternately, you can use the `onSelectionChanged(perform:)` modifier to handle
    ///   bookmark selection.
    public init(
        isPresented: Binding<Bool>,
        bookmarks: [Bookmark],
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        _isPresented = isPresented
        self.bookmarks = bookmarks
        self.viewpoint = viewpoint
    }
    
    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - geoModel: A `GeoModel` authored with pre-existing bookmarks.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
    ///   Alternately, you can use the `onSelectionChanged(perform:)` modifier to handle
    ///   bookmark selection.
    public init(
        isPresented: Binding<Bool>,
        geoModel: GeoModel,
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        self.geoModel = geoModel
        self.viewpoint = viewpoint
        self.bookmarks = []
        _isPresented = isPresented
    }
    
    public var body: some View {
        BookmarksHeader(isPresented: $isPresented)
            .padding([.horizontal, .top])
        Divider()
        if !bookmarks.isEmpty {
            list
                .onChange(of: selectedBookmark) { selectedBookmark in
                    if let selectedBookmark {
                        selectBookmark(selectedBookmark)
                    }
                }
        } else if let loadingError {
            makeErrorMessage(with: loadingError)
        } else if geoModel != nil {
            loading
        } else {
            noBookmarks
        }
        // Push content to the top edge.
        Spacer()
    }
}

extension Bookmarks {
    /// The list of bookmarks sorted alphabetically.
    var sortedBookmarks: [Bookmark] {
        bookmarks.sorted { $0.name <  $1.name }
    }
    
    /// Sets an action to perform when the bookmark selection changes.
    /// - Parameter action: The action to perform when the bookmark selection has changed.
    public func onSelectionChanged(
        perform action: @escaping (Bookmark) -> Void
    ) -> Bookmarks {
        var copy = self
        copy.selectionChangedAction = action
        return copy
    }
    
    /// Performs the necessary actions when a bookmark is selected.
    ///
    /// This includes indicating that bookmarks should be set to a hidden state, and changing the viewpoint
    /// binding (if provided) or calling the action provided by the `onSelectionChanged(perform:)` modifier.
    /// - Parameter bookmark: The bookmark that was selected.
    func selectBookmark(_ bookmark: Bookmark) {
        isPresented = false
        if let viewpoint = viewpoint {
            viewpoint.wrappedValue = bookmark.viewpoint
        } else if let onSelectionChanged = selectionChangedAction {
            onSelectionChanged(bookmark)
        }
    }
    
    /// Makes a view that is shown when the `GeoModel` failed to load.
    private func makeErrorMessage(with loadingError: Error) -> Text {
        Text(
            "Error loading bookmarks: \(loadingError.localizedDescription)",
            bundle: .toolkitModule,
            comment: """
                     An error message shown when a GeoModel failed to load.
                     The variable provides additional data.
                     """
        )
    }
    
    /// A view that shows the list of bookmarks.
    ///
    /// - Note: Once the minimum supported platform is 16.4 or greater, the `ScrollView`, `VStack`
    /// and `ForEach` can be replaced with a `List` with `scrollContentBackground(.hidden)` applied.
    private var list: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(sortedBookmarks, id: \.self) { bookmark in
                    Button {
                        selectedBookmark = bookmark
                    } label: {
                        Text(bookmark.name)
                            // Make the entire row tappable.
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(4)
                    if bookmark != sortedBookmarks.last {
                        Divider()
                    }
                }
            }
        }
        .padding([.horizontal])
    }
    
    /// A view that is shown while a `GeoModel` is loading.
    private var loading: some View {
        ProgressView()
            .padding()
            .task {
                do {
                    try await geoModel?.load()
                    bookmarks = geoModel?.bookmarks ?? []
                } catch {
                    loadingError = error
                }
            }
    }
    
    /// A view that is shown when no bookmarks are present.
    private var noBookmarks: some View {
        Label {
            Text(
                "No bookmarks",
                bundle: .toolkitModule,
                comment: "A label indicating that no bookmarks are available for selection."
            )
        } icon: {
            Image(systemName: "bookmark.slash")
        }
        .foregroundColor(.primary)
        .padding()
    }
}
