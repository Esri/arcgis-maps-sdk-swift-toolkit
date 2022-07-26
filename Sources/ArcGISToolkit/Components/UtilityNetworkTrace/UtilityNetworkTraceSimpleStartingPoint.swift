***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import UIKit

***REMOVED***/ A simplified starting point of a utility network trace.
public struct UtilityNetworkTraceSimpleStartingPoint {
***REMOVED******REMOVED***/ The underlying geo element.
***REMOVED***let geoElement: GeoElement
***REMOVED***
***REMOVED******REMOVED***/ A unique identifier for the simple starting point.
***REMOVED***let id = UUID()
***REMOVED***
***REMOVED******REMOVED***/ A map point (useful for specifying a fractional starting location along an edge element).
***REMOVED***let point: Point?
***REMOVED***
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - geoElement: The underlying geo element.
***REMOVED******REMOVED***/   - point: A map point (useful for specifying a fractional starting location along an edge element).
***REMOVED***public init(
***REMOVED******REMOVED***geoElement: GeoElement,
***REMOVED******REMOVED***point: Point? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.geoElement = geoElement
***REMOVED******REMOVED***self.point = point
***REMOVED***
***REMOVED***

extension UtilityNetworkTraceSimpleStartingPoint: Equatable {
***REMOVED***public static func == (lhs: UtilityNetworkTraceSimpleStartingPoint, rhs: UtilityNetworkTraceSimpleStartingPoint) -> Bool {
***REMOVED******REMOVED***lhs.id == rhs.id
***REMOVED***
***REMOVED***
