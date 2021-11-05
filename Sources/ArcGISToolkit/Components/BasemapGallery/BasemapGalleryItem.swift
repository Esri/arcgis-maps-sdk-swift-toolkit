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
    
    public enum SpatialReferenceStatus {
        case unknown
        case match
        case noMatch
    }
    
    /// Creates a `BasemapGalleryItem`.
    /// - Parameters:
    ///   - basemap: The `Basemap` represented by the item.
    ///   - name: The item name.
    ///   - description: The item description.
    ///   - thumbnail: The thumbnail used to represent the item.
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
    
    @Published
    public var loadBasemapsError: Error? = nil
    
    /// The basemap this `BasemapGalleryItem` represents.
    public private(set) var basemap: Basemap
    
    /// The name of this `Basemap`.
    @Published
    public private(set) var name: String = ""
    private var nameOverride: String? = nil
    
    /// The description which will be used in the gallery.
    @Published
    public private(set) var description: String? = nil
    private var descriptionOverride: String? = nil
    
    /// The thumbnail which will be displayed in the gallery.
    @Published
    public private(set) var thumbnail: UIImage? = nil
    private var thumbnailOverride: UIImage? = nil
    
    /// Denotes whether the `basemap` or it's base layers are being loaded.
    @Published
    public private(set) var isLoading = true
    
    @Published
    public private(set) var spatialReferenceStatus: SpatialReferenceStatus = .unknown
    
    /// The `SpatialReference` of `basemap`.  This will be `nil` until the basemap's
    /// baseLayers have been loaded in `updateSpatialReferenceStatus`.
    public private(set) var spatialReference: SpatialReference? = nil

    /// The currently executing async task for loading basemap.
    private var loadBasemapTask: Task<Void, Never>? = nil
}

extension BasemapGalleryItem {
    private func loadBasemap() async {
        var loadError: Error? = nil
        do {
            try await basemap.load()
            if let loadableImage = basemap.item?.thumbnail {
                try await loadableImage.load()
            }
        } catch {
            loadError = error
        }
        await update(error: loadError)
    }
    
    @MainActor
    func update(error: Error?) {
        name = nameOverride ?? basemap.name
        description = descriptionOverride ?? basemap.item?.description
        thumbnail = thumbnailOverride ??
        (basemap.item?.thumbnail?.image ?? BasemapGalleryItem.defaultThumbnail)
        
        loadBasemapsError = error
        isLoading = false
    }
    
    @MainActor
    func update(with referenceSpatialReference: SpatialReference) {
        spatialReference = basemap.baseLayers.first?.spatialReference
        spatialReferenceStatus = matches(referenceSpatialReference) ? .match : .noMatch
        isLoading = false
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

extension BasemapGalleryItem {
    public func updateSpatialReferenceStatus(
        for referenceSpatialReference: SpatialReference?
    ) async throws {
        guard let spatialReference = referenceSpatialReference,
              basemap.loadStatus == .loaded,
              self.spatialReference == nil
        else { return }
        
        isLoading = true
        await withThrowingTaskGroup(
            of: Void.self,
            returning: Void.self,
            body: { taskGroup in
                basemap.baseLayers.forEach { baseLayer in
                    taskGroup.addTask {
                        try await baseLayer.load()
                        return
                    }
                }
            }
        )
        
        await update(with: spatialReference)
    }
    
    /// Determines if the basemap spatial reference matches `spatialReference`.
    /// - Parameter spatialReference: The `SpatialReference` to match against.
    /// - Returns: `true` if the basemap spatial reference matches `spatialReference`,
    /// `false` if they don't match.
    private func matches(_ spatialReference: SpatialReference) -> Bool {
        for baselayer in basemap.baseLayers {
            if let baseLayerSR = baselayer.spatialReference,
               baseLayerSR != spatialReference {
                return false
            }
        }
        
        return true
    }
}
