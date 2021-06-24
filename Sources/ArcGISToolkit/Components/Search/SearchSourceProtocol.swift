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
import Foundation

***REMOVED***/ Defines the contract for a search result provider.
public protocol SearchSourceProtocol {
***REMOVED******REMOVED***/ Name to show when presenting this source in the UI.
***REMOVED***var displayName: String { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The maximum results to return when performing a search. Most sources default to 6.
***REMOVED***var maximumResults: Int { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The maximum suggestions to return. Most sources default to 6.
***REMOVED***var maximumSuggestions: Int { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Area to be used as a constraint for searches and suggestions.
***REMOVED***var searchArea: Geometry? { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Point to be used as an input to searches and suggestions.
***REMOVED***var preferredSearchLocation: Point? { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Gets suggestions.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - queryString: Text to be used for query.
***REMOVED******REMOVED***/   - cancellationToken: Token used for cooperative cancellation.
***REMOVED******REMOVED***/ - Returns: The array of suggestions.
***REMOVED***func suggest(_ queryString: String, cancelationToken: String) async throws -> [SearchSuggestion]
***REMOVED***
***REMOVED******REMOVED***/ Gets search results. If `area` is not `nil`, search is restricted to that area. Otherwise, the
***REMOVED******REMOVED***/ `searchArea` property may be consulted but does not need to be used as a strict limit.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - queryString: Text to be used for query.
***REMOVED******REMOVED***/   - area: Area to be used to constrain search results.
***REMOVED******REMOVED***/   - cancellationToken: Token used for cooperative cancellation.
***REMOVED******REMOVED***/ - Returns: Array of `SearchResult`s
***REMOVED***func search(_ queryString: String,
***REMOVED******REMOVED******REMOVED******REMOVED***area: Geometry?,
***REMOVED******REMOVED******REMOVED******REMOVED***cancellationToken: String?) async throws -> [SearchResult]
***REMOVED***
***REMOVED******REMOVED***/ Gets search results. If `area` is not `nil`, search is restricted to that area. Otherwise, the
***REMOVED******REMOVED***/ `searchArea` property may be consulted but does not need to be used as a strict limit.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - searchSuggestion: Suggestion to be used as basis for search.
***REMOVED******REMOVED***/   - area: Area to be used to constrain search results.
***REMOVED******REMOVED***/   - cancellationToken: Token used for cooperative cancellation.
***REMOVED******REMOVED***/ - Returns: Array of `SearchResult`s
***REMOVED***func search(_ searchSuggestion: SearchSuggestion,
***REMOVED******REMOVED******REMOVED******REMOVED***area: Geometry?,
***REMOVED******REMOVED******REMOVED******REMOVED***cancellationToken: String?) async throws -> [SearchResult]
***REMOVED***
