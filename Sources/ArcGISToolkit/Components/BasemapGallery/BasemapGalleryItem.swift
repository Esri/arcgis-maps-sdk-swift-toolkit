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
    /// Indicates the status of the basemap's spatial reference in relation to a reference spatial reference.
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
    ///   - name: The item name.  If `nil`, `Basemap.name` is used, if available..
    ///   - description: The item description.  If `nil`, `Basemap.Item.description`
    ///   is used, if available.
    ///   - thumbnail: The thumbnail used to represent the item.  If `nil`,
    ///   `Basemap.Item.thumbnail` is used, if available.
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
    
    /// The error generated loading the basemap, if any.
    @Published
    public var loadBasemapsError: Error? = nil
    
    /// The basemap this `BasemapGalleryItem` represents.
    public private(set) var basemap: Basemap
    
    /// The name of the `basemap`.
    @Published
    public private(set) var name: String = ""
    private var nameOverride: String? = nil
    
    /// The description of the `basemap`.
    @Published
    public private(set) var description: String? = nil
    private var descriptionOverride: String? = nil
    
    /// The thumbnail used to represent the `basemap`.
    @Published
    public private(set) var thumbnail: UIImage? = nil
    private var thumbnailOverride: UIImage? = nil
    
    /// Denotes whether the `basemap` or it's base layers are being loaded.
    @Published
    public private(set) var isLoading = true
    
    /// The `SpatialReferenceStatus` of the item.  This is set via a call to
    /// `updateSpatialReferenceStatus(for:)`
    @Published
    public private(set) var spatialReferenceStatus: SpatialReferenceStatus = .unknown
    
    /// The `SpatialReference` of `basemap`.  This will be `nil` until the basemap's
    /// baseLayers have been loaded in `updateSpatialReferenceStatus(for:)`.
    public private(set) var spatialReference: SpatialReference? = nil
    
    /// The currently executing `Task` for loading the basemap.
    private var loadBasemapTask: Task<Void, Never>? = nil
}

private extension BasemapGalleryItem {
    func loadBasemap() async {
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
    /// Updates the item in response to basemap loading completion.
    /// - Parameter error: The basemap load error, if any.
    func update(error: Error?) {
        name = nameOverride ?? basemap.name
        description = descriptionOverride ?? basemap.item?.description
        thumbnail = thumbnailOverride ??
        (basemap.item?.thumbnail?.image ?? UIImage.defaultThumbnail())
        
        loadBasemapsError = error
        isLoading = false
    }
    
    @MainActor
    /// Updates the item's `spatialReference` and `spatialReferenceStatus` properties.
    /// - Parameter referenceSpatialReference: The `SpatialReference` used to
    /// compare to the `basemap`'s `SpatialReference`, represented by the first base layer's`
    /// `SpatialReference`.
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
    /// Loads the first base layer of `basemap` and determines if it matches
    /// `referenceSpatialReference`, setting the `spatialReferenceStatus`
    /// property appropriately.
    /// - Parameter referenceSpatialReference: The `SpatialReference to match to`.
    public func updateSpatialReferenceStatus(
        for referenceSpatialReference: SpatialReference?
    ) async throws {
        guard let spatialReference = referenceSpatialReference,
              basemap.loadStatus == .loaded,
              self.spatialReference == nil
        else { return }
        
        isLoading = true
        try await basemap.baseLayers.first?.load()
        
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

private extension UIImage {
    /// A search result marker symbol.
    static func defaultThumbnail() -> UIImage {
        return UIImage(named: "DefaultBasemap")!
    }
}
