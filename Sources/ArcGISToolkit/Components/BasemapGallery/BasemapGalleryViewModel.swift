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

/// Manages the state for a `BasemapGallery`.
@MainActor
public class BasemapGalleryViewModel: ObservableObject {
    /// Creates a `BasemapGalleryViewModel`
    /// - Remark: The ArcGISOnline's developer basemaps will
    /// be loaded and added to `basemapGalleryItems`.
    /// - Parameter geoModel: The `GeoModel`.
    public convenience init(_ geoModel: GeoModel? = nil) {
        self.init(geoModel, basemapGalleryItems: [])
    }

    /// Creates a `BasemapGalleryViewModel`. Uses the given array of basemap gallery items.
    /// - Remark: If `basemapGalleryItems` is empty, ArcGISOnline's developer basemaps will
    /// be loaded and added to `basemapGalleryItems`.
    /// - Parameters:
    ///   - geoModel: The `GeoModel`.
    ///   - basemapGalleryItems: A list of pre-defined base maps to display.
    public init(
        _ geoModel: GeoModel? = nil,
        basemapGalleryItems: [BasemapGalleryItem]
    ) {
        self.basemapGalleryItems.append(contentsOf: basemapGalleryItems)
        
        defer {
            // Using `defer` allows the property `didSet` observers to be called.
            self.geoModel = geoModel
        }
    }
    
    /// If the `GeoModel` is not loaded when passed to the `BasemapGalleryViewModel`, then
    /// the geoModel will be immediately loaded. The spatial reference of geoModel dictates which
    /// basemaps from the gallery are enabled. When an enabled basemap is selected by the user,
    /// the geoModel will have its basemap replaced with the selected basemap.
    public var geoModel: GeoModel? {
        didSet {
            guard let geoModel = geoModel else { return }
            Task { await load(geoModel: geoModel) }
        }
    }
    
    /// The list of basemaps currently visible in the gallery. It is comprised of items passed into
    /// the `BasemapGalleryItem` constructor property.
    @Published
    public var basemapGalleryItems: [BasemapGalleryItem] = []
    
    /// The `BasemapGalleryItem` representing the `GeoModel`'s current base map. This may be a
    /// basemap which does not exist in the gallery.
    @Published
    public var currentBasemapGalleryItem: BasemapGalleryItem? = nil {
        didSet {
            guard let item = currentBasemapGalleryItem else { return }
            geoModel?.basemap = item.basemap
        }
    }
}

private extension BasemapGalleryViewModel {
    /// Loads the given `GeoModel` then sets `currentBasemapGalleryItem` to an item
    /// created with the geoModel's basemap.
    /// - Parameter geoModel: The `GeoModel` to load.
    func load(geoModel: GeoModel?) async {
        guard let geoModel = geoModel else { return }
        do {
            try await geoModel.load()
            if let basemap = geoModel.basemap {
                currentBasemapGalleryItem = BasemapGalleryItem(basemap: basemap)
            }
            else {
                currentBasemapGalleryItem = nil
            }
        } catch { }
    }
}
