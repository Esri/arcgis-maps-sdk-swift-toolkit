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

import UIKit.UIImage
import ArcGIS

/// Wraps a search result for display.
public class SearchResult {
    public init(displayTitle: String,
                displaySubtitle: String? = nil,
                markerImage: UIImage? = nil,
                owningSource: SearchSourceProtocol,
                geoElement: GeoElement? = nil,
                selectionViewpoint: Viewpoint? = nil) {
        self.displayTitle = displayTitle
        self.displaySubtitle = displaySubtitle
        self.markerImage = markerImage
        self.owningSource = owningSource
        self.geoElement = geoElement
        self.selectionViewpoint = selectionViewpoint
    }
    
    /// Title that should be shown whenever a result is displayed.
    public var displayTitle: String
    
    /// Should be shown as a subtitle wherever results are shown.
    public var displaySubtitle: String?
    
    /// Image, in the native platform's format, for the result. This should be the marker that would be
    /// shown on the map, and also shown in the UI. This property is available for convenience so the
    /// UI doesn't have to worry about whether the `GeoElement` is a graphic or a feature when displaying
    /// the icon in the UI.
    public var markerImage: UIImage?
    
    /// Reference to the search source that created this result.
    public var owningSource: SearchSourceProtocol
    
    /// For locator results, should be the graphic that was used to display the result on the map.
    /// For feature layer results, should be the result feature. Can be null depending on the type of the
    /// result, and can have `GeoElement`s without a defined geometry.
    public var geoElement: GeoElement?
    
    /// The viewpoint to be used when the view zooms to a selected result. This property can be `nil`
    /// because not all valid results will have a geometry. E.g. feature results from non-spatial features.
    public var selectionViewpoint: Viewpoint?
}

// MARK: Extensions

extension SearchResult: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}

extension SearchResult: Equatable {
    public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs === rhs
    }
}

extension SearchResult: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(displayTitle)
        hasher.combine(displaySubtitle)
        if let geometry = geoElement?.geometry {
            hasher.combine(geometry)
        }
    }
}
