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
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        
        if basemap.loadStatus != .loaded {
            Task { await loadBasemap() }
        }
    }
    
    /// The error generated loading the basemap, if any.
    @Published
    private(set) var loadBasemapsError: Error? = nil
    
    /// The basemap represented by `BasemapGalleryItem`.
    public let basemap: Basemap
    
    /// The name of the `basemap`.
    @Published
    public private(set) var name: String?

    /// The description of the `basemap`.
    @Published
    public private(set) var description: String?
    
    /// The thumbnail used to represent the `basemap`.
    @Published
    public private(set) var thumbnail: UIImage?
    
    /// A Boolean value indicating whether the `basemap` or it's base layers are being loaded.
    @Published
    private(set) var isBasemapLoading = true
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
    @MainActor
    func finalizeLoading(error: Error?) {
        if name == nil {
            name = basemap.name
        }
        if description == nil {
            description = basemap.item?.description
        }
        if thumbnail == nil {
            thumbnail = basemap.item?.thumbnail?.image ?? .defaultThumbnail()
        }
        
        loadBasemapsError = error
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

private extension UIImage {
    /// A default thumbnail image.
    /// - Returns: The default thumbnail.
    static func defaultThumbnail() -> UIImage {
        return UIImage(named: "basemap", in: .module, with: nil)!
    }
}
