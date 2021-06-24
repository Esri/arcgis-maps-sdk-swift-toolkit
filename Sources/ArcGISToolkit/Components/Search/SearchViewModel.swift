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
***REMOVED***public convenience init(defaultPlaceHolder: String = "Find a place or address",
***REMOVED******REMOVED******REMOVED******REMOVED***activeSource: SearchSourceProtocol? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***queryArea: Geometry? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***queryCenter: Point? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***resultMode: SearchResultMode = .automatic,
***REMOVED******REMOVED******REMOVED******REMOVED***results: [SearchResult]? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***sources: [SearchSourceProtocol] = [],
***REMOVED******REMOVED******REMOVED******REMOVED***suggestions: [SearchSuggestion]? = nil
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
***REMOVED***var defaultPlaceHolder: String = "Find a place or address"
***REMOVED***
***REMOVED******REMOVED***/ Tracks the currently active search source.  All sources are used if this property is `nil`.
***REMOVED***var activeSource: SearchSourceProtocol?
***REMOVED***
***REMOVED******REMOVED***/ Tracks the current user-entered query. This should be updated by the view after every key press.
***REMOVED******REMOVED***/ This property drives both suggestions and searches. This property can be changed by
***REMOVED******REMOVED***/ other method calls and property changes within the view model, so the view should take care to
***REMOVED******REMOVED***/ observe for changes.
***REMOVED***@Published
***REMOVED***var currentQuery: String = ""
***REMOVED***
***REMOVED******REMOVED***/ The search area to be used for the current query. Ignored in most queries, unless the
***REMOVED******REMOVED***/ `RestrictToArea` property is set to true when calling `commitSearch`. This property
***REMOVED******REMOVED***/ should be updated as the user navigates the map/scene, or at minimum before calling `commitSearch`.
***REMOVED***var queryArea: Geometry?
***REMOVED***
***REMOVED******REMOVED***/ Defines the center for the search. This should be updated by the view every time the
***REMOVED******REMOVED***/ user navigates the map.
***REMOVED***var queryCenter: Point?
***REMOVED***
***REMOVED******REMOVED***/ Defines how many results to return. Defaults to Automatic. In automatic mode, an appropriate
***REMOVED******REMOVED***/ number of results is returned based on the type of suggestion chosen (driven by the IsCollection property).
***REMOVED***var resultMode: SearchResultMode = .automatic
***REMOVED***
***REMOVED******REMOVED***/ Collection of results. `nil` means no query has been made. An empty array means there
***REMOVED******REMOVED***/ were no results, and the view should show an appropriate 'no results' message.
***REMOVED***var results: [SearchResult]?
***REMOVED***
***REMOVED***@Published
***REMOVED******REMOVED***/ Tracks selection of results from the `results` collection. When there is only one result,
***REMOVED******REMOVED***/ that result is automatically assigned to this property. If there are multiple results, the view sets
***REMOVED******REMOVED***/ this property upon user selection. This property is observable. The view should observe this
***REMOVED******REMOVED***/ property and update the associated GeoView's viewpoint, if configured.
***REMOVED***var selectedResult: SearchResult?
***REMOVED***
***REMOVED******REMOVED***/ Collection of search sources to be used. This list is maintained over time and is not nullable.
***REMOVED******REMOVED***/ The view should observe this list for changes. Consumers should add and remove sources from
***REMOVED******REMOVED***/ this list as needed.
***REMOVED***var sources: [SearchSourceProtocol] = []
***REMOVED***
***REMOVED******REMOVED***/ Collection of suggestion results. Defaults to `nil`. This collection will be set to empty when there
***REMOVED******REMOVED***/ are no suggestions, `nil` when no suggestions have been requested. If the list is empty,
***REMOVED******REMOVED***/ a useful 'no results' message should be shown by the view.
***REMOVED***var suggestions: [SearchSuggestion]?
***REMOVED***
***REMOVED******REMOVED***/ True if the `queryArea` has changed since the `results` collection has been set.
***REMOVED******REMOVED***/ This property is used by the view to enable 'Repeat search here' functionality. This property is
***REMOVED******REMOVED***/ observable, and the view should use it to hide and show the 'repeat search' button. Changes to
***REMOVED******REMOVED***/ this property are driven by changes to the `queryArea` property.
***REMOVED***@Published
***REMOVED***var isEligibleForRequery: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ Starts a search. `selectedResult` and `results`, among other properties, are set
***REMOVED******REMOVED***/ asynchronously. Other query properties are read to define the parameters of the search.
***REMOVED******REMOVED***/ Participates in cooperative cancellation using the supplied cancellation token.
***REMOVED******REMOVED***/ If `restrictToArea` is true, only results in the query area will be returned.
***REMOVED******REMOVED***/ - Parameter restrictToArea: If true, the search is restricted to results within the extent
***REMOVED******REMOVED***/ of the `queryArea` property. Behavior when called with `restrictToArea` set to true
***REMOVED******REMOVED***/ when the `queryArea` property is null, a line, a point, or an empty geometry is undefined.
***REMOVED***func commitSearch(_ restrictToArea: Bool) async {
***REMOVED******REMOVED***guard !currentQuery.isEmpty else { return ***REMOVED***
***REMOVED******REMOVED***print("SearchViewModel.commitSearch: \(currentQuery)")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates suggestions list asynchronously. View should take care to cancel previous suggestion
***REMOVED******REMOVED***/ requests before initiating new ones. The view should also wait for some time after user finishes
***REMOVED******REMOVED***/ typing before making suggestions. The JavaScript implementation uses 150ms by default.
***REMOVED******REMOVED***/ - Parameter cancellationToken: Token used for cooperative cancellation.
***REMOVED***func updateSuggestions(_ cancellationToken: String?) async {
***REMOVED******REMOVED***guard !currentQuery.isEmpty else { return ***REMOVED***
***REMOVED******REMOVED***print("SearchViewModel.updateSuggestions: \(currentQuery)")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Commits a search from a specific suggestion. Results will be set asynchronously. Behavior is
***REMOVED******REMOVED***/ generally the same as `commitSearch`, except the suggestion is used instead of the
***REMOVED******REMOVED***/ `currentQuery` property. When a suggestion is accepted, `currentQuery` is updated to
***REMOVED******REMOVED***/ match the suggestion text. The view should take care not to submit a separate search in response
***REMOVED******REMOVED***/ to changes to `currentQuery` initiated by a call to this method.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - searchSuggestion: The suggestion to use to commit the search.
***REMOVED******REMOVED***/   - cancellationToken: ken used for cooperative cancellation.
***REMOVED***func acceptSuggestion(_ searchSuggestion: SearchSuggestion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  cancellationToken: String?) async {
***REMOVED******REMOVED***print("SearchViewModel.acceptSuggestion")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Configures the view model for the provided map. By default, will only configure the view model
***REMOVED******REMOVED***/ with the default world geocoder. In future updates, additional functionality may be added to take
***REMOVED******REMOVED***/ web map configuration into account.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - map: Map to use for configuration.
***REMOVED******REMOVED***/   - cancellationToken: cancellationToken: String
***REMOVED***func configureForMap(_ map: Map, cancellationToken: String?) {
***REMOVED******REMOVED***print("SearchViewModel.configureForMap")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Configures the view model for the provided scene. By default, will only configure the view model
***REMOVED******REMOVED***/ with the default world geocoder. In future updates, additional functionality may be added to take
***REMOVED******REMOVED***/ web scene configuration into account.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - scene: Scene used for configuration.
***REMOVED******REMOVED***/   - cancellationToke: Token used for cooperative cancellation.
***REMOVED***func configureForScene(_ scene: ArcGIS.Scene, cancellationToken: String?) {
***REMOVED******REMOVED***print("SearchViewModel.configureForScene")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Clears the search. This will set the results list to null, clear the result selection, clear suggestions,
***REMOVED******REMOVED***/ and reset the current query.
***REMOVED***func clearSearch() {
***REMOVED******REMOVED***print("SearchViewModel.clearSearch")
***REMOVED***
***REMOVED***
