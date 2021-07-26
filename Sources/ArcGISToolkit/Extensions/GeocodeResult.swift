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

***REMOVED***

extension GeocodeResult {
***REMOVED***func toSearchResult(searchSource: SearchSourceProtocol) -> SearchResult {
***REMOVED******REMOVED***let subtitle = self.attributes["LongLabel"] as? String ??
***REMOVED******REMOVED***"Match percent: \((self.score / 100.0).formatted(.percent))"
***REMOVED******REMOVED***var viewpoint: Viewpoint? = nil
***REMOVED******REMOVED***if let extent = self.extent {
***REMOVED******REMOVED******REMOVED***viewpoint = Viewpoint(targetExtent: extent)
***REMOVED***
***REMOVED******REMOVED***return SearchResult(
***REMOVED******REMOVED******REMOVED***displayTitle: self.label,
***REMOVED******REMOVED******REMOVED***displaySubtitle: subtitle,
***REMOVED******REMOVED******REMOVED***markerImage: nil,
***REMOVED******REMOVED******REMOVED***owningSource: searchSource,
***REMOVED******REMOVED******REMOVED***geoElement: Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry: self.displayLocation,
***REMOVED******REMOVED******REMOVED******REMOVED***attributes: self.attributes
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***selectionViewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension GeocodeResult: Identifiable {
***REMOVED***public var id: ObjectIdentifier { ObjectIdentifier(self) ***REMOVED***
***REMOVED***
