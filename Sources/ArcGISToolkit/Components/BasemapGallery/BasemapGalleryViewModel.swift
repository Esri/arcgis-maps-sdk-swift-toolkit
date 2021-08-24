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
public class BasemapGalleryViewModel: ObservableObject {
    public init(
        geoModel: GeoModel? = nil,
        portal: Portal? = nil,
        basemapGalleryItems: [BasemapGalleryItem] = []
    ) {
        self.geoModel = geoModel
        self.portal = portal
        self.basemapGalleryItems = basemapGalleryItems
    }
    
//
//    /// Creates a `BasemapGalleryViewModel`. Generates a list of appropriate, default basemaps.
//    /// The given default basemaps require either an API key or named-user to be signed into the app.
//    /// These basemaps are sourced from this PortalGroup:
//    /// https://www.arcgis.com/home/group.html?id=a25523e2241d4ff2bcc9182cc971c156).
//    /// `BasemapGalleryViewModel.currentBasemap` is set to the basemap of the given
//    /// geoModel if not `nil`.
//    /// - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
//    public init(geoModel: GeoModel? = nil) {
//        self.geoModel = geoModel
//        self.currentBasemap = geoModel?.basemap
//        self.portal = Portal.arcGISOnline(loginRequired: false)
//    }
//
//    /// Creates a `BasemapGalleryViewModel`. Uses the given `portal` to retrieve basemaps.
//    /// `BasemapGalleryViewModel.currentBasemap` is set to the basemap of the given
//    /// geoModel if not `nil`.
//    /// - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
//    /// - Parameter portal: The `GeoModel` we're selecting the basemap for.
//    public init(
//        geoModel: GeoModel? = nil,
//        portal: Portal
//    ) {
//        self.geoModel = geoModel
//        self.currentBasemap = geoModel?.basemap
//        self.portal = portal
//    }
//
//    /// Creates a `BasemapGalleryViewModel`. Uses the given list of basemap gallery items.
//    /// `BasemapGalleryViewModel.currentBasemap` is set to the basemap of the given
//    /// geoModel if not `nil`.
//    /// - Parameter geoModel: The `GeoModel` we're selecting the basemap for.
//    /// - Parameter basemapGalleryItems: The `GeoModel` we're selecting the basemap for.
//    public init(
//        geoModel: GeoModel? = nil,
//        basemapGalleryItems: [BasemapGalleryItem] = []
//    ) {
//        self.geoModel = geoModel
//        self.currentBasemap = geoModel?.basemap
//        self.basemapGalleryItems = basemapGalleryItems
//    }
    
    /// If the `GeoModel` is not loaded when passed to the `BasemapGalleryViewModel`, then
    /// the geoModel will be immediately loaded. The spatial reference of geoModel dictates which
    /// basemaps from the gallery are enabled. When an enabled basemap is selected by the user,
    /// the geoModel will have its basemap replaced with the selected basemap.
    public var geoModel: GeoModel? = nil
    
    /// The `Portal` object, if any.
    public var portal: Portal? = nil

    @Published
    /// The list of basemaps currently visible in the gallery. Items added or removed from this list will
    /// update the gallery.
    public var basemapGalleryItems: [BasemapGalleryItem] = []
    
    /// Currently applied basemap on the associated `GeoModel`. This may be a basemap
    /// which does not exist in the gallery.
    public var currentBasemap: Basemap? {
        get async throws {
            guard let geoModel = geoModel else { return nil }
            try await geoModel.load()
            return geoModel.basemap
        }
    }

    /// The currently executing async task.  `currentTask` should be cancelled
    /// prior to starting another async task.
    private var currentTask: Task<Void, Never>? = nil
    
    /// Updates suggestions list asynchronously.
    public func fetchBasemaps() async -> Void {
        guard let portal = portal else { return }
        
        currentTask?.cancel()
        currentTask = fetchBasemapsTask(portal)
        await currentTask?.value
    }
}

extension BasemapGalleryViewModel {
    private func fetchBasemapsTask(_ portal: Portal) -> Task<(), Never> {
        let task = Task(operation: {
            let basemapResults = await Result {
                try await portal.fetchDeveloperBasemaps()
            }
            
            DispatchQueue.main.async { [weak self] in
                switch basemapResults {
                case .success(let basemaps):
                    self?.basemapGalleryItems = basemaps.map { BasemapGalleryItem(basemap: $0) }
                case .failure(_):
                    self?.basemapGalleryItems = []
                case .none:
                    self?.basemapGalleryItems = []
                }
            }
        })
        return task
    }
}

extension BasemapGalleryViewModel {
}
