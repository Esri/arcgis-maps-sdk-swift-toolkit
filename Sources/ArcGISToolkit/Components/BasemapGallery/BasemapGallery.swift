// Copyright 2021 Esri
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

import SwiftUI
import ArcGIS

/// The `BasemapGallery` displays a collection of basemaps from ArcGIS Online, a user-defined
/// portal, or an array of ``BasemapGalleryItem`` objects. When a new basemap is selected from the
/// `BasemapGallery` and a geo model was provided when the basemap gallery was created, the
/// basemap of the `geoModel` is replaced with the basemap in the gallery.
///
/// | iPhone | iPad |
/// | ------ | ---- |
/// | ![image](https://user-images.githubusercontent.com/3998072/205385086-cb9bc0a0-3c46-484d-aefa-8878c7112a3e.png) | ![image](https://user-images.githubusercontent.com/3998072/205384854-79f25efe-25f4-4330-a487-b64b528a9daf.png) |
///
/// > Note: `BasemapGallery` uses metered ArcGIS basemaps by default, so you will need to configure
/// an API key. See [Security and authentication documentation](https://developers.arcgis.com/documentation/mapping-apis-and-services/security/#api-keys)
/// for more information.
///
/// **Features**
///
/// - Can be configured to use a list, grid, or automatic layout. When using an
/// automatic layout, list or grid presentation is chosen based on the horizontal size class of the
/// environment.
/// - Displays basemaps from a portal or a custom collection. If neither a custom portal or array of
/// basemaps is provided, the list of basemaps will be loaded from ArcGIS Online.
/// - Displays a representation of the map or scene's current basemap if that basemap exists in the
/// gallery.
/// - Displays a name and thumbnail for each basemap.
/// - Can be configured to automatically change the basemap of a geo model based on user selection.
///
/// `BasemapGallery` has the following helper class: ``BasemapGalleryItem``
///
/// **Behavior**
///
/// Selecting a basemap with a spatial reference that does not match that of the geo model
/// will display an error. It will also display an error if a provided base map cannot be loaded. If
/// a `GeoModel` is provided to the `BasemapGallery`, selecting an item in the gallery will set that
/// basemap on the geo model.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [BasemapGalleryExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/BasemapGalleryExampleView.swift)
/// in the project. To learn more about using the `BasemapGallery` see the <doc:BasemapGalleryTutorial>.
@preconcurrency
public struct BasemapGallery: View {
    /// The view style of the gallery.
    public enum Style: Sendable {
        /// The `BasemapGallery` will display as a grid when there is an appropriate
        /// width available for the gallery to do so. Otherwise, the gallery will display as a list.
        /// When displayed as a grid, `maxGridItemWidth` sets the maximum width of a grid item.
        case automatic(maxGridItemWidth: CGFloat = 300)
        /// The `BasemapGallery` will display as a grid.
        case grid(maxItemWidth: CGFloat = 300)
        /// The `BasemapGallery` will display as a list.
        case list
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
        _viewModel = StateObject(wrappedValue: BasemapGalleryViewModel(geoModel: geoModel, items: items))
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
        _viewModel = StateObject(wrappedValue: BasemapGalleryViewModel(geoModel, portal: portal))
    }
    
    /// The view model used by the view. The `BasemapGalleryViewModel` manages the state
    /// of the `BasemapGallery`. The view observes `BasemapGalleryViewModel` for changes
    /// in state. The view updates the state of the `BasemapGalleryViewModel` in response to
    /// user action.
    @StateObject private var viewModel: BasemapGalleryViewModel
    
    /// The style of the basemap gallery. The gallery can be displayed as a list, grid, or automatically
    /// switch between the two based on-screen real estate. Defaults to ``BasemapGallery/Style/automatic``.
    /// Set using the `style` modifier.
    private var style: Style = .automatic()
    
    @Environment(\.isPortraitOrientation) var isPortraitOrientation
    
    /// If `true`, the gallery will display as if the device is in a regular-width orientation.
    /// If `false`, the gallery will display as if the device is in a compact-width orientation.
    private var isRegularWidth: Bool {
        !isPortraitOrientation
    }
    
    /// A Boolean value indicating whether to show an error alert.
    @State private var showErrorAlert = false
    
    /// The current alert item to display.
    @State private var alertItem: AlertItem?
    
    public var body: some View {
        GeometryReader { geometry in
            makeGalleryView(geometry.size.width)
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
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
        }
    }
}

private extension BasemapGallery {
    /// Creates a gallery view.
    /// - Parameter containerWidth: The width of the container holding the gallery.
    /// - Returns: A view representing the basemap gallery.
    func makeGalleryView(_ containerWidth: CGFloat) -> some View {
        ScrollView {
            switch style {
            case .automatic(let maxGridItemWidth):
                if isRegularWidth {
                    makeGridView(containerWidth, maxGridItemWidth)
                } else {
                    makeListView()
                }
            case .grid(let maxItemWidth):
                makeGridView(containerWidth, maxItemWidth)
            case .list:
                makeListView()
            }
        }
    }
    
    /// The gallery view, displayed as a grid.
    /// - Parameters:
    ///   - containerWidth: The width of the container holding the grid view.
    ///   - maxItemWidth: The maximum allowable width for an item in the grid. Defaults to `300`.
    /// - Returns: A view representing the basemap gallery grid.
    func makeGridView(_ containerWidth: CGFloat, _ maxItemWidth: CGFloat) -> some View {
        internalMakeGalleryView(
            columns: Array(
                repeating: GridItem(
                    .flexible(),
                    alignment: .top
                ),
                count: max(
                    1,
                    Int((containerWidth / maxItemWidth).rounded(.down))
                )
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
    }
}

// MARK: Modifiers

public extension BasemapGallery {
    /// The style of the basemap gallery. Defaults to ``Style/automatic(maxGridItemWidth:)``.
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
            title: String.basemapFailedToLoadTitle,
            message: (loadBasemapError as? ArcGISError)?.details ?? String.basemapFailedToLoadFallbackError
        )
    }
    
    /// Creates an alert item based on a spatial reference mismatch error.
    /// - Parameter spatialReferenceMismatchError: The error associated with the mismatch.
    init(spatialReferenceMismatchError: SpatialReferenceMismatchError) {
        let message: String
        
        switch (spatialReferenceMismatchError.basemapSpatialReference, spatialReferenceMismatchError.geoModelSpatialReference) {
        case (.some(_), .some(_)):
            message = String(
                localized: "The basemap has a spatial reference that is incompatible with the map.",
                bundle: .toolkitModule,
                comment: """
                         A label indicating the spatial reference of the chosen basemap doesn't
                         match the spatial reference of the map.
                         """
            )
        case (_, .none):
            message = String(
                localized: "The map does not have a spatial reference.",
                bundle: .toolkitModule,
                comment: "A label indicating the map doesn't have a spatial reference."
            )
        case (.none, _):
            message = String(
                localized: "The basemap does not have a spatial reference.",
                bundle: .toolkitModule,
                comment: "A label indicating the chosen basemap doesn't have a spatial reference."
            )
        }
        
        self.init(
            title: String(
                localized: "Spatial reference mismatch.",
                bundle: .toolkitModule,
                comment: """
                         A label indicating the spatial reference of the chosen basemap doesn't
                         match the spatial reference of the map or scene.
                         """
            ),
            message: message
        )
    }
}

private extension String {
    static let basemapFailedToLoadFallbackError = String(
        localized: "The basemap failed to load for an unknown reason.",
        bundle: .toolkitModule,
        comment: """
                 An error to be displayed when a basemap chosen from the basemap gallery fails to
                 load for an unknown reason.
                 """
    )
    
    static let basemapFailedToLoadTitle = String(
        localized: "Error loading basemap.",
        bundle: .toolkitModule,
        comment: "An error to be displayed when a basemap chosen from the basemap gallery fails to load."
    )
}
