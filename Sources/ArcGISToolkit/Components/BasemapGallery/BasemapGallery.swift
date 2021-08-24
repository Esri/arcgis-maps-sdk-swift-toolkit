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
    
    public init(viewModel: BasemapGalleryViewModel? = nil) {
        if let viewModel = viewModel {
            self.viewModel = viewModel
        }
        else {
            self.viewModel = BasemapGalleryViewModel()
        }
    }
    
    @ObservedObject
    public var viewModel: BasemapGalleryViewModel
    
    /// The style of the basemap gallery. The gallery can be displayed as a list, grid, or automatically
    /// switch between the two based on screen real estate. Defaults to `automatic`.
    /// Set using the `basemapGalleryStyle` modifier.
    private var style: BasemapGalleryStyle = .automatic
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public var body: some View {
        GalleryView()
            .task {
                await viewModel.fetchBasemaps()
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
                        basemapGalleryItem: basemapGalleryItem
                    )
                        .onTapGesture {
                            viewModel.geoModel?.basemap = basemapGalleryItem.basemap
                        }
                }
            }
        }
        .esriBorder()
    }
}

private struct BasemapGalleryItemRow: View {
    var basemapGalleryItem: BasemapGalleryItem
    
    var body: some View {
        VStack {
            if let thumbnailImage = basemapGalleryItem.thumbnail {
                // TODO: thumbnail will have to be loaded.
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Text(basemapGalleryItem.name)
                .font(.footnote)
        }
//        if basemapGalleryItem == currentBasemap {
//            .background(Color.accentColor)
//        }
    }
}
