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

/// The `BasemapGallery` tool displays a collection of images representing basemaps from
/// ArcGIS Online, a user-defined portal, or an array of `Basemap`s.
/// When a new basemap is selected from the `BasemapGallery` and the optional
/// `BasemapGallery.geoModel` property is set, then the basemap of the geoModel is replaced
/// with the basemap in the gallery.
public struct BasemapGallery: View {
    /// The view style of the gallery.
    public enum BasemapGalleryStyle {
        /// The `BasemapGallery` will display as a grid when there is appropriate
        /// width available for the gallery to do so. Otherwise the gallery will display as a list.
        case automatic
        /// The `BasemapGallery` will display as a grid.
        case grid
        /// The `BasemapGallery` will display as a list.
        case list
    }
    
    /// Creates a `BasemapGallery`.
    /// - Parameter viewModel: The view model used by the `BasemapGallery`.
    public init(viewModel: BasemapGalleryViewModel? = nil) {
        if let viewModel = viewModel {
            self.viewModel = viewModel
        }
        else {
            self.viewModel = BasemapGalleryViewModel()
        }
    }
    
    /// The view model used by the view. The `BasemapGalleryViewModel` manages the state
    /// of the `BasemapGallery`. The view observes `BasemapGalleryViewModel` for changes
    /// in state. The view updates the state of the `BasemapGalleryViewModel` in response to
    /// user action.
    @ObservedObject
    public var viewModel: BasemapGalleryViewModel
    
    /// The style of the basemap gallery. The gallery can be displayed as a list, grid, or automatically
    /// switch between the two based on screen real estate. Defaults to `automatic`.
    /// Set using the `basemapGalleryStyle` modifier.
    private var style: BasemapGalleryStyle = .automatic
    
    /// The size class used to determine if the basemap items should dispaly in a list or grid.
    /// If the size class is `.regular`, they display in a grid.  If it is `.compact`, they display in a list.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State
    private var alertItem: AlertItem?

    public var body: some View {
        GalleryView()
            .alert(item: $alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message)
                )
            }
    }
    
    // MARK: Modifiers
    
    /// The style of the basemap gallery. Defaults to `.automatic`.
    /// - Parameter style: The `BasemapGalleryStyle` to use.
    /// - Returns: The `BasemapGallery`.
    public func basemapGalleryStyle(_ style: BasemapGalleryStyle) -> BasemapGallery {
        var copy = self
        copy.style = style
        return copy
    }
}

extension BasemapGallery {
    @ViewBuilder
    private func GalleryView() -> some View {
        switch style {
        case .automatic:
            if horizontalSizeClass == .regular {
                GridView()
            }
            else {
                ListView()
            }
        case .grid:
            GridView()
        case .list:
            ListView()
        }
    }
    
    private func GridView() -> some View {
        let columns: [GridItem] = [
            .init(.flexible(), spacing: 8.0, alignment: .top),
            .init(.flexible(), spacing: 8.0, alignment: .top),
            .init(.flexible(), spacing: 8.0, alignment: .top)
        ]

        return InternalGalleryView(columns)
    }
    
    private func ListView() -> some View {
        let columns: [GridItem] = [
            .init(.flexible(), spacing: 8.0, alignment: .top)
        ]

        return InternalGalleryView(columns)
    }
    
    private func InternalGalleryView(_ columns: [GridItem]) -> some View {
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.basemapGalleryItems) { basemapGalleryItem in
                    BasemapGalleryItemRow(
                        basemapGalleryItem: basemapGalleryItem,
                        isSelected: basemapGalleryItem == viewModel.currentBasemapGalleryItem
                    )
                        .onTapGesture {
                            // Don't check spatial reference until user taps on it.
                            // At this point, we need to get errors from setting the basemap (in the model?).
                            // Error in the model, displayed in the gallery.
                            
                            // TODO:  this doesn't work until the basemap is tapped on once, then I assume
                            // TODO: it's loaded the basemap layers.  Figure this out.  (load base layers when bm loads?)
                            if let loadError = basemapGalleryItem.loadBasemapsError {
                                alertItem = AlertItem(error: loadError)
                                print("basemaps DON'T match (or error)!")
                            }
                            else {
                                //                                if !showingBasemapLoadError,
                                //                                   basemapGalleryItem.matchesSpatialReference(viewModel.geoModel?.spatialReference) {
                                Task {
                                    try await basemapGalleryItem.updateSpatialReferenceStatus(for: viewModel.geoModel?.spatialReference)
                                    if basemapGalleryItem.spatialReferenceStatus == .match ||
                                        basemapGalleryItem.spatialReferenceStatus == .unknown {
                                        print("basemap matches!")
                                        viewModel.currentBasemapGalleryItem = basemapGalleryItem
                                    }
                                    else {
                                        alertItem = AlertItem(
                                            basemapSR: basemapGalleryItem.spatialReference,
                                            geoModelSR: viewModel.geoModel?.spatialReference
                                        )
                                        print("Task bm don't match")
                                    }
                                }
                            }
                        }
                }
            }
        }
        .esriBorder()
    }
}

private struct BasemapGalleryItemRow: View {
    @ObservedObject var basemapGalleryItem: BasemapGalleryItem
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            VStack {
                if basemapGalleryItem.isLoading {
                    Spacer()
                    ProgressView()
                       .progressViewStyle(CircularProgressViewStyle())
                    Spacer()

                } else {
                    ZStack(alignment: .center) {
                        if let thumbnailImage = basemapGalleryItem.thumbnail {
                            Image(uiImage: thumbnailImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .border(
                                    isSelected ? Color.accentColor: Color.clear,
                                    width: 3.0)
                        }
                        
                        if basemapGalleryItem.loadBasemapsError != nil {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        } else if basemapGalleryItem.spatialReferenceStatus == .noMatch {
                            Image(systemName: "x.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }
                }
                Text(basemapGalleryItem.name)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
        }
        .allowsHitTesting(
            !basemapGalleryItem.isLoading
        )
    }
}

struct AlertItem {
    var title: String = ""
    var message: String = ""
}

extension AlertItem: Identifiable {
    public var id: UUID { UUID() }
}

// TODO: add SR for basemap, if possible (SR property on basemap?)  Maybe that can speed up baselayer sr checking...
// TODO: Cleanup all .tapGesture code, alert code, old error/alert stuff
// TODO: Figure out common errors, so I don't need to rely on `Error` or `RuntimeError`.
extension AlertItem {
    init(basemapSR: SpatialReference?, geoModelSR: SpatialReference?) {
        self.init(
            title: "Spatial Reference mismatch.",
            message: "The spatial reference of the basemap \(basemapSR?.description ?? "") does not match that of the GeoModel \(geoModelSR?.description ?? "")."
        )
    }

    init(error: Error) {
        self.init(
            title: "Error loading basemap.",
            message: "\(error.localizedDescription)"
        )
    }
}
