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

import Foundation

///  The `BasemapGalleryItem` encompasses an element in a `BasemapGallery`.
public class BasemapGalleryItem: ObservableObject {
    static var defaultThumbnail: UIImage {
        return UIImage(named: "DefaultBasemap")!
    }
    
    public init(
        basemap: Basemap,
        name: String? = nil,
        description: String? = nil,
        thumbnail: UIImage? = nil
    ) {
        self.basemap = basemap
        self.nameOverride = name
        self.name = name ?? ""
        self.descriptionOverride = description
        self.description = description
        self.thumbnailOverride = thumbnail
        self.thumbnail = thumbnail
        
        loadBasemapTask = Task { await loadBasemap() }
    }
    
//    deinit {
//        loadBasemapTask.cancel()
//        fetchBasemapTask.cancel()
//    }
    
    @Published
    public var loadBasemapsError: Error? = nil

    /// The basemap this `BasemapGalleryItem` represents.
    public private(set) var basemap: Basemap

    private var nameOverride: String? = nil
    /// The name of this `Basemap`.
    @Published
    public private(set) var name: String = ""

    private var descriptionOverride: String? = nil
    /// The description which will be used in the gallery.
    @Published
    public private(set) var description: String? = nil

    private var thumbnailOverride: UIImage? = nil
    /// The thumbnail which will be displayed in the gallery.
    @Published
    public private(set) var thumbnail: UIImage? = nil
    
    public private(set) var spatialReference: SpatialReference? = nil
    
    @Published
    public private(set) var isLoaded = false

    /// The currently executing async task for loading basemap.
    private var loadBasemapTask: Task<Void, Never>? = nil
}

extension BasemapGalleryItem {
    private func loadBasemap() async {
        do {
            print("pre-basemap.load()")
            try await basemap.load()
            print("basemap loaded!")
            if let loadableImage = basemap.item?.thumbnail {
                try await loadableImage.load()
            }
            
            //TODO: use the item.spatialreferenceName to create a spatial reference instead of always loading the first base layer.
            // Determine the spatial reference of the basemap
//            if let item = basemap.item as? PortalItem {
//                try await item.load()
//            }

            print("sr = \(basemap.item?.spatialReferenceName ?? "no name"); item: \(String(describing: (basemap.item as? PortalItem)?.loadStatus))")
            if let layer = basemap.baseLayers.first {
                try await layer.load()
                spatialReference = layer.spatialReference
            }
            
            //TODO:  Add sr checking and setting of sr to bmgi (isValid???); and what to do with errors...
            
            await update()
        } catch {
            loadBasemapsError = error
        }
    }
    
    @MainActor
    func update() {
        self.name = nameOverride ?? basemap.name
        self.description = descriptionOverride ?? basemap.item?.description
        self.thumbnail = thumbnailOverride ??
        (basemap.item?.thumbnail?.image ?? BasemapGalleryItem.defaultThumbnail)
        
        isLoaded = true
    }
    
    /// Returns whether the basemap gallery item is valid and ok to use.
    /// - Parameter item: item to match spatial references with.
    /// - Returns: true if the item is loaded and either `item`'s spatial reference is nil
    /// or matches `spatialReference`.
    public func isValid(for otherSpatialReference: SpatialReference?) -> Bool {
        print("name: \(name); isLoaded = \(isLoaded); loadStatus = \(basemap.loadStatus)")
        guard isLoaded else { return false }
        return otherSpatialReference == nil || otherSpatialReference == spatialReference
//        return true
    }
}

extension BasemapGalleryItem: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}

extension BasemapGalleryItem: Equatable {
    public static func == (lhs: BasemapGalleryItem, rhs: BasemapGalleryItem) -> Bool {
        lhs.basemap === rhs.basemap &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.thumbnail === rhs.thumbnail
    }

}
