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
public struct SmartLocatorSearchSource {
***REMOVED***public init(repeatSearchResultThreshold: Int = 1,
***REMOVED******REMOVED******REMOVED******REMOVED***repeatSuggestResultThreshold: Int = 6,
***REMOVED******REMOVED******REMOVED******REMOVED***resultSymbolStyle: SymbolStyle? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***locator: LocatorTask = LocatorTask(url: URL(string: "https:***REMOVED***geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!),
***REMOVED******REMOVED******REMOVED******REMOVED***geocodeParameters: GeocodeParameters,
***REMOVED******REMOVED******REMOVED******REMOVED***suggestParameters: SuggestParameters,
***REMOVED******REMOVED******REMOVED******REMOVED***displayName: String = "Search",
***REMOVED******REMOVED******REMOVED******REMOVED***maximumResults: Int = 6,
***REMOVED******REMOVED******REMOVED******REMOVED***maximumSuggestions: Int = 6,
***REMOVED******REMOVED******REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***preferredSearchLocation: Point? = nil
***REMOVED***){
***REMOVED******REMOVED***self.repeatSearchResultThreshold = repeatSearchResultThreshold
***REMOVED******REMOVED***self.repeatSuggestResultThreshold = repeatSuggestResultThreshold
***REMOVED******REMOVED***self.resultSymbolStyle = resultSymbolStyle
***REMOVED******REMOVED***self._locator = locator
***REMOVED******REMOVED***self._geocodeParameters = geocodeParameters
***REMOVED******REMOVED***self._suggestParameters = suggestParameters
***REMOVED******REMOVED***self._displayName = displayName
***REMOVED******REMOVED***self._maximumResults = maximumResults
***REMOVED******REMOVED***self._maximumSuggestions = maximumSuggestions
***REMOVED******REMOVED***self._searchArea = searchArea
***REMOVED******REMOVED***self._preferredSearchLocation = preferredSearchLocation
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The minimum number of results to attempt to return. If there are too few results, the search is
***REMOVED******REMOVED***/ repeated with loosened parameters until enough results are accumulated. If no search is
***REMOVED******REMOVED***/ successful, it is still possible to have a total number of results less than this threshold. Does not
***REMOVED******REMOVED***/ apply to repeated search with area constraint. Set to zero to disable search repeat behavior.
***REMOVED***var repeatSearchResultThreshold: Int
***REMOVED***
***REMOVED******REMOVED***/ The minimum number of suggestions to attempt to return. If there are too few suggestions,
***REMOVED******REMOVED***/ request is repeated with loosened constraints until enough suggestions are accumulated.
***REMOVED******REMOVED***/ If no search is successful, it is still possible to have a total number of results less than this
***REMOVED******REMOVED***/ threshold. Does not apply to repeated search with area constraint. Set to zero to disable search
***REMOVED******REMOVED***/ repeat behavior.
***REMOVED***var repeatSuggestResultThreshold: Int
***REMOVED***
***REMOVED******REMOVED***/ Web style used to find symbols for results. When set, symbols are found for results based on the
***REMOVED******REMOVED***/ result's `Type` field, if available. Defaults to the style identified by the name
***REMOVED******REMOVED***/ "Esri2DPointSymbolsStyle". The default Esri 2D point symbol has good results for many of the
***REMOVED******REMOVED***/ types returned by the world geocode service. You can use this property to customize result icons
***REMOVED******REMOVED***/ by publishing a web style, taking care to ensure that symbol keys match the `Type` attribute
***REMOVED******REMOVED***/ returned by the locator.
***REMOVED***var resultSymbolStyle: SymbolStyle?
***REMOVED***
***REMOVED******REMOVED***/ The locator used by this search source.
***REMOVED***private var _locator: LocatorTask = LocatorTask(url: URL(string: "https:***REMOVED***geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for geocoding. Some properties on parameters will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***private var _geocodeParameters: GeocodeParameters
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for getting suggestions. Some properties will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***private var _suggestParameters: SuggestParameters
***REMOVED***
***REMOVED******REMOVED***/ Name to show when presenting this source in the UI.
***REMOVED***private var _displayName: String
***REMOVED***
***REMOVED******REMOVED***/ The maximum results to return when performing a search. Most sources default to 6.
***REMOVED***private var _maximumResults: Int
***REMOVED***
***REMOVED******REMOVED***/ The maximum suggestions to return. Most sources default to 6.
***REMOVED***private var _maximumSuggestions: Int
***REMOVED***
***REMOVED******REMOVED***/ Area to be used as a constraint for searches and suggestions.
***REMOVED***private var _searchArea: Geometry?
***REMOVED***
***REMOVED******REMOVED***/ Point to be used as an input to searches and suggestions.
***REMOVED***private var _preferredSearchLocation: Point?
***REMOVED***
***REMOVED******REMOVED******REMOVED***@State
***REMOVED******REMOVED******REMOVED***private var address: String = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***@State
***REMOVED******REMOVED******REMOVED***private var result: Result<[GeocodeResult], Error> = .success([])
***REMOVED***

extension SmartLocatorSearchSource: LocatorSearchSourceProtocol {
***REMOVED***public var locator: LocatorTask {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return _locator
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var geocodeParameters: GeocodeParameters {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return _geocodeParameters
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var suggestParameters: SuggestParameters {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return _suggestParameters
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var displayName: String {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return _displayName
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***_displayName = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var maximumResults: Int {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return _maximumResults
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***_maximumResults = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var maximumSuggestions: Int {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return _maximumSuggestions
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***_maximumSuggestions = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var searchArea: Geometry? {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return _searchArea
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***_searchArea = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var preferredSearchLocation: Point? {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***return _preferredSearchLocation
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***_preferredSearchLocation = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func suggest(_ queryString: String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cancelationToken: String) async throws -> [SearchSuggestion] {
***REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***public func search(_ queryString: String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   area: Geometry?,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   cancellationToken: String?) async throws -> [SearchResult] {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***result = await Result { try await locator.geocode(searchText: address) ***REMOVED***
***REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***public func search(_ searchSuggestion: SearchSuggestion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   area: Geometry?,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   cancellationToken: String?) async throws -> [SearchResult] {
***REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
