***REMOVED***
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import UIKit.UIImage
***REMOVED***

***REMOVED***/ Wraps a search result for display.
@available(visionOS, unavailable)
public struct SearchResult: @unchecked Sendable {
***REMOVED******REMOVED***/ Creates a `SearchResult`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - displayTitle: The string to be shown whenever a result is displayed.
***REMOVED******REMOVED***/   - owningSource: Reference to the search source that created this result.
***REMOVED******REMOVED***/   - displaySubtitle: The string to be shown as a subtitle wherever results are shown.
***REMOVED******REMOVED***/   - geoElement: The graphic that was used to display the result on the map.
***REMOVED******REMOVED***/   - markerImage: The marker that would be shown on the map for the result.
***REMOVED******REMOVED***/   - selectionViewpoint: The viewpoint to be used when the view zooms to a selected result.
***REMOVED***public init(
***REMOVED******REMOVED***displayTitle: String,
***REMOVED******REMOVED***owningSource: SearchSource,
***REMOVED******REMOVED***displaySubtitle: String = "",
***REMOVED******REMOVED***geoElement: GeoElement? = nil,
***REMOVED******REMOVED***markerImage: UIImage? = nil,
***REMOVED******REMOVED***selectionViewpoint: Viewpoint? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.displayTitle = displayTitle
***REMOVED******REMOVED***self.owningSource = owningSource
***REMOVED******REMOVED***self.displaySubtitle = displaySubtitle
***REMOVED******REMOVED***self.geoElement = geoElement
***REMOVED******REMOVED***self.markerImage = markerImage
***REMOVED******REMOVED***self.selectionViewpoint = selectionViewpoint
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The string to be shown whenever a result is displayed.
***REMOVED***public let displayTitle: String
***REMOVED***
***REMOVED******REMOVED***/ Reference to the search source that created this result.
***REMOVED***public let owningSource: SearchSource
***REMOVED***
***REMOVED******REMOVED***/ The string to be shown as a subtitle wherever results are shown.
***REMOVED***public let displaySubtitle: String
***REMOVED***
***REMOVED******REMOVED***/ For locator results, should be the graphic that was used to display the result on the map.
***REMOVED******REMOVED***/ For feature layer results, should be the resulting feature. Can be `nil` depending on the type of the
***REMOVED******REMOVED***/ result, and can have `GeoElement`s without a defined geometry.
***REMOVED***public let geoElement: GeoElement?
***REMOVED***
***REMOVED******REMOVED***/ Image, in the native platform's format, for the result. This should be the marker that would be
***REMOVED******REMOVED***/ shown on the map, and also shown in the UI. This property is available for convenience so the
***REMOVED******REMOVED***/ UI doesn't have to worry about whether the `GeoElement` is a graphic or a feature when displaying
***REMOVED******REMOVED***/ the icon in the UI.
***REMOVED***public let markerImage: UIImage?
***REMOVED***
***REMOVED******REMOVED***/ The viewpoint to be used when the view zooms to a selected result. This property can be `nil`
***REMOVED******REMOVED***/ because not all valid results will have a geometry. E.g. feature results from non-spatial features.
***REMOVED***public let selectionViewpoint: Viewpoint?
***REMOVED***
***REMOVED***public let id = UUID()
***REMOVED***

***REMOVED*** MARK: Extensions

@available(visionOS, unavailable)
extension SearchResult: Identifiable {***REMOVED***

@available(visionOS, unavailable)
extension SearchResult: Equatable {
***REMOVED***public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
***REMOVED******REMOVED***lhs.id == rhs.id
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
extension SearchResult: Hashable {
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(id)
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
extension SearchResult {
***REMOVED***init(
***REMOVED******REMOVED***geocodeResult: GeocodeResult,
***REMOVED******REMOVED***searchSource: SearchSource
***REMOVED***) {
***REMOVED******REMOVED***let subtitle = geocodeResult.attributes["LongLabel"] as? String ??
***REMOVED******REMOVED***"Match percent: \((geocodeResult.score / 100.0).formatted(.percent))"
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***displayTitle: geocodeResult.label,
***REMOVED******REMOVED******REMOVED***owningSource: searchSource,
***REMOVED******REMOVED******REMOVED***displaySubtitle: subtitle,
***REMOVED******REMOVED******REMOVED***geoElement: Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry: geocodeResult.displayLocation,
***REMOVED******REMOVED******REMOVED******REMOVED***attributes: geocodeResult.attributes
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***selectionViewpoint: geocodeResult.extent.map { .init(boundingGeometry: $0) ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
