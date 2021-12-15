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
    /// Creates a `BasemapGalleryItem`.
    /// - Parameters:
    ///   - basemap: The `Basemap` represented by the item.
    ///   - name: The item name. If `nil`, `Basemap.name` is used, if available..
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
        self.nameOverride = name
        self.name = name ?? ""
        self.descriptionOverride = description
        self.description = description
        self.thumbnailOverride = thumbnail
        self.thumbnail = thumbnail
        
        Task { await loadBasemap() }
    }
    
    /// The error generated loading the basemap, if any.
    @Published
    public private(set) var loadBasemapsError: RuntimeError? = nil
    
    /// The basemap represented by `BasemapGalleryItem`.
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
    
    /// The `SpatialReference` of `basemap`.
    public private(set) var spatialReference: SpatialReference? = nil
}

private extension BasemapGalleryItem {
    /// Loads the basemap and the item's thumbnail, if available.
    func loadBasemap() async {
        var loadError: RuntimeError? = nil
        do {
            try await basemap.load()
            if let loadableImage = basemap.item?.thumbnail {
                try await loadableImage.load()
            }
        } catch  {
            loadError = error as? RuntimeError
        }
        await finalizeLoading(error: loadError)
    }
    
    /// Updates the item in response to basemap loading completion.
    /// - Parameter error: The basemap load error, if any.
    @MainActor
    func finalizeLoading(error: RuntimeError?) {
        name = nameOverride ?? basemap.name
        description = descriptionOverride ?? basemap.item?.description
        thumbnail = thumbnailOverride ??
        (basemap.item?.thumbnail?.image ?? UIImage.defaultThumbnail())
        
        loadBasemapsError = error
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

private extension UIImage {
    /// A default thumbnail image.
    /// - Returns: The default thumbnail.
    static func defaultThumbnail() -> UIImage {
        return UIImage(named: "DefaultBasemap", in: Bundle.module, with: nil)!
    }
}
