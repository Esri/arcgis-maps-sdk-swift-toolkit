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
***REMOVED***public convenience init(displayName: String = "Search",
***REMOVED******REMOVED******REMOVED******REMOVED***maximumSuggestions: Int,
***REMOVED******REMOVED******REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***preferredSearchLocation: Point? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***repeatSearchResultThreshold: Int = 1,
***REMOVED******REMOVED******REMOVED******REMOVED***repeatSuggestResultThreshold: Int = 6,
***REMOVED******REMOVED******REMOVED******REMOVED***resultSymbolStyle: SymbolStyle? = nil) {
***REMOVED******REMOVED***self.init()
***REMOVED******REMOVED******REMOVED***self.objectWillChange = objectWillChange
***REMOVED******REMOVED***self.displayName = displayName
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
***REMOVED******REMOVED***public var displayName: String
***REMOVED***
***REMOVED******REMOVED***public var maximumSuggestions: Int
***REMOVED***
***REMOVED******REMOVED***public var searchArea: Geometry?
***REMOVED***
***REMOVED******REMOVED***public var preferredSearchLocation: Point?
***REMOVED***
***REMOVED******REMOVED***public func suggest(_ queryString: String) async throws -> [SearchSuggestion] {
***REMOVED******REMOVED******REMOVED***<#code#>
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***public func search(_ queryString: String, area: Geometry?) async throws -> [SearchResult] {
***REMOVED******REMOVED******REMOVED***<#code#>
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***public func search(_ searchSuggestion: SearchSuggestion, area: Geometry?) async throws -> [SearchResult] {
***REMOVED******REMOVED******REMOVED***<#code#>
***REMOVED******REMOVED***
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
***REMOVED***
