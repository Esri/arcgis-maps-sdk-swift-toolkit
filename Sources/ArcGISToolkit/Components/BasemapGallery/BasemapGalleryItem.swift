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

public struct BasemapGalleryItem {
    public init(
        basemap: Basemap,
        name: String = "",
        description: String? = "",
        thumbnail: UIImage? = nil
    ) {
        self.basemap = basemap
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
    }
    
    var basemap: Basemap
    var name: String
    var description: String?
    var thumbnail: UIImage?
}

//extension DisplayableBasemap: Identifiable {
//    public var id: ObjectIdentifier { ObjectIdentifier(self) }
//}
