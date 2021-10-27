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

import Swift
import SwiftUI
import ArcGIS
import Combine

/// Manages the state for a `BasemapGallery`.
@MainActor
public class BasemapGalleryViewModel: ObservableObject {
    /// Creates a `BasemapGalleryViewModel`.
    /// - Parameters:
    ///   - geoModel: The `GeoModel`.
    ///   - portal: The `Portal` to load base maps from.
    ///   - basemapGalleryItems: A list of pre-defined base maps to display.
    public init(
        geoModel: GeoModel? = nil,
        portal: Portal? = nil,
        basemapGalleryItems: [BasemapGalleryItem] = []
    ) {
        self.geoModel = geoModel
        self.portal = portal
        self.basemapGalleryItems.append(contentsOf: basemapGalleryItems)
        
        loadGeoModelTask = Task { await loadGeoModel() }
        fetchBasemapTask = Task { await fetchBasemaps() }
    }
    
    deinit {
        loadGeoModelTask?.cancel()
        fetchBasemapTask?.cancel()
    }
    
    @Published
    public var fetchBasemapsError: Error? = nil
    
    @Published
    public var loadGeoModelError: Error? = nil

    /// If the `GeoModel` is not loaded when passed to the `BasemapGalleryViewModel`, then
    /// the geoModel will be immediately loaded. The spatial reference of geoModel dictates which
    /// basemaps from the gallery are enabled. When an enabled basemap is selected by the user,
    /// the geoModel will have its basemap replaced with the selected basemap.
    public var geoModel: GeoModel? {
        didSet {
            loadGeoModelTask?.cancel()
            loadGeoModelTask = Task { await loadGeoModel() }
        }
    }
    
    /// The `Portal` object, if any.  Setting the portal will automatically fetch it's base maps
    /// and add them to the `basemapGalleryItems` array.
    public var portal: Portal? {
       didSet {
           fetchBasemapTask?.cancel()
           fetchBasemapTask = Task { await fetchBasemaps() }
       }
   }
    
    /// The list of basemaps currently visible in the gallery. Items added or removed from this list will
    /// update the gallery.
    @Published
    public var basemapGalleryItems: [BasemapGalleryItem] = []
    
    /// `BasemapGalleryItem` representing the `GeoModel`'s current base map. This may be a
    /// basemap which does not exist in the gallery.
    @Published
    public var currentBasemapGalleryItem: BasemapGalleryItem? = nil {
        didSet {
            guard let item = currentBasemapGalleryItem else { return }
            geoModel?.basemap = item.basemap
        }
    }
    
    /// The currently executing async task for fetching basemaps from the portal.
    /// `fetchBasemapTask` should be cancelled prior to starting another async task.
    private var fetchBasemapTask: Task<Void, Never>? = nil
    
    /// Fetches the basemaps from `portal`.
    private func fetchBasemaps() async {
        guard let portal = portal else { return }

        do {
            basemapGalleryItems += try await portal.developerBasemaps.map {
                BasemapGalleryItem.init(basemap: $0)
            }
        } catch {
            fetchBasemapsError = error
        }
    }
    
    /// The currently executing async task for loading `geoModel`.
    /// `loadGeoModelTask` should be cancelled prior to starting another async task.
    private var loadGeoModelTask: Task<Void, Never>? = nil
    
    /// Loads `geoModel`.
    private func loadGeoModel() async {
        guard let geoModel = geoModel else { return }
        do {
            try await geoModel.load()
            if let basemap = geoModel.basemap {
                currentBasemapGalleryItem = BasemapGalleryItem(basemap: basemap)
            }
            else {
                currentBasemapGalleryItem = nil
            }
        } catch {
            loadGeoModelError = error
        }
    }
}
