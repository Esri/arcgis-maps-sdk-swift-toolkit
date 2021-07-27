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

import Swift
***REMOVED***
***REMOVED***

***REMOVED***/ Defines how many results to return; one, many, or automatic based on circumstance.
public enum SearchResultMode {
***REMOVED******REMOVED***/ Search should always result in at most one result.
***REMOVED***case single
***REMOVED******REMOVED***/ Search should always try to return multiple results.
***REMOVED***case multiple
***REMOVED******REMOVED***/ Search should make a choice based on context. E.g. 'coffee shop' should be multiple results,
***REMOVED******REMOVED***/ while '380 New York St. Redlands' should be one result.
***REMOVED***case automatic
***REMOVED***

***REMOVED***/ Performs searches and manages search state for a Search, or optionally without a UI connection.
public class SearchViewModel: ObservableObject {
***REMOVED***public convenience init(
defaultPlaceHolder: String = "Find a place or address",
activeSource: SearchSourceProtocol? = nil,
queryArea: Geometry? = nil,
queryCenter: Point? = nil,
resultMode: SearchResultMode = .automatic,
results: Result<[SearchResult]?, SearchError> = .success(nil),
sources: [SearchSourceProtocol] = [],
suggestions: Result<[SearchSuggestion]?, SearchError> = .success(nil)
***REMOVED***) {
***REMOVED******REMOVED***self.init()
***REMOVED******REMOVED***self.defaultPlaceHolder = defaultPlaceHolder
***REMOVED******REMOVED***self.activeSource = activeSource
***REMOVED******REMOVED***self.queryArea = queryArea
***REMOVED******REMOVED***self.queryCenter = queryCenter
***REMOVED******REMOVED***self.resultMode = resultMode
***REMOVED******REMOVED***self.results = results
***REMOVED******REMOVED***self.sources = sources
***REMOVED******REMOVED***self.suggestions = suggestions
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The string shown in the search view when no user query is entered.
***REMOVED******REMOVED***/ Default is "Find a place or address", or read from web map JSON if specified in the web map configuration.
***REMOVED***public var defaultPlaceHolder: String = "Find a place or address"
***REMOVED***
***REMOVED******REMOVED***/ Tracks the currently active search source.  All sources are used if this property is `nil`.
***REMOVED***public var activeSource: SearchSourceProtocol?
***REMOVED***
***REMOVED******REMOVED***/ Tracks the current user-entered query. This should be updated by the view after every key press.
***REMOVED******REMOVED***/ This property drives both suggestions and searches. This property can be changed by
***REMOVED******REMOVED***/ other method calls and property changes within the view model, so the view should take care to
***REMOVED******REMOVED***/ observe for changes.
***REMOVED***@Published
***REMOVED***public var currentQuery: String = "" {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***selectedResult = nil
***REMOVED******REMOVED******REMOVED***if currentQuery.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***results = .success(nil)
***REMOVED******REMOVED******REMOVED******REMOVED***suggestions = .success(nil)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The search area to be used for the current query. Ignored in most queries, unless the
***REMOVED******REMOVED***/ `restrictToArea` property is set to true when calling `commitSearch`. This property
***REMOVED******REMOVED***/ should be updated as the user navigates the map/scene, or at minimum before calling `commitSearch`.
***REMOVED***public var queryArea: Geometry? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***isEligibleForRequery = true
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Defines the center for the search. This should be updated by the view every time the
***REMOVED******REMOVED***/ user navigates the map.
***REMOVED***public var queryCenter: Point?
***REMOVED***
***REMOVED******REMOVED***/ Defines how many results to return. Defaults to Automatic. In automatic mode, an appropriate
***REMOVED******REMOVED***/ number of results is returned based on the type of suggestion chosen (driven by the IsCollection property).
***REMOVED***public var resultMode: SearchResultMode = .automatic
***REMOVED***
***REMOVED******REMOVED***/ Collection of results. `nil` means no query has been made. An empty array means there
***REMOVED******REMOVED***/ were no results, and the view should show an appropriate 'no results' message.
***REMOVED***@Published
***REMOVED***public var results: Result<[SearchResult]?, SearchError> = .success(nil)
***REMOVED***
***REMOVED******REMOVED***/ Tracks selection of results from the `results` collection. When there is only one result,
***REMOVED******REMOVED***/ that result is automatically assigned to this property. If there are multiple results, the view sets
***REMOVED******REMOVED***/ this property upon user selection. This property is observable. The view should observe this
***REMOVED******REMOVED***/ property and update the associated GeoView's viewpoint, if configured.
***REMOVED***@Published
***REMOVED***public var selectedResult: SearchResult?
***REMOVED***
***REMOVED******REMOVED***/ Collection of search sources to be used. This list is maintained over time and is not nullable.
***REMOVED******REMOVED***/ The view should observe this list for changes. Consumers should add and remove sources from
***REMOVED******REMOVED***/ this list as needed.
***REMOVED***public var sources: [SearchSourceProtocol] = []
***REMOVED***
***REMOVED******REMOVED***/ Collection of suggestion results. Defaults to `nil`. This collection will be set to empty when there
***REMOVED******REMOVED***/ are no suggestions, `nil` when no suggestions have been requested. If the list is empty,
***REMOVED******REMOVED***/ a useful 'no results' message should be shown by the view.
***REMOVED***@Published
***REMOVED***public var suggestions: Result<[SearchSuggestion]?, SearchError> = .success(nil)
***REMOVED***
***REMOVED******REMOVED***/ True if the `queryArea` has changed since the `results` collection has been set.
***REMOVED******REMOVED***/ This property is used by the view to enable 'Repeat search here' functionality. This property is
***REMOVED******REMOVED***/ observable, and the view should use it to hide and show the 'repeat search' button. Changes to
***REMOVED******REMOVED***/ this property are driven by changes to the `queryArea` property.
***REMOVED***private(set) var isEligibleForRequery: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ Starts a search. `selectedResult` and `results`, among other properties, are set
***REMOVED******REMOVED***/ asynchronously. Other query properties are read to define the parameters of the search.
***REMOVED******REMOVED***/ If `restrictToArea` is true, only results in the query area will be returned.
***REMOVED******REMOVED***/ - Parameter restrictToArea: If true, the search is restricted to results within the extent
***REMOVED******REMOVED***/ of the `queryArea` property. Behavior when called with `restrictToArea` set to true
***REMOVED******REMOVED***/ when the `queryArea` property is null, a line, a point, or an empty geometry is undefined.
***REMOVED***func commitSearch(_ restrictToArea: Bool) async -> Void {
***REMOVED******REMOVED***guard !currentQuery.isEmpty,
***REMOVED******REMOVED******REMOVED***  var source = currentSource() else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***source.searchArea = queryArea
***REMOVED******REMOVED***source.preferredSearchLocation = queryCenter
***REMOVED******REMOVED***
***REMOVED******REMOVED***let searchResult = await Result {
***REMOVED******REMOVED******REMOVED***try await source.search(
***REMOVED******REMOVED******REMOVED******REMOVED***currentQuery,
***REMOVED******REMOVED******REMOVED******REMOVED***area: restrictToArea ? queryArea : nil
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectedResult = nil
***REMOVED******REMOVED***isEligibleForRequery = false
***REMOVED******REMOVED***suggestions = .success(nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch searchResult {
***REMOVED******REMOVED***case .success(let searchResults):
***REMOVED******REMOVED******REMOVED***results = .success(searchResults)
***REMOVED******REMOVED******REMOVED***if searchResults.count == 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = searchResults.first
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***results = .failure(SearchError(error))
***REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***results = .success(nil)
***REMOVED******REMOVED******REMOVED***break
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates suggestions list asynchronously. View should take care to cancel previous suggestion
***REMOVED******REMOVED***/ requests before initiating new ones. The view should also wait for some time after user finishes
***REMOVED******REMOVED***/ typing before making suggestions. The JavaScript implementation uses 150ms by default.
***REMOVED***func updateSuggestions() async -> Void {
***REMOVED******REMOVED***guard !currentQuery.isEmpty,
***REMOVED******REMOVED******REMOVED***  var source = currentSource() else { return ***REMOVED***
***REMOVED******REMOVED***print("SearchViewModel.updateSuggestions: \(currentQuery)")
***REMOVED******REMOVED***
***REMOVED******REMOVED***source.searchArea = queryArea
***REMOVED******REMOVED***source.preferredSearchLocation = queryCenter
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestResult = await Result {
***REMOVED******REMOVED******REMOVED***try await source.suggest(currentQuery)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = .success(nil)
***REMOVED******REMOVED***selectedResult = nil
***REMOVED******REMOVED***isEligibleForRequery = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch suggestResult {
***REMOVED******REMOVED***case .success(let suggestResults):
***REMOVED******REMOVED******REMOVED***suggestions = .success(suggestResults)
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***suggestions = .failure(SearchError(error))
***REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***suggestions = .success(nil)
***REMOVED******REMOVED******REMOVED***break
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Commits a search from a specific suggestion. Results will be set asynchronously. Behavior is
***REMOVED******REMOVED***/ generally the same as `commitSearch`, except the suggestion is used instead of the
***REMOVED******REMOVED***/ `currentQuery` property. When a suggestion is accepted, `currentQuery` is updated to
***REMOVED******REMOVED***/ match the suggestion text. The view should take care not to submit a separate search in response
***REMOVED******REMOVED***/ to changes to `currentQuery` initiated by a call to this method.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - searchSuggestion: The suggestion to use to commit the search.
***REMOVED***func acceptSuggestion(_ searchSuggestion: SearchSuggestion) async -> Void {
***REMOVED******REMOVED***currentQuery = searchSuggestion.displayTitle
***REMOVED******REMOVED***
***REMOVED******REMOVED***var searchResults = [SearchResult]()
***REMOVED******REMOVED***var suggestError: Error?
***REMOVED******REMOVED***let searchResult = await Result {
***REMOVED******REMOVED******REMOVED***try await searchSuggestion.owningSource.search(searchSuggestion)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***suggestions = .success(nil)
***REMOVED******REMOVED***isEligibleForRequery = false
***REMOVED******REMOVED***selectedResult = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch searchResult {
***REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED***switch (resultMode)
***REMOVED******REMOVED******REMOVED***{
***REMOVED******REMOVED******REMOVED***case .single:
***REMOVED******REMOVED******REMOVED******REMOVED***if let firstResult = results.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchResults = [firstResult]
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .multiple:
***REMOVED******REMOVED******REMOVED******REMOVED***searchResults = results
***REMOVED******REMOVED******REMOVED***case .automatic:
***REMOVED******REMOVED******REMOVED******REMOVED***if searchSuggestion.suggestResult?.isCollection ?? true {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchResults = results
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let firstResult = results.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchResults = [firstResult]
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***suggestError = error
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***break
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let error = suggestError {
***REMOVED******REMOVED******REMOVED***results = .failure(SearchError(error))
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***results = .success(searchResults)
***REMOVED******REMOVED******REMOVED***if searchResults.count == 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = searchResults.first
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Configures the view model for the provided map. By default, will only configure the view model
***REMOVED******REMOVED***/ with the default world geocoder. In future updates, additional functionality may be added to take
***REMOVED******REMOVED***/ web map configuration into account.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - map: Map to use for configuration.
***REMOVED***func configureForMap(_ map: Map) {
***REMOVED******REMOVED***print("SearchViewModel.configureForMap")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Configures the view model for the provided scene. By default, will only configure the view model
***REMOVED******REMOVED***/ with the default world geocoder. In future updates, additional functionality may be added to take
***REMOVED******REMOVED***/ web scene configuration into account.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - scene: Scene used for configuration.
***REMOVED***func configureForScene(_ scene: ArcGIS.Scene) {
***REMOVED******REMOVED***print("SearchViewModel.configureForScene")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Clears the search. This will set the results list to null, clear the result selection, clear suggestions,
***REMOVED******REMOVED***/ and reset the current query.
***REMOVED***func clearSearch() {
***REMOVED******REMOVED******REMOVED*** Setting currentQuery to "" will reset everything necessary.
***REMOVED******REMOVED***currentQuery = ""
***REMOVED***
***REMOVED***

extension SearchViewModel {
***REMOVED***func currentSource() -> SearchSourceProtocol? {
***REMOVED******REMOVED***var source: SearchSourceProtocol?
***REMOVED******REMOVED***if let activeSource = activeSource {
***REMOVED******REMOVED******REMOVED***source = activeSource
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***source = sources.first
***REMOVED***
***REMOVED******REMOVED***return source
***REMOVED***
***REMOVED***
