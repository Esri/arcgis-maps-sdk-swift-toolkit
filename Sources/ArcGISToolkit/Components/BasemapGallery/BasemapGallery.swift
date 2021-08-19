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
    
    /// Creates a `BasemapGallery`. Generates a list of appropriate, default basemaps.
    /// The given default basemaps require either an API key or named-user to be signed into the app.
    /// These basemaps are sourced from this PortalGroup:
    /// https://www.arcgis.com/home/group.html?id=a25523e2241d4ff2bcc9182cc971c156).
    /// `BasemapmapGallery.currentBasemap` is set to the basemap of the given
    /// geoModel if not `nil`.
    /// - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
    public init(geoModel: GeoModel? = nil) {
        self.geoModel = geoModel
        self.currentBasemap = geoModel?.basemap
        self.portal = Portal.arcGISOnline(loginRequired: false)
    }
    
    /// Creates a `BasemapGallery`. Uses the given `portal` to retrieve basemaps.
    /// `BasemapmapGallery.currentBasemap` is set to the basemap of the given
    /// geoModel if not `nil`.
    /// - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
    /// - Parameter portal: The `GeoModel` we're selecting the basemap for.
    public init(
        geoModel: GeoModel? = nil,
        portal: Portal
    ) {
        self.geoModel = geoModel
        self.currentBasemap = geoModel?.basemap
        self.portal = portal
    }
    
    /// Creates a `BasemapGallery`. Uses the given list of basemap gallery items.
    /// `BasemapmapGallery.currentBasemap` is set to the basemap of the given
    /// geoModel if not `nil`.
    /// - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
    /// - Parameter basemapGalleryItems: The `GeoModel` we're selecting the basemap for.
    public init(
        geoModel: GeoModel? = nil,
        basemapGalleryItems: [BasemapGalleryItem] = []
    ) {
        self.geoModel = geoModel
        self.currentBasemap = geoModel?.basemap
        self._basemapGalleryItems = State(wrappedValue: basemapGalleryItems)
    }
    
    /// If the `GeoModel` is not loaded when passed to the `BasemapGallery`, then the
    /// geoModel will be immediately loaded. The spatial reference of geoModel dictates which
    /// basemaps from the gallery are enabled.
    /// When an enabled basemap is selected by the user, the geoModel will have its
    /// basemap replaced with the selected basemap.
    public var geoModel: GeoModel? = nil
    
    @State
    /// Currently applied basemap on the associated `GeoModel`. This may be a basemap
    /// which does not exist in the gallery.
    public var currentBasemap: Basemap? = nil
    
    /// The `Portal` object, if set in the constructor of the `BasemapGallery`.
    public var portal: Portal? = nil

    @State
    /// The list of basemaps currently visible in the gallery. Items added or removed from this list will
    /// update the gallery.
    public var basemapGalleryItems: [BasemapGalleryItem] = []

    @State
    private var fetchBasemapsResult: Result<[BasemapGalleryItem]?, Error>? = .success([])

    /// The style of the basemap gallery. The gallery can be displayed as a list, grid, or automatically
    /// switch between the two based on screen real estate. Defaults to `automatic`.
    /// Set using the `basemapGalleryStyle` modifier.
    private var style: BasemapGalleryStyle = .automatic
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    public var body: some View {
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
        Spacer()
            .task {
                let result = await Result {
                    try await portal?.fetchDeveloperBasemaps()
                }
                switch result {
                case .success(let basemaps):
                    let items = basemaps.map {
                        $0.map {
                            BasemapGalleryItem(basemap: $0)
                        }
                    }
                    _fetchBasemapsResult = State(wrappedValue: .success(items))
//                    _basemapGalleryItems = State(wrappedValue: items)
                case .failure(let error):
                    self?.results = .failure(error)
                    break
                case .none:
                    self?.results = .success(nil)
                    break
                }
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
    private func GridView() -> some View {
        let columns: [GridItem] = [
            .init(.flexible(), spacing: 8.0, alignment: .top),
            .init(.flexible(), spacing: 8.0, alignment: .top),
            .init(.flexible(), spacing: 8.0, alignment: .top)
        ]

        return GalleryView(columns)
    }
    
    private func ListView() -> some View {
        let columns: [GridItem] = [
            .init(.flexible(), spacing: 8.0, alignment: .top)
        ]

        return GalleryView(columns)
    }
    
    private func GalleryView(_ columns: [GridItem]) -> some View {
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(basemapGalleryItems) { basemapGalleryItem in
                    BasemapGalleryItemRow(
                        basemapGalleryItem: basemapGalleryItem,
                        currentBasemap: currentBasemap
                    )
                        .onTapGesture {
                            geoModel?.basemap = basemapGalleryItem.basemap
                            currentBasemap = basemapGalleryItem.basemap
                        }
                }
            }
        }
        .esriBorder()
    }
}

private struct BasemapGalleryItemRow: View {
    var basemapGalleryItem: BasemapGalleryItem
    var currentBasemap: Basemap? = nil
    
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
    }
}
