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
***REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***public func search(_ searchSuggestion: SearchSuggestion, area: Geometry?, cancellationToken: String?) async throws -> [SearchResult] {
***REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
