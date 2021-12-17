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
/// `BasemapGallery.geoModel` property is set, then the basemap of the geoModel is replaced
/// with the basemap in the gallery.
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

    /// A Boolean value indicating whether the error alert should be shown.
    @State
    private var showErrorAlert = false
    
    /// The current alert item to display.
    @State
    private var alertItem: AlertItem?
    
    public var body: some View {
        makeGalleryView()
            .frame(width: 300)
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
            let columns = Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)
            LazyVGrid(columns: columns) {
                ForEach(viewModel.items) { item in
                    BasemapGalleryItemRow(
                        item: item,
                        isSelected: item == viewModel.currentBasemapGalleryItem
                    )
                        .onTapGesture {
                            if let loadError = item.loadBasemapsError {
                                alertItem = AlertItem(loadBasemapError: loadError)
                                showErrorAlert = true
                            } else {
                                viewModel.currentBasemapGalleryItem = item
                            }
                        }
                }
            }
        }
        .esriBorder()
    }
}

/// A row or grid element representing a basemap gallery item.
private struct BasemapGalleryItemRow: View {
    @ObservedObject var item: BasemapGalleryItem
    let isSelected: Bool
    
    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                // Display the thumbnail, if available.
                if let thumbnailImage = item.thumbnail {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .border(
                            isSelected ? Color.accentColor: Color.clear,
                            width: 3.0)
                }
                
                // Display an image representing either a load basemap error
                // or a spatial reference mismatch error.
                if item.loadBasemapsError != nil {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                
                // Display a progress view if the item is loading.
                if item.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .esriBorder()
                }
            }
            
            // Display the name of the item.
            Text(item.name)
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
        .allowsHitTesting(
            !item.isLoading
        )
    }
}

// MARK: AlertItem

/// An item used to populate a displayed alert.
struct AlertItem {
    var title: String = ""
    var message: String = ""
}

extension AlertItem: Identifiable {
    public var id: UUID { UUID() }
}

extension AlertItem {
    /// Creates an alert item based on an error generated loading a basemap.
    /// - Parameter loadBasemapError: The load basemap error.
    init(loadBasemapError: RuntimeError) {
        self.init(
            title: "Error loading basemap.",
            message: "\(loadBasemapError.failureReason ?? "The basemap failed to load for an unknown reason.")"
        )
    }
}
