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

***REMOVED***

***REMOVED***/ Defines the contract for a search result provider.
@MainActor
@preconcurrency
@available(visionOS, unavailable)
public protocol SearchSource {
***REMOVED******REMOVED***/ Name to show when presenting this source in the UI.
***REMOVED***var name: String { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The maximum results to return when performing a search. Most sources default to `6`.
***REMOVED***var maximumResults: Int { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The maximum suggestions to return. Most sources default to `6`.
***REMOVED***var maximumSuggestions: Int { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns the search suggestions for the specified query.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - query: The query for which to provide search suggestions.
***REMOVED******REMOVED***/   - searchArea: The area used to limit results.
***REMOVED******REMOVED***/   - preferredSearchLocation: The location used as a starting point for searches.
***REMOVED******REMOVED***/ - Returns: An array of search suggestions.
***REMOVED***func suggest(
***REMOVED******REMOVED***_ query: String,
***REMOVED******REMOVED***searchArea: Geometry?,
***REMOVED******REMOVED***preferredSearchLocation: Point?
***REMOVED***) async throws -> [SearchSuggestion]
***REMOVED***
***REMOVED******REMOVED***/ Gets search results.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - query: Text to be used for query.
***REMOVED******REMOVED***/   - searchArea: The area used to limit results.
***REMOVED******REMOVED***/   - preferredSearchLocation: The location used as a starting point for searches.
***REMOVED******REMOVED***/ - Returns: An array of search results.
***REMOVED***func search(
***REMOVED******REMOVED***_ query: String,
***REMOVED******REMOVED***searchArea: Geometry?,
***REMOVED******REMOVED***preferredSearchLocation: Point?
***REMOVED***) async throws -> [SearchResult]
***REMOVED***
***REMOVED******REMOVED***/ Returns the search results for the specified search suggestion.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - searchSuggestion: The search suggestion for which to provide search results.
***REMOVED******REMOVED***/   - searchArea: The area used to limit results.
***REMOVED******REMOVED***/   - preferredSearchLocation: The location used as a starting point for searches.
***REMOVED******REMOVED***/ - Returns: An array of search results.
***REMOVED***func search(
***REMOVED******REMOVED***_ searchSuggestion: SearchSuggestion,
***REMOVED******REMOVED***searchArea: Geometry?,
***REMOVED******REMOVED***preferredSearchLocation: Point?
***REMOVED***) async throws -> [SearchResult]
***REMOVED***
***REMOVED******REMOVED***/ Repeats the last search.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - query: Text to be used for query.
***REMOVED******REMOVED***/   - searchExtent: Extent used to limit the results.
***REMOVED******REMOVED***/ - Returns: An array of search results.
***REMOVED***func repeatSearch(
***REMOVED******REMOVED***_ query: String,
***REMOVED******REMOVED***searchExtent: Envelope
***REMOVED***) async throws -> [SearchResult]
***REMOVED***
