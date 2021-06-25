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

import Foundation
***REMOVED***

***REMOVED***/ Uses a Locator to provide search and suggest results. Most configuration should be done on the
***REMOVED***/ `GeocodeParameters` directly.
public class LocatorSearchSource {
***REMOVED***public init(locator: LocatorTask = LocatorTask(url: URL(string: "https:***REMOVED***geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!),
***REMOVED******REMOVED******REMOVED******REMOVED***geocodeParameters: GeocodeParameters = GeocodeParameters(),
***REMOVED******REMOVED******REMOVED******REMOVED***suggestParameters: SuggestParameters = SuggestParameters(),
***REMOVED******REMOVED******REMOVED******REMOVED***displayName: String = "Search",
***REMOVED******REMOVED******REMOVED******REMOVED***maximumResults: Int = 6,
***REMOVED******REMOVED******REMOVED******REMOVED***maximumSuggestions: Int = 6,
***REMOVED******REMOVED******REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***preferredSearchLocation: Point? = nil) {
***REMOVED******REMOVED***self.locator = locator
***REMOVED******REMOVED***self.geocodeParameters = geocodeParameters
***REMOVED******REMOVED***self.suggestParameters = suggestParameters
***REMOVED******REMOVED***self.displayName = displayName
***REMOVED******REMOVED***self.maximumResults = maximumResults
***REMOVED******REMOVED***self.maximumSuggestions = maximumSuggestions
***REMOVED******REMOVED***self.searchArea = searchArea
***REMOVED******REMOVED***self.preferredSearchLocation = preferredSearchLocation
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The locator used by this search source.
***REMOVED***var locator: LocatorTask = LocatorTask(url: URL(string: "https:***REMOVED***geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for geocoding. Some properties on parameters will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***var geocodeParameters: GeocodeParameters = GeocodeParameters()
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for getting suggestions. Some properties will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***var suggestParameters: SuggestParameters = SuggestParameters()
***REMOVED***
***REMOVED***public var displayName: String = "Search"
***REMOVED***
***REMOVED***public var maximumResults: Int = 6
***REMOVED***
***REMOVED***public var maximumSuggestions: Int = 6
***REMOVED***
***REMOVED***public var searchArea: Geometry?
***REMOVED***
***REMOVED***public var preferredSearchLocation: Point?
***REMOVED***

extension LocatorSearchSource: SearchSourceProtocol {
***REMOVED***public func suggest(_ queryString: String, cancelationToken: String) async throws -> [SearchSuggestion] {
***REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***public func search(_ queryString: String, area: Geometry?, cancellationToken: String?) async throws -> [SearchResult] {
***REMOVED******REMOVED***let geocodeResults =  try await locator.geocode(searchText: queryString)
***REMOVED******REMOVED******REMOVED***convert to search results
***REMOVED******REMOVED***return geocodeResults.map{ $0.toSearchResult(searchSource: self) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func search(_ searchSuggestion: SearchSuggestion, area: Geometry?, cancellationToken: String?) async throws -> [SearchResult] {
***REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED*** TODO: add locator name from Locator.locatorInfo.name (can't do it here because search source is no LocatorSearchSource, but maybe could subclass toSearchResult....
***REMOVED*** TODO: following Nathan's lead on all this stuff, i.e., go through his code and duplicate it as I go.
***REMOVED*** TODO: Should move this to the Extensions folder in it's own file (along with Identifieable compliance).
extension GeocodeResult {
***REMOVED***func toSearchResult(searchSource: SearchSourceProtocol) -> SearchResult {
***REMOVED******REMOVED***return SearchResult(displayTitle: self.label,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***displaySubtitle: "Score: \((self.score).formatted(.percent))",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***markerImage: nil,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***owningSource: searchSource,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoElement: nil,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectionViewpoint: nil)
***REMOVED***
***REMOVED***
