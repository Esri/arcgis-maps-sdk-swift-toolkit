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

import UIKit.UIImage
import ArcGIS

/// Wraps a search result for display.
public struct SearchResult: @unchecked Sendable {
    /// Creates a `SearchResult`.
    /// - Parameters:
    ///   - displayTitle: The string to be shown whenever a result is displayed.
    ///   - owningSource: Reference to the search source that created this result.
    ///   - displaySubtitle: The string to be shown as a subtitle wherever results are shown.
    ///   - geoElement: The graphic that was used to display the result on the map.
    ///   - markerImage: The marker that would be shown on the map for the result.
    ///   - selectionViewpoint: The viewpoint to be used when the view zooms to a selected result.
    public init(
        displayTitle: String,
        owningSource: SearchSource,
        displaySubtitle: String = "",
        geoElement: GeoElement? = nil,
        markerImage: UIImage? = nil,
        selectionViewpoint: Viewpoint? = nil
    ) {
        self.displayTitle = displayTitle
        self.owningSource = owningSource
        self.displaySubtitle = displaySubtitle
        self.geoElement = geoElement
        self.markerImage = markerImage
        self.selectionViewpoint = selectionViewpoint
    }
    
    /// The string to be shown whenever a result is displayed.
    public let displayTitle: String
    
    /// Reference to the search source that created this result.
    public let owningSource: SearchSource
    
    /// The string to be shown as a subtitle wherever results are shown.
    public let displaySubtitle: String
    
    /// For locator results, should be the graphic that was used to display the result on the map.
    /// For feature layer results, should be the resulting feature. Can be `nil` depending on the type of the
    /// result, and can have `GeoElement`s without a defined geometry.
    public let geoElement: GeoElement?
    
    /// Image, in the native platform's format, for the result. This should be the marker that would be
    /// shown on the map, and also shown in the UI. This property is available for convenience so the
    /// UI doesn't have to worry about whether the `GeoElement` is a graphic or a feature when displaying
    /// the icon in the UI.
    public let markerImage: UIImage?
    
    /// The viewpoint to be used when the view zooms to a selected result. This property can be `nil`
    /// because not all valid results will have a geometry. E.g. feature results from non-spatial features.
    public let selectionViewpoint: Viewpoint?
    
    public let id = UUID()
}

// MARK: Extensions

extension SearchResult: Identifiable {}

extension SearchResult: Equatable {
    public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
}

extension SearchResult: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension SearchResult {
    init(
        geocodeResult: GeocodeResult,
        searchSource: SearchSource
    ) {
        let subtitle = geocodeResult.attributes["LongLabel"] as? String ??
        "Match percent: \((geocodeResult.score / 100.0).formatted(.percent))"
        
        self.init(
            displayTitle: geocodeResult.label,
            owningSource: searchSource,
            displaySubtitle: subtitle,
            geoElement: Graphic(
                geometry: geocodeResult.displayLocation,
                attributes: geocodeResult.attributes
            ),
            selectionViewpoint: geocodeResult.extent.map { .init(boundingGeometry: $0) }
        )
    }
}
