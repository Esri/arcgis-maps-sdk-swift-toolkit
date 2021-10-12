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
public struct BasemapGalleryItem {
    static var defaultThumbnail: UIImage {
        return UIImage(named: "basemap")!
    }
    
    public init(
        basemap: Basemap,
        name: String = "",
        description: String? = "",
        thumbnail: UIImage? = nil
    ) {
        self.basemap = basemap
        self.name = name.isEmpty ? basemap.name : name
        self.description = description ?? basemap.item?.description
        self.thumbnail = thumbnail ??
        (basemap.item?.thumbnail?.image ?? BasemapGalleryItem.defaultThumbnail)
    }
    
    /// The basemap this `BasemapGalleryItem` represents.
    public private(set) var basemap: Basemap
    
    /// The name of this `Basemap`.
    public private(set) var name: String
    
    /// The description which will be used in the gallery.
    public private(set) var description: String?
    
    /// The thumbnail which will be displayed in the gallery.
    public let thumbnail: UIImage?
}

extension BasemapGalleryItem: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(basemap) }
}

extension BasemapGalleryItem: Equatable {
    public static func == (lhs: BasemapGalleryItem, rhs: BasemapGalleryItem) -> Bool {
        lhs.basemap === rhs.basemap &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.thumbnail === rhs.thumbnail
    }
    
}
