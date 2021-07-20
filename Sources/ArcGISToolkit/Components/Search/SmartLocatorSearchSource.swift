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
***REMOVED***

***REMOVED***/ Extends `LocatorSearchSource` with intelligent search behaviors; adds support for features like
***REMOVED***/ type-specific placemarks, repeated search, and more. Advanced functionality requires knowledge of the
***REMOVED***/ underlying locator to be used well; this class implements behaviors that make assumptions about the
***REMOVED***/ locator being the world geocode service.
public class SmartLocatorSearchSource: LocatorSearchSource {
***REMOVED***public convenience init(
***REMOVED******REMOVED***displayName: String = "Search",
***REMOVED******REMOVED***maximumResults: Int = 6,
***REMOVED******REMOVED***maximumSuggestions: Int,
***REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED***preferredSearchLocation: Point? = nil,
***REMOVED******REMOVED***repeatSearchResultThreshold: Int = 1,
***REMOVED******REMOVED***repeatSuggestResultThreshold: Int = 6,
***REMOVED******REMOVED***resultSymbolStyle: SymbolStyle? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.init()
***REMOVED******REMOVED***self.displayName = displayName
***REMOVED******REMOVED***self.maximumResults = maximumResults
***REMOVED******REMOVED***self.maximumSuggestions = maximumSuggestions
***REMOVED******REMOVED***self.searchArea = searchArea
***REMOVED******REMOVED***self.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***self.repeatSearchResultThreshold = repeatSearchResultThreshold
***REMOVED******REMOVED***self.repeatSuggestResultThreshold = repeatSuggestResultThreshold
***REMOVED******REMOVED***self.resultSymbolStyle = resultSymbolStyle
***REMOVED******REMOVED***
***REMOVED******REMOVED***geocodeParameters.maxResults = Int32(maximumResults)
***REMOVED******REMOVED***suggestParameters.maxResults = Int32(maximumSuggestions)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The minimum number of results to attempt to return. If there are too few results, the search is
***REMOVED******REMOVED***/ repeated with loosened parameters until enough results are accumulated. If no search is
***REMOVED******REMOVED***/ successful, it is still possible to have a total number of results less than this threshold. Does not
***REMOVED******REMOVED***/ apply to repeated search with area constraint. Set to zero to disable search repeat behavior.
***REMOVED***var repeatSearchResultThreshold: Int = 1
***REMOVED***
***REMOVED******REMOVED***/ The minimum number of suggestions to attempt to return. If there are too few suggestions,
***REMOVED******REMOVED***/ request is repeated with loosened constraints until enough suggestions are accumulated.
***REMOVED******REMOVED***/ If no search is successful, it is still possible to have a total number of results less than this
***REMOVED******REMOVED***/ threshold. Does not apply to repeated search with area constraint. Set to zero to disable search
***REMOVED******REMOVED***/ repeat behavior.
***REMOVED***var repeatSuggestResultThreshold: Int = 6
***REMOVED***
***REMOVED******REMOVED***/ Web style used to find symbols for results. When set, symbols are found for results based on the
***REMOVED******REMOVED***/ result's `Type` field, if available. Defaults to the style identified by the name
***REMOVED******REMOVED***/ "Esri2DPointSymbolsStyle". The default Esri 2D point symbol has good results for many of the
***REMOVED******REMOVED***/ types returned by the world geocode service. You can use this property to customize result icons
***REMOVED******REMOVED***/ by publishing a web style, taking care to ensure that symbol keys match the `Type` attribute
***REMOVED******REMOVED***/ returned by the locator.
***REMOVED***var resultSymbolStyle: SymbolStyle?

***REMOVED***public override func search(
***REMOVED******REMOVED***_ queryString: String,
***REMOVED******REMOVED***area: Geometry?
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED******REMOVED*** First, peform super class search.
***REMOVED******REMOVED***var results = try await super.search(queryString, area: area)
***REMOVED******REMOVED***if results.count > repeatSearchResultThreshold ||
***REMOVED******REMOVED***   area == nil,
***REMOVED******REMOVED***   searchArea == nil,
***REMOVED******REMOVED***   preferredSearchLocation == nil {
***REMOVED******REMOVED******REMOVED******REMOVED*** Result count meets threshold or there were no geographic
***REMOVED******REMOVED******REMOVED******REMOVED*** constraints on the search, so return results.
***REMOVED******REMOVED******REMOVED***return results
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Remove geographic constraints and re-run search.
***REMOVED******REMOVED***geocodeParameters.searchArea = nil
***REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = nil
***REMOVED******REMOVED***let geocodeResults = try await locator.geocode(
***REMOVED******REMOVED******REMOVED***searchText: queryString,
***REMOVED******REMOVED******REMOVED***parameters: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Union results and return.
***REMOVED******REMOVED***let searchResults = geocodeResults.map{ $0.toSearchResult(searchSource: self) ***REMOVED***
***REMOVED******REMOVED***results.append(contentsOf: searchResults)
***REMOVED******REMOVED***var allResults: [SearchResult] = Array(Set(results))

***REMOVED******REMOVED******REMOVED*** Limit results to `maximumResults`.
***REMOVED******REMOVED***if allResults.count > maximumResults {
***REMOVED******REMOVED******REMOVED***let dropCount = allResults.count - maximumResults
***REMOVED******REMOVED******REMOVED***allResults = allResults.dropLast(dropCount)
***REMOVED***
***REMOVED******REMOVED***return allResults
***REMOVED***

***REMOVED***public override func search(
***REMOVED******REMOVED***_ searchSuggestion: SearchSuggestion
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED***guard let suggestResult = searchSuggestion.suggestResult else { return [] ***REMOVED***

***REMOVED******REMOVED***var results = try await super.search(searchSuggestion)
***REMOVED******REMOVED***if results.count > repeatSearchResultThreshold ||
***REMOVED******REMOVED***   searchArea == nil,
***REMOVED******REMOVED***   preferredSearchLocation == nil {
***REMOVED******REMOVED******REMOVED******REMOVED*** Result count meets threshold or there were no geographic
***REMOVED******REMOVED******REMOVED******REMOVED*** constraints on the search, so return results.
***REMOVED******REMOVED******REMOVED***return results
***REMOVED***

***REMOVED******REMOVED******REMOVED*** Remove geographic constraints and re-run search.
***REMOVED******REMOVED***geocodeParameters.searchArea = nil
***REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = nil
***REMOVED******REMOVED***let geocodeResults = try await locator.geocode(suggestResult: suggestResult,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***parameters: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Union results and return.
***REMOVED******REMOVED***let searchResults = geocodeResults.map{ $0.toSearchResult(searchSource: self) ***REMOVED***
***REMOVED******REMOVED***results.append(contentsOf: searchResults)
***REMOVED******REMOVED***var allResults: [SearchResult] = Array(Set(results))

***REMOVED******REMOVED******REMOVED*** Limit results to `maximumResults`.
***REMOVED******REMOVED***if allResults.count > maximumResults {
***REMOVED******REMOVED******REMOVED***let dropCount = allResults.count - maximumResults
***REMOVED******REMOVED******REMOVED***allResults = allResults.dropLast(dropCount)
***REMOVED***
***REMOVED******REMOVED***return allResults
***REMOVED***
***REMOVED***
***REMOVED***public override func suggest(
***REMOVED******REMOVED***_ queryString: String
***REMOVED***) async throws -> [SearchSuggestion] {
***REMOVED******REMOVED***var results = try await super.suggest(queryString)
***REMOVED******REMOVED***if results.count > repeatSuggestResultThreshold ||
***REMOVED******REMOVED***   searchArea == nil,
***REMOVED******REMOVED***   preferredSearchLocation == nil {
***REMOVED******REMOVED******REMOVED******REMOVED*** Result count meets threshold or there were no geographic
***REMOVED******REMOVED******REMOVED******REMOVED*** constraints on the search, so return results.
***REMOVED******REMOVED******REMOVED***return results
***REMOVED***

***REMOVED******REMOVED******REMOVED*** Remove geographic constraints and re-run search.
***REMOVED******REMOVED***suggestParameters.searchArea = nil
***REMOVED******REMOVED***suggestParameters.preferredSearchLocation = nil
***REMOVED******REMOVED***let geocodeResults =  try await locator.suggest(
***REMOVED******REMOVED******REMOVED***searchText: queryString,
***REMOVED******REMOVED******REMOVED***parameters: suggestParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Union results and return.
***REMOVED******REMOVED***let suggestResults = geocodeResults.map{ $0.toSearchSuggestion(searchSource: self) ***REMOVED***
***REMOVED******REMOVED***results.append(contentsOf: suggestResults)
***REMOVED******REMOVED***var allResults: [SearchSuggestion] = Array(Set(results))

***REMOVED******REMOVED******REMOVED*** Limit results to `maximumResults`.
***REMOVED******REMOVED***if allResults.count > maximumSuggestions {
***REMOVED******REMOVED******REMOVED***let dropCount = allResults.count - maximumSuggestions
***REMOVED******REMOVED******REMOVED***allResults = allResults.dropLast(dropCount)
***REMOVED***
***REMOVED******REMOVED***return allResults
***REMOVED***
***REMOVED***
