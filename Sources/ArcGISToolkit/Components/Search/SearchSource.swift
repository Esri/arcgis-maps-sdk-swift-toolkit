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

***REMOVED***/ Defines the contract for a search result provider.
public protocol SearchSource {
***REMOVED******REMOVED***/ Name to show when presenting this source in the UI.
***REMOVED***var name: String { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The maximum results to return when performing a search. Most sources default to 6.
***REMOVED***var maximumResults: Int32 { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The maximum suggestions to return. Most sources default to 6.
***REMOVED***var maximumSuggestions: Int32 { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The area to be used as a constraint for searches and suggestions.
***REMOVED***var searchArea: Geometry? { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The point to be used as an input to searches and suggestions.
***REMOVED***var preferredSearchLocation: Point? { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns the search suggestions for the specified query.
***REMOVED******REMOVED***/ - Parameter queryString: The query for which to provide search suggestions.
***REMOVED******REMOVED***/ - Returns: An array of search suggestions.
***REMOVED***func suggest(_ queryString: String) async throws -> [SearchSuggestion]
***REMOVED***
***REMOVED******REMOVED***/ Gets search results.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - queryString: Text to be used for query.
***REMOVED******REMOVED***/ - Returns: Array of `SearchResult`s
***REMOVED***func search(_ queryString: String) async throws -> [SearchResult]
***REMOVED***
***REMOVED******REMOVED***/ Returns the search results for the specified search suggestion.
***REMOVED******REMOVED***/ - Parameter searchSuggestion: The search suggestion for which to provide
***REMOVED******REMOVED***/ search results.
***REMOVED******REMOVED***/ - Returns: An array of search results.
***REMOVED***func search(
***REMOVED******REMOVED***_ searchSuggestion: SearchSuggestion
***REMOVED***) async throws -> [SearchResult]
***REMOVED***
***REMOVED******REMOVED***/ Repeats the last search.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - queryString: Text to be used for query.
***REMOVED******REMOVED***/   - queryExtent: Extent used to limit the results.
***REMOVED******REMOVED***/ - Returns: Array of `SearchResult`s
***REMOVED***func repeatSearch(_ queryString: String, queryExtent: Envelope) async throws -> [SearchResult]
***REMOVED***
