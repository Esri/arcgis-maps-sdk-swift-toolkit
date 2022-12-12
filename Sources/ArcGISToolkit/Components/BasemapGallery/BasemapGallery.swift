// Copyright 2021 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

/// The `BasemapGallery` tool displays a collection of basemaps from either
/// ArcGIS Online, a user-defined portal, or an array of `BasemapGalleryItem`s.
/// When a new basemap is selected from the `BasemapGallery` and the optional
/// `BasemapGalleryViewModel.geoModel` property is set, then the basemap of the
/// `geoModel` is replaced with the basemap in the gallery.
public struct BasemapGallery: View {
    /// The view style of the gallery.
    public enum Style {
        /// The `BasemapGallery` will display as a grid when there is an appropriate
        /// width available for the gallery to do so. Otherwise, the gallery will display as a list.
        /// Defaults to `125` when displayed as a list, `300` when displayed as a grid.
        case automatic(listWidth: CGFloat = 125, gridWidth: CGFloat = 300)
        /// The `BasemapGallery` will display as a grid. Defaults to `300`.
        case grid(width: CGFloat = 300)
        /// The `BasemapGallery` will display as a list. Defaults to `125`.
        case list(width: CGFloat = 125)
    }
    
    /// Creates a `BasemapGallery` with the given geo model and array of basemap gallery items.
    /// - Remark: If `items` is empty, ArcGIS Online's developer basemaps will
    /// be loaded and added to `items`.
    /// - Parameters:
    ///   - items: A list of pre-defined base maps to display.
    ///   - geoModel: A geo model.
    public init(
        items: [BasemapGalleryItem] = [],
        geoModel: GeoModel? = nil
    ) {
        viewModel = BasemapGalleryViewModel(geoModel: geoModel, items: items)
    }
    
    /// Creates a `BasemapGallery` with the given geo model and portal.
    /// The portal will be used to retrieve basemaps.
    /// - Parameters:
    ///   - portal: The portal to use to load basemaps.
    ///   - geoModel: A geo model.
    public init(
        portal: Portal,
        geoModel: GeoModel? = nil
    ) {
        viewModel = BasemapGalleryViewModel(geoModel, portal: portal)
    }
    
    /// The view model used by the view. The `BasemapGalleryViewModel` manages the state
    /// of the `BasemapGallery`. The view observes `BasemapGalleryViewModel` for changes
    /// in state. The view updates the state of the `BasemapGalleryViewModel` in response to
    /// user action.
    @ObservedObject private var viewModel: BasemapGalleryViewModel
    
    /// The style of the basemap gallery. The gallery can be displayed as a list, grid, or automatically
    /// switch between the two based on-screen real estate. Defaults to ``BasemapGallery/Style/automatic``.
    /// Set using the `style` modifier.
    private var style: Style = .automatic()
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// If `true`, the gallery will display as if the device is in a regular-width orientation.
    /// If `false`, the gallery will display as if the device is in a compact-width orientation.
    private var isRegularWidth: Bool {
        !(horizontalSizeClass == .compact && verticalSizeClass == .regular)
    }
    
    /// The width of the gallery, taking into account the horizontal and vertical size classes of the device.
    private var galleryWidth: CGFloat {
        switch style {
        case .list(let width):
            return width
        case .grid(let width):
            return width
        case .automatic(let listWidth, let gridWidth):
            return isRegularWidth ? gridWidth : listWidth
        }
    }
    
    /// A Boolean value indicating whether to show an error alert.
    @State private var showErrorAlert = false
    
    /// The current alert item to display.
    @State private var alertItem: AlertItem?
    
    /// The height of the basemap gallery content.
    @State private var contentHeight: CGFloat = .zero
    
    public var body: some View {
        GeometryReader { geometry in
            makeGalleryView()
                .onReceive(
                    viewModel.$spatialReferenceMismatchError.dropFirst(),
                    perform: { error in
                        guard let error = error else { return }
                        alertItem = AlertItem(spatialReferenceMismatchError: error)
                        showErrorAlert = true
                    }
                )
                .alert(
                    alertItem?.title ?? "",
                    isPresented: $showErrorAlert,
                    presenting: alertItem
                ) { _ in
                } message: { item in
                    Text(item.message)
                }
                .frame(height: min(contentHeight, geometry.size.height))
                .esriBorder()
        }
        .frame(width: galleryWidth)
    }
}

private extension BasemapGallery {
    /// Creates a gallery view.
    /// - Returns: A view representing the basemap gallery.
    func makeGalleryView() -> some View {
        ScrollView {
            switch style {
            case .automatic:
                if isRegularWidth {
                    makeGridView()
                } else {
                    makeListView()
                }
            case .grid:
                makeGridView()
            case .list:
                makeListView()
            }
        }
    }
    
    /// The gallery view, displayed as a grid.
    /// - Returns: A view representing the basemap gallery grid.
    func makeGridView() -> some View {
        internalMakeGalleryView(
            columns: Array(
                repeating: GridItem(
                    .flexible(),
                    alignment: .top
                ),
                count: 3
            )
        )
    }
    
    /// The gallery view, displayed as a list.
    /// - Returns: A view representing the basemap gallery list.
    func makeListView() -> some View {
        internalMakeGalleryView(
            columns: [
                .init(
                    .flexible(),
                    alignment: .top
                )
            ]
        )
    }
    
    /// The gallery view, displayed in the specified columns.
    /// - Parameter columns: The columns used to display the basemap items.
    /// - Returns: A view representing the basemap gallery with the specified columns.
    func internalMakeGalleryView(columns: [GridItem]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(viewModel.items) { item in
                BasemapGalleryCell(
                    item: item,
                    isSelected: item == viewModel.currentItem
                ) {
                    if let loadError = item.loadBasemapError {
                        alertItem = AlertItem(loadBasemapError: loadError)
                        showErrorAlert = true
                    } else {
                        viewModel.setCurrentItem(item)
                    }
                }
            }
        }
        .onSizeChange {
            contentHeight = $0.height
        }
    }
}

// MARK: Modifiers

public extension BasemapGallery {
    /// The style of the basemap gallery. Defaults to ``Style/automatic(listWidth:gridWidth:)``.
    /// - Parameter style: The `Style` to use.
    /// - Returns: The `BasemapGallery`.
    func style(
        _ newStyle: Style
    ) -> BasemapGallery {
        var copy = self
        copy.style = newStyle
        return copy
    }
}

// MARK: AlertItem

/// An item used to populate a displayed alert.
struct AlertItem {
    var title: String = ""
    var message: String = ""
}

extension AlertItem {
    /// Creates an alert item based on an error generated loading a basemap.
    /// - Parameter loadBasemapError: The load basemap error.
    init(loadBasemapError: Error) {
        self.init(
            title: "Error loading basemap.",
            message: "\((loadBasemapError as? ArcGISError)?.failureReason ?? "The basemap failed to load for an unknown reason.")"
        )
    }
    
    /// Creates an alert item based on a spatial reference mismatch error.
    /// - Parameter spatialReferenceMismatchError: The error associated with the mismatch.
    init(spatialReferenceMismatchError: SpatialReferenceMismatchError) {
        let message: String
        
        switch (spatialReferenceMismatchError.basemapSpatialReference, spatialReferenceMismatchError.geoModelSpatialReference) {
        case (.some(_), .some(_)):
            message = "The basemap has a spatial reference that is incompatible with the map."
        case (_, .none):
            message = "The map does not have a spatial reference."
        case (.none, _):
            message = "The basemap does not have a spatial reference."
        }
        
        self.init(
            title: "Spatial reference mismatch.",
            message: message
        )
    }
}
