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

import Foundation
import UIKit.UIImage
import ArcGIS

///  The `BasemapGalleryItem` encompasses an element in a `BasemapGallery`.
public class BasemapGalleryItem: ObservableObject {
    /// The status of a basemap's spatial reference in relation to a reference spatial reference.
    public enum SpatialReferenceStatus {
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
            if basemap.loadStatus != .loaded {
                await loadBasemap()
            } else {
                await finalizeLoading()
            }
        }
    }
    
    /// The basemap represented by `BasemapGalleryItem`.
    public let basemap: Basemap
    
    /// The name of the `basemap`.
    @Published public private(set) var name: String?
    
    /// The description of the `basemap`.
    @Published public private(set) var description: String?
    
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
        var loadError: Error? = nil
        do {
            try await basemap.load()
            if let loadableImage = basemap.item?.thumbnail {
                try await loadableImage.load()
            }
        } catch  {
            loadError = error
        }
        await finalizeLoading(error: loadError)
    }
    
    /// Updates the item in response to basemap loading completion.
    /// - Parameter error: The basemap load error, if any.
    @MainActor func finalizeLoading(error: Error? = nil) {
        if name == nil {
            name = basemap.name
        }
        if description == nil {
            description = basemap.item?.description
        }
        if thumbnail == nil {
            thumbnail = basemap.item?.thumbnail?.image ?? .defaultThumbnail()
        }
        
        loadBasemapError = error
        isBasemapLoading = false
    }
}

extension BasemapGalleryItem: Identifiable {}

extension BasemapGalleryItem: Equatable {
    public static func == (lhs: BasemapGalleryItem, rhs: BasemapGalleryItem) -> Bool {
        lhs.basemap === rhs.basemap &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.thumbnail === rhs.thumbnail
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
        return UIImage(named: "defaultthumbnail", in: .module, with: nil)!
    }
}
