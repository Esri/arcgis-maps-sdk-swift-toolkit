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
***REMOVED***

***REMOVED***/ Extends `LocatorSearchSource` with intelligent search behaviors; adds support for features like
***REMOVED***/ type-specific placemarks, repeated search, and more on the world geocode service.
public class SmartLocatorSearchSource: LocatorSearchSource, @unchecked Sendable {
***REMOVED******REMOVED***/ Creates a smart locator search source.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - name: Name to show when presenting this source in the UI.
***REMOVED******REMOVED***/   - maximumResults: The maximum results to return when performing a search. Most sources default to `6`.
***REMOVED******REMOVED***/   - maximumSuggestions: The maximum suggestions to return. Most sources default to `6`.
***REMOVED******REMOVED***/   - repeatSearchResultThreshold: The minimum number of search results to attempt to return.
***REMOVED******REMOVED***/   - repeatSuggestResultThreshold: The minimum number of suggestions to attempt to return.
***REMOVED***public init(
***REMOVED******REMOVED***name: String = "Smart Locator",
***REMOVED******REMOVED***maximumResults: Int = 6,
***REMOVED******REMOVED***maximumSuggestions: Int = 6,
***REMOVED******REMOVED***repeatSearchResultThreshold: Int? = 1,
***REMOVED******REMOVED***repeatSuggestResultThreshold: Int? = 6
***REMOVED***) {
***REMOVED******REMOVED***super.init(
***REMOVED******REMOVED******REMOVED***name: name,
***REMOVED******REMOVED******REMOVED***locatorTask: LocatorTask(
***REMOVED******REMOVED******REMOVED******REMOVED***url: URL(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***string: "https:***REMOVED***geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***maximumResults: maximumResults,
***REMOVED******REMOVED******REMOVED***maximumSuggestions: maximumSuggestions
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.repeatSearchResultThreshold = repeatSearchResultThreshold
***REMOVED******REMOVED***self.repeatSuggestResultThreshold = repeatSuggestResultThreshold
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The minimum number of results to attempt to return. If there are too few results, the search is
***REMOVED******REMOVED***/ repeated with loosened parameters until enough results are accumulated. If no search is
***REMOVED******REMOVED***/ successful, it is still possible to have a total number of results less than this threshold. Does not
***REMOVED******REMOVED***/ apply to repeated search with area constraint. Set to `nil` to disable search repeat behavior.
***REMOVED***public var repeatSearchResultThreshold: Int? = 1
***REMOVED***
***REMOVED******REMOVED***/ The minimum number of suggestions to attempt to return. If there are too few suggestions,
***REMOVED******REMOVED***/ request is repeated with loosened constraints until enough suggestions are accumulated.
***REMOVED******REMOVED***/ If no search is successful, it is still possible to have a total number of results less than this
***REMOVED******REMOVED***/ threshold. Does not apply to repeated search with area constraint. Set to `nil` to disable search
***REMOVED******REMOVED***/ repeat behavior.
***REMOVED***public var repeatSuggestResultThreshold: Int? = 6
***REMOVED***
***REMOVED***public override func search(
***REMOVED******REMOVED***_ query: String,
***REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED***preferredSearchLocation: Point? = nil
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED******REMOVED*** First, perform super class search.
***REMOVED******REMOVED***var results = try await super.search(
***REMOVED******REMOVED******REMOVED***query,
***REMOVED******REMOVED******REMOVED***searchArea: searchArea,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: preferredSearchLocation
***REMOVED******REMOVED***)
***REMOVED******REMOVED***if repeatSearchResultThreshold == nil ||
***REMOVED******REMOVED******REMOVED***results.count > repeatSearchResultThreshold! ||
***REMOVED******REMOVED******REMOVED***geocodeParameters.searchArea == nil {
***REMOVED******REMOVED******REMOVED******REMOVED*** Result count meets threshold or there were no geographic
***REMOVED******REMOVED******REMOVED******REMOVED*** constraints on the search, so return results.
***REMOVED******REMOVED******REMOVED***return results
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Remove geographic constraints and re-run search.
***REMOVED******REMOVED***geocodeParameters.searchArea = nil
***REMOVED******REMOVED***let geocodeResults = try await locatorTask.geocode(
***REMOVED******REMOVED******REMOVED***forSearchText: query,
***REMOVED******REMOVED******REMOVED***using: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Union results and return.
***REMOVED******REMOVED***let searchResults = geocodeResults.map {
***REMOVED******REMOVED******REMOVED***SearchResult(geocodeResult: $0, searchSource: self)
***REMOVED***
***REMOVED******REMOVED***results.append(contentsOf: searchResults)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Limit results to `maximumResults`.
***REMOVED******REMOVED***return Array(results.prefix(Int(maximumResults)))
***REMOVED***
***REMOVED***
***REMOVED***public override func search(
***REMOVED******REMOVED***_ searchSuggestion: SearchSuggestion,
***REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED***preferredSearchLocation: Point? = nil
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED***guard let suggestResult = searchSuggestion.suggestResult
***REMOVED******REMOVED***else { return [] ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await super.search(
***REMOVED******REMOVED******REMOVED***searchSuggestion,
***REMOVED******REMOVED******REMOVED***searchArea: searchArea,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: preferredSearchLocation
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if repeatSearchResultThreshold == nil ||
***REMOVED******REMOVED******REMOVED***results.count > repeatSearchResultThreshold! ||
***REMOVED******REMOVED******REMOVED***geocodeParameters.searchArea == nil {
***REMOVED******REMOVED******REMOVED******REMOVED*** Result count meets threshold or there were no geographic
***REMOVED******REMOVED******REMOVED******REMOVED*** constraints on the search, so return results.
***REMOVED******REMOVED******REMOVED***return results
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Remove geographic constraints and re-run search.
***REMOVED******REMOVED***geocodeParameters.searchArea = nil
***REMOVED******REMOVED***let geocodeResults = try await locatorTask.geocode(
***REMOVED******REMOVED******REMOVED***forSuggestResult: suggestResult,
***REMOVED******REMOVED******REMOVED***using: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Union results and return.
***REMOVED******REMOVED***let searchResults = geocodeResults.map {
***REMOVED******REMOVED******REMOVED***SearchResult(geocodeResult: $0, searchSource: self)
***REMOVED***
***REMOVED******REMOVED***results.append(contentsOf: searchResults)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Limit results to `maximumResults`.
***REMOVED******REMOVED***return Array(results.prefix(Int(maximumResults)))
***REMOVED***
***REMOVED***
***REMOVED***public override func suggest(
***REMOVED******REMOVED***_ query: String,
***REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED***preferredSearchLocation: Point? = nil
***REMOVED***) async throws -> [SearchSuggestion] {
***REMOVED******REMOVED***var results = try await super.suggest(
***REMOVED******REMOVED******REMOVED***query,
***REMOVED******REMOVED******REMOVED***searchArea: searchArea,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: preferredSearchLocation
***REMOVED******REMOVED***)
***REMOVED******REMOVED***if repeatSuggestResultThreshold == nil ||
***REMOVED******REMOVED******REMOVED***results.count > repeatSuggestResultThreshold! ||
***REMOVED******REMOVED******REMOVED***suggestParameters.searchArea == nil {
***REMOVED******REMOVED******REMOVED******REMOVED*** Result count meets threshold or there were no geographic
***REMOVED******REMOVED******REMOVED******REMOVED*** constraints on the search, so return results.
***REMOVED******REMOVED******REMOVED***return results
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Remove geographic constraints and re-run search.
***REMOVED******REMOVED***suggestParameters.searchArea = nil
***REMOVED******REMOVED***let geocodeResults =  try await locatorTask.suggest(
***REMOVED******REMOVED******REMOVED***forSearchText: query,
***REMOVED******REMOVED******REMOVED***parameters: suggestParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Union results and return.
***REMOVED******REMOVED***let suggestResults = geocodeResults.map {
***REMOVED******REMOVED******REMOVED***SearchSuggestion(suggestResult: $0, searchSource: self)
***REMOVED***
***REMOVED******REMOVED***results.append(contentsOf: suggestResults)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Limit results to `maximumSuggestions`.
***REMOVED******REMOVED***return Array(results.prefix(Int(maximumSuggestions)))
***REMOVED***
***REMOVED***
