// Copyright 2021 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Combine
import UIKit

///  The `BasemapGalleryItem` encompasses an element in a `BasemapGallery`.
@MainActor
@preconcurrency
public final class BasemapGalleryItem: ObservableObject, Sendable {
    /// The status of a basemap's spatial reference in relation to a reference spatial reference.
    public enum SpatialReferenceStatus: Sendable {
        /// The basemap's spatial reference status is unknown, either because the basemap's
        /// base layers haven't been loaded yet or the status has yet to be updated.
        case unknown
        /// The basemap's spatial reference matches the reference spatial reference.
        case match
        /// The basemap's spatial reference does not match the reference spatial reference.
        case noMatch
    }
    
    /// Creates a `BasemapGalleryItem`.
    /// - Parameters:
    ///   - basemap: The `Basemap` represented by the item.
    ///   - name: The item name. If `nil`, `Basemap.name` is used, if available.
    ///   - description: The item description. If `nil`, `Basemap.Item.description`
    ///   is used, if available.
    ///   - thumbnail: The thumbnail used to represent the item. If `nil`,
    ///   `Basemap.Item.thumbnail` is used, if available.
    public init(
        basemap: Basemap,
        name: String? = nil,
        description: String? = nil,
        thumbnail: UIImage? = nil
    ) {
        self.basemap = basemap
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        
        Task {
            await loadBasemap()
        }
    }
    
    /// The basemap represented by `BasemapGalleryItem`.
    public nonisolated let basemap: Basemap
    
    /// The name of the `basemap`.
    @Published public private(set) var name: String?
    
    /// The description of the `basemap`.
    @Published public private(set) var description: String?
    
    /// A Boolean value indicating whether the basemap supports 3D visualization.
    @Published public private(set) var is3D: Bool = false
    
    /// The thumbnail used to represent the `basemap`.
    @Published public private(set) var thumbnail: UIImage?

    /// The spatial reference status of the item. This is set via a call to
    /// ``updateSpatialReferenceStatus(_:)``.
    @Published public private(set) var spatialReferenceStatus: SpatialReferenceStatus = .unknown
    
    /// A Boolean value indicating whether the `basemap` or it's base layers are being loaded.
    @Published private(set) var isBasemapLoading = true

    /// The error generated loading the basemap, if any.
    @Published private(set) var loadBasemapError: Error? = nil

    /// The spatial reference of ``basemap``. This will be `nil` until the
    /// basemap's base layers have been loaded by
    /// ``updateSpatialReferenceStatus(_:)``.
    public private(set) var spatialReference: SpatialReference? = nil
}

private extension BasemapGalleryItem {
    /// Loads the basemap and the item's thumbnail, if available.
    func loadBasemap() async {
        // A loaded and cloned basemap set on SceneView from within a sheet does
        // not draw correctly. To workaround this, we clone and load the basemap
        // here, get the information needed for display and then discard the
        // loaded copy. When a gallery selection is made, we have an
        // unloaded instance of the basemap to set on the geo model.
        // See Also: https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/issues/1126
        let basemap = basemap.clone()
        
        do {
            try await basemap.load()
            if let loadableImage = basemap.item?.thumbnail {
                try await loadableImage.load()
            }
        } catch  {
            loadBasemapError = error
        }
        
        if name == nil {
            name = basemap.name
        }
        if description == nil {
            description = basemap.item?.description
        }
        if thumbnail == nil {
            thumbnail = basemap.item?.thumbnail?.image ?? .defaultThumbnail()
        }
        
        is3D = basemap.baseLayers.contains(where: { $0 is ArcGISSceneLayer })
        
        isBasemapLoading = false
    }
}

extension BasemapGalleryItem: Identifiable {}

extension BasemapGalleryItem: Equatable {
    public static nonisolated func == (lhs: BasemapGalleryItem, rhs: BasemapGalleryItem) -> Bool {
        return lhs.basemap === rhs.basemap
    }
}

public extension BasemapGalleryItem {
    /// Updates the ``spatialReferenceStatus-swift.property`` by loading the first base layer of
    /// ``basemap`` and determining if it matches with the given spatial reference.
    /// - Parameter referenceSpatialReference: The spatial reference to match to.
    @MainActor func updateSpatialReferenceStatus(
        _ referenceSpatialReference: SpatialReference?
    ) async throws {
        guard basemap.loadStatus == .loaded else { return }
        
        if spatialReference == nil {
            isBasemapLoading = true
            try await basemap.baseLayers.first?.load()
        }
        
        finalizeUpdateSpatialReferenceStatus(
            with: referenceSpatialReference
        )
    }
    
    /// Updates the item's ``spatialReference`` and ``spatialReferenceStatus-swift.property`` properties.
    /// - Parameter referenceSpatialReference: The spatial reference used to
    /// compare to `basemap`'s spatial reference, represented by the first base layer's
    /// spatial reference.
    @MainActor private func finalizeUpdateSpatialReferenceStatus(
        with referenceSpatialReference: SpatialReference?
    ) {
        spatialReference = basemap.baseLayers.first?.spatialReference
        
        if referenceSpatialReference == nil {
            spatialReferenceStatus = .unknown
        } else if spatialReference == referenceSpatialReference {
            spatialReferenceStatus = .match
        } else {
            spatialReferenceStatus = .noMatch
        }
        
        isBasemapLoading = false
    }
}

private extension UIImage {
    /// A default thumbnail image.
    /// - Returns: The default thumbnail.
    static func defaultThumbnail() -> UIImage {
        return UIImage(named: "defaultthumbnail", in: .toolkitModule, with: nil)!
    }
}
