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
    /// Creates a `BasemapGallery`.
    /// - Parameter viewModel: The view model used by the `BasemapGallery`.
    public init(viewModel: BasemapGalleryViewModel? = nil) {
        self.viewModel = viewModel ?? BasemapGalleryViewModel()
    }
    
    /// The view model used by the view. The `BasemapGalleryViewModel` manages the state
    /// of the `BasemapGallery`. The view observes `BasemapGalleryViewModel` for changes
    /// in state. The view updates the state of the `BasemapGalleryViewModel` in response to
    /// user action.
    @ObservedObject
    public var viewModel: BasemapGalleryViewModel

    /// A Boolean value indicating whether to show an error alert.
    @State
    private var showErrorAlert = false
    
    /// The current alert item to display.
    @State
    private var alertItem: AlertItem?
    
    public var body: some View {
        makeGalleryView()
            .alert(
                alertItem?.title ?? "",
                isPresented: $showErrorAlert,
                presenting: alertItem) { item in
                    Text(item.message)
                }
    }
}

private extension BasemapGallery {
    /// The gallery view, displayed in the specified columns.
    /// - Parameter columns: The columns used to display the basemap items.
    /// - Returns: A view representing the basemap gallery with the specified columns.
    func makeGalleryView() -> some View {
        ScrollView {
            let columns = Array(
                repeating: GridItem(
                    .flexible(minimum: 75, maximum: 100),
                    alignment: .top
                ),
                count: 3
            )
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
                            viewModel.currentItem = item
                        }
                    }
                }
            }
        }
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
            message: "\((loadBasemapError as? RuntimeError)?.failureReason ?? "The basemap failed to load for an unknown reason.")"
        )
    }
}
