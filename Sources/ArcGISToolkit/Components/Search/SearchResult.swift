***REMOVED***.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import UIKit.UIImage
***REMOVED***

***REMOVED***/ Wraps a search result for display.
public class SearchResult {
***REMOVED***public init(
***REMOVED******REMOVED***displayTitle: String,
***REMOVED******REMOVED***displaySubtitle: String? = nil,
***REMOVED******REMOVED***markerImage: UIImage? = nil,
***REMOVED******REMOVED***owningSource: SearchSource,
***REMOVED******REMOVED***geoElement: GeoElement? = nil,
***REMOVED******REMOVED***selectionViewpoint: Viewpoint? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.displayTitle = displayTitle
***REMOVED******REMOVED***self.displaySubtitle = displaySubtitle
***REMOVED******REMOVED***self.markerImage = markerImage
***REMOVED******REMOVED***self.owningSource = owningSource
***REMOVED******REMOVED***self.geoElement = geoElement
***REMOVED******REMOVED***self.selectionViewpoint = selectionViewpoint
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Title that should be shown whenever a result is displayed.
***REMOVED***public var displayTitle: String
***REMOVED***
***REMOVED******REMOVED***/ Should be shown as a subtitle wherever results are shown.
***REMOVED***public var displaySubtitle: String?
***REMOVED***
***REMOVED******REMOVED***/ Image, in the native platform's format, for the result. This should be the marker that would be
***REMOVED******REMOVED***/ shown on the map, and also shown in the UI. This property is available for convenience so the
***REMOVED******REMOVED***/ UI doesn't have to worry about whether the `GeoElement` is a graphic or a feature when displaying
***REMOVED******REMOVED***/ the icon in the UI.
***REMOVED***public var markerImage: UIImage?
***REMOVED***
***REMOVED******REMOVED***/ Reference to the search source that created this result.
***REMOVED***public var owningSource: SearchSource
***REMOVED***
***REMOVED******REMOVED***/ For locator results, should be the graphic that was used to display the result on the map.
***REMOVED******REMOVED***/ For feature layer results, should be the result feature. Can be null depending on the type of the
***REMOVED******REMOVED***/ result, and can have `GeoElement`s without a defined geometry.
***REMOVED***public var geoElement: GeoElement?
***REMOVED***
***REMOVED******REMOVED***/ The viewpoint to be used when the view zooms to a selected result. This property can be `nil`
***REMOVED******REMOVED***/ because not all valid results will have a geometry. E.g. feature results from non-spatial features.
***REMOVED***public var selectionViewpoint: Viewpoint?
***REMOVED***

***REMOVED*** MARK: Extensions

extension SearchResult: Identifiable {
***REMOVED***public var id: ObjectIdentifier { ObjectIdentifier(self) ***REMOVED***
***REMOVED***

extension SearchResult: Equatable {
***REMOVED***public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
***REMOVED******REMOVED***lhs.hashValue == rhs.hashValue
***REMOVED***
***REMOVED***

extension SearchResult: Hashable {
***REMOVED******REMOVED***/ Note:  we're not hashing `geoElement.attributes` as results with the same title,
***REMOVED******REMOVED***/ subtitle, geometry, and owningSource are considered identical for searching purposes.
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(displayTitle)
***REMOVED******REMOVED***hasher.combine(displaySubtitle)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let geometry = geoElement?.geometry {
***REMOVED******REMOVED******REMOVED***hasher.combine(geometry)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let locatorSource = owningSource as? LocatorSearchSource {
***REMOVED******REMOVED******REMOVED***hasher.combine(ObjectIdentifier(locatorSource))
***REMOVED***
***REMOVED******REMOVED******REMOVED*** If you define a custom type that does NOT inherit from
***REMOVED******REMOVED******REMOVED*** `LocatorSearchSource`, you will need to add an `else if` check
***REMOVED******REMOVED******REMOVED*** for your custom type.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else if let customSearchSource = owningSource as? MyCustomSearchSource {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***hasher.combine(ObjectIdentifier(customSearchSource))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
