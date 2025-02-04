// Copyright 2022 Esri
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
import SwiftUI

/// The `Bookmarks` component displays a list of bookmarks and allows the user to make a selection.
/// You can initialize the component with an array of bookmarks or with a `GeoModel`
/// containing bookmarks.
///
/// The map or scene will automatically pan and zoom to the selected bookmark when a `GeoViewProxy`
/// is provided in the initializer. Alternatively, handle selection changes manually using the bound
/// `selection` property.
///
/// The component will automatically hide itself when a selection is made.
///
/// @Image(source: Bookmarks, alt: "An image of the Bookmarks component.")
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [BookmarksExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/BookmarksExampleView.swift)
/// in the project. To learn more about using the `Bookmarks` component see the <doc:BookmarksTutorial>.
@preconcurrency
public struct Bookmarks: View {
    /// The data source used to initialize the view.
    enum BookmarkSource {
        case array([Bookmark])
        case geoModel(GeoModel)
    }
    
    /// The bookmark data source.
    let bookmarkSource: BookmarkSource
    
    /// The proxy to provide access to geo view operations.
    private let geoViewProxy: GeoViewProxy?
    
    /// An error that occurred while loading the geo model.
    @State private var loadingError: Error?
    
    /// Indicates if bookmarks have loaded and are ready for display.
    @State private var isGeoModelLoaded = false
    
    /// Determines if the bookmarks list is currently shown or not.
    @Binding private var isPresented: Bool
    
    /// The selected bookmark.
    private var selection: Binding<Bookmark?>?
    
    /// User defined action to be performed when a bookmark is selected.
    ///
    /// Use this when you prefer to self-manage the response to a bookmark selection. Use either
    /// `onSelectionChanged(perform:)` or `viewpoint` exclusively.
    var selectionChangedAction: ((Bookmark) -> Void)? = nil
    
    /// If non-`nil`, this viewpoint is updated when a bookmark is selected.
    private var viewpoint: Binding<Viewpoint?>?
    
    public var body: some View {
        VStack {
            BookmarksHeader(isPresented: $isPresented)
                .padding([.horizontal, .top])
            Divider()
            switch bookmarkSource {
            case .array(let array):
                makeList(bookmarks: array)
            case .geoModel(let geoModel):
                if isGeoModelLoaded {
                    makeList(bookmarks: geoModel.bookmarks)
                } else if let loadingError {
                    makeErrorMessage(with: loadingError)
                } else if !isGeoModelLoaded {
                    makeLoadingView(geoModel: geoModel)
                }
            }
            Spacer()
        }
        .frame(idealWidth: 320, idealHeight: 428)
    }
}

public extension Bookmarks {
    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - bookmarks: An array of bookmarks. Use this when displaying bookmarks defined at runtime.
    ///   - selection: A selected Bookmark.
    ///   - geoViewProxy: The proxy to provide access to geo view operations.
    ///
    /// When a `GeoViewProxy` is provided, the map or scene will automatically pan and zoom to the
    /// selected bookmark.
    init(
        isPresented: Binding<Bool>,
        bookmarks: [Bookmark],
        selection: Binding<Bookmark?>,
        geoViewProxy: GeoViewProxy? = nil
    ) {
        self.init(
            bookmarkSource: .array(bookmarks),
            geoViewProxy: geoViewProxy,
            isPresented: isPresented,
            selection: selection
        )
    }
    
    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - geoModel: A `GeoModel` authored with pre-existing bookmarks.
    ///   - selection: A selected Bookmark.
    ///   - geoViewProxy: The proxy to provide access to geo view operations.
    ///
    /// When a `GeoViewProxy` is provided, the map or scene will automatically pan and zoom to the
    /// selected bookmark.
    init(
        isPresented: Binding<Bool>,
        geoModel: GeoModel,
        selection: Binding<Bookmark?>,
        geoViewProxy: GeoViewProxy? = nil
    ) {
        self.init(
            bookmarkSource: .geoModel(geoModel),
            geoViewProxy: geoViewProxy,
            isPresented: isPresented,
            selection: selection
        )
    }
}

extension Bookmarks {
    /// Performs the necessary actions when a bookmark is selected.
    ///
    /// This includes indicating that bookmarks should be set to a hidden state, and changing the viewpoint
    /// binding (if provided) or calling the action provided by the `onSelectionChanged(perform:)` modifier.
    /// - Parameter bookmark: The bookmark that was selected.
    func selectBookmark(_ bookmark: Bookmark) {
        selection?.wrappedValue = bookmark
        isPresented = false
        
        if let geoViewProxy, let viewpoint = bookmark.viewpoint {
            Task {
                await geoViewProxy.setViewpoint(viewpoint, duration: nil)
            }
        } else if let viewpoint = viewpoint {
            viewpoint.wrappedValue = bookmark.viewpoint
        }
        
        if let selectionChangedAction {
            selectionChangedAction(bookmark)
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
    
    /// Makes a view that shows a list of bookmarks.
    /// - Parameter bookmarks: The bookmarks to be shown.
    @ViewBuilder private func makeList(bookmarks: [Bookmark]) -> some View {
        if bookmarks.isEmpty {
            noBookmarks
        } else {
            List(bookmarks.sorted { $0.name <  $1.name }, id: \.self, selection: selection) { bookmark in
                // When 'init(isPresented:bookmarks:viewpoint:)' and
                // 'init(isPresented:geoModel:viewpoint:)' are removed, this
                // button can be replaced with 'Text' and the list's selection
                // mechanism and 'onChange(of: selection)' can be used instead.
                Button {
                    selectBookmark(bookmark)
                } label: {
                    Text(bookmark.name)
                        // Make the entire row tappable.
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .contentShape(.rect)
                }
#if !os(visionOS)
                .buttonStyle(.plain)
#endif
#if targetEnvironment(macCatalyst)
                .listRowBackground(bookmark == selection?.wrappedValue ? nil : Color.clear)
#endif
            }
#if !os(visionOS)
            .listStyle(.plain)
#endif
        }
    }
    
    /// Makes a view that is shown while a `GeoModel` is loading.
    private func makeLoadingView(geoModel: GeoModel) -> some View {
        return ProgressView()
            .padding()
            .task(id: geoModel) {
                do {
                    try await geoModel.load()
                    isGeoModelLoaded = true
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
        .foregroundStyle(.primary)
        .padding()
    }
}

public extension Bookmarks /* Deprecated */ {
    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - bookmarks: An array of bookmarks. Use this when displaying bookmarks defined at runtime.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
    /// - Attention: Deprecated at 200.5.
    @available(*, deprecated, message: "Use 'init(isPresented:bookmarks:selection:geoViewProxy:)' instead.")
    init(
        isPresented: Binding<Bool>,
        bookmarks: [Bookmark],
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        self.init(
            bookmarkSource: .array(bookmarks),
            geoViewProxy: nil,
            isPresented: isPresented,
            viewpoint: viewpoint
        )
    }
    
    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - geoModel: A `GeoModel` authored with pre-existing bookmarks.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
    /// - Attention: Deprecated at 200.5.
    @available(*, deprecated, message: "Use 'init(isPresented:geoModel:selection:geoViewProxy:)' instead.")
    init(
        isPresented: Binding<Bool>,
        geoModel: GeoModel,
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        self.init(
            bookmarkSource: .geoModel(geoModel),
            geoViewProxy: nil,
            isPresented: isPresented,
            viewpoint: viewpoint
        )
    }
    
    /// Sets an action to perform when the bookmark selection changes.
    /// - Parameter action: The action to perform when the bookmark selection has changed.
    /// - Attention: Deprecated at 200.5.
    @available(*, deprecated)
    func onSelectionChanged(
        perform action: @escaping (Bookmark) -> Void
    ) -> Bookmarks {
        var copy = self
        copy.selectionChangedAction = action
        return copy
    }
}
