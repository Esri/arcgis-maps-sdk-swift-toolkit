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
import Combine

***REMOVED***/ Performs searches and manages search state for a Search, or optionally without a UI connection.
@MainActor
public class SearchViewModel: ObservableObject {
***REMOVED******REMOVED***/ Defines how many results to return; one, many, or automatic based on circumstance.
***REMOVED***public enum SearchResultMode {
***REMOVED******REMOVED******REMOVED***/ Search should always result in at most one result.
***REMOVED******REMOVED***case single
***REMOVED******REMOVED******REMOVED***/ Search should always try to return multiple results.
***REMOVED******REMOVED***case multiple
***REMOVED******REMOVED******REMOVED***/ Search should make a choice based on context. E.g. 'coffee shop' should be multiple results,
***REMOVED******REMOVED******REMOVED***/ while '380 New York St. Redlands' should be one result.
***REMOVED******REMOVED***case automatic
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `SearchViewModel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - defaultPlaceholder: The string shown in the search view when no user query is entered.
***REMOVED******REMOVED***/   - activeSource: Tracks the currently active search source.
***REMOVED******REMOVED***/   - queryArea: The search area to be used for the current query.
***REMOVED******REMOVED***/   - queryCenter: Defines the center for the search.
***REMOVED******REMOVED***/   - resultMode: Defines how many results to return.
***REMOVED******REMOVED***/   - sources: Collection of search sources to be used.
***REMOVED***public convenience init(
***REMOVED******REMOVED***defaultPlaceholder: String = .defaultPlaceholder,
***REMOVED******REMOVED***activeSource: SearchSourceProtocol? = nil,
***REMOVED******REMOVED***queryArea: Geometry? = nil,
***REMOVED******REMOVED***queryCenter: Point? = nil,
***REMOVED******REMOVED***resultMode: SearchResultMode = .automatic,
***REMOVED******REMOVED***sources: [SearchSourceProtocol] = []
***REMOVED***) {
***REMOVED******REMOVED***self.init()
***REMOVED******REMOVED***self.defaultPlaceholder = defaultPlaceholder
***REMOVED******REMOVED***self.activeSource = activeSource
***REMOVED******REMOVED***self.queryArea = queryArea
***REMOVED******REMOVED***self.queryCenter = queryCenter
***REMOVED******REMOVED***self.resultMode = resultMode
***REMOVED******REMOVED***self.sources = sources
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The string shown in the search view when no user query is entered.
***REMOVED******REMOVED***/ Default is "Find a place or address".
***REMOVED***public var defaultPlaceholder: String = .defaultPlaceholder
***REMOVED***
***REMOVED******REMOVED***/ The active search source.  If `nil`, the first item in `sources` is used.
***REMOVED***public var activeSource: SearchSourceProtocol?
***REMOVED***
***REMOVED******REMOVED***/ Tracks the current user-entered query. This property drives both suggestions and searches.
***REMOVED***@Published
***REMOVED***public var currentQuery: String = "" {
***REMOVED******REMOVED***willSet {
***REMOVED******REMOVED******REMOVED***results = nil
***REMOVED******REMOVED******REMOVED***suggestions = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The search area to be used for the current query.  This property should be updated
***REMOVED******REMOVED***/ as the user navigates the map/scene, or at minimum before calling `commitSearch`.
***REMOVED***public var queryArea: Geometry? = nil
***REMOVED***
***REMOVED******REMOVED***/ Defines the center for the search. For most use cases, this should be updated by the view
***REMOVED******REMOVED***/ every time the user navigates the map.
***REMOVED***public var queryCenter: Point?
***REMOVED***
***REMOVED******REMOVED***/ Defines how many results to return. Defaults to Automatic. In automatic mode, an appropriate
***REMOVED******REMOVED***/ number of results is returned based on the type of suggestion chosen
***REMOVED******REMOVED***/ (driven by the IsCollection property).
***REMOVED***public var resultMode: SearchResultMode = .automatic
***REMOVED***
***REMOVED******REMOVED***/ Collection of results. `nil` means no query has been made. An empty array means there
***REMOVED******REMOVED***/ were no results, and the view should show an appropriate 'no results' message.
***REMOVED***@Published
***REMOVED***public private(set) var results: Result<[SearchResult], SearchError>? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***switch results {
***REMOVED******REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***if results.count == 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = results.first
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED***/ NOTE:  only the first source is currently used; multiple sources are not yet supported.
***REMOVED***public var sources: [SearchSourceProtocol] = []
***REMOVED***
***REMOVED******REMOVED***/ Collection of suggestion results. Defaults to `nil`. This collection will be set to empty when there
***REMOVED******REMOVED***/ are no suggestions, `nil` when no suggestions have been requested. If the list is empty,
***REMOVED******REMOVED***/ a useful 'no results' message should be shown by the view.
***REMOVED***@Published
***REMOVED***public private(set) var suggestions: Result<[SearchSuggestion], SearchError>?
***REMOVED***
***REMOVED***private var subscriptions = Set<AnyCancellable>()
***REMOVED***
***REMOVED******REMOVED***/ The currently executing async task.  `currentTask` should be cancelled
***REMOVED******REMOVED***/ prior to starting another async task.
***REMOVED***private var currentTask: Task<Void, Never>?
***REMOVED***
***REMOVED***private func makeEffectiveSource(
***REMOVED******REMOVED***with searchArea: Geometry?,
***REMOVED******REMOVED***preferredSearchLocation: Point?
***REMOVED***) -> SearchSourceProtocol? {
***REMOVED******REMOVED***guard var source = currentSource() else { return nil ***REMOVED***
***REMOVED******REMOVED***source.searchArea = searchArea ?? queryArea
***REMOVED******REMOVED***source.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***return source
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Starts a search. `selectedResult` and `results`, among other properties, are set
***REMOVED******REMOVED***/ asynchronously. Other query properties are read to define the parameters of the search.
***REMOVED******REMOVED***/ - Parameter searchArea: geometry used to constrain the results.  If `nil`, the
***REMOVED******REMOVED***/ `queryArea` property is used instead.  If `queryArea` is `nil`, results are not constrained.
***REMOVED***public func commitSearch(_ searchArea: Geometry? = nil) {
***REMOVED******REMOVED***guard !currentQuery.trimmingCharacters(in: .whitespaces).isEmpty,
***REMOVED******REMOVED******REMOVED***  let source = makeEffectiveSource(with: searchArea, preferredSearchLocation: queryCenter) else {
***REMOVED******REMOVED******REMOVED******REMOVED***  return
***REMOVED***  ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***kickoffTask(commitSearchTask(source))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates suggestions list asynchronously.
***REMOVED***@MainActor  ***REMOVED*** TODO:  ???? yes or no or a better idea?  Maybe model is an Actor and not a class
***REMOVED***public func updateSuggestions() {
***REMOVED******REMOVED***guard !currentQuery.trimmingCharacters(in: .whitespaces).isEmpty,
***REMOVED******REMOVED******REMOVED***  let source = makeEffectiveSource(with: queryArea, preferredSearchLocation: queryCenter) else {
***REMOVED******REMOVED******REMOVED******REMOVED***  return
***REMOVED***  ***REMOVED***
***REMOVED******REMOVED***guard currentSuggestion == nil else {
***REMOVED******REMOVED******REMOVED******REMOVED*** don't update suggestions if currently searching for one
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***kickoffTask(updateSuggestionsTask(source))
***REMOVED***
***REMOVED***
***REMOVED***@Published
***REMOVED***public var currentSuggestion: SearchSuggestion? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***if let currentSuggestion = currentSuggestion {
***REMOVED******REMOVED******REMOVED******REMOVED***currentQuery = currentSuggestion.displayTitle
***REMOVED******REMOVED******REMOVED******REMOVED***kickoffTask(acceptSuggestionTask(currentSuggestion))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Commits a search from a specific suggestion. Results will be set asynchronously. Behavior is
***REMOVED******REMOVED***/ generally the same as `commitSearch`, except `searchSuggestion` is used instead of the
***REMOVED******REMOVED***/ `currentQuery` property.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - searchSuggestion: The suggestion to use to commit the search.
***REMOVED***public func acceptSuggestion(
***REMOVED******REMOVED***_ searchSuggestion: SearchSuggestion
***REMOVED***) async -> Void {
***REMOVED******REMOVED***currentQuery = searchSuggestion.displayTitle
***REMOVED******REMOVED***
***REMOVED******REMOVED***suggestions = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***currentTask?.cancel()
***REMOVED******REMOVED***currentTask = acceptSuggestionTask(searchSuggestion)
***REMOVED******REMOVED***await currentTask?.value
***REMOVED***
***REMOVED***
***REMOVED***private func kickoffTask(_ task: Task<(), Never>) {
***REMOVED******REMOVED***suggestions = nil
***REMOVED******REMOVED***currentTask?.cancel()
***REMOVED******REMOVED***currentTask = task
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Clears the search. This will set the results list to null, clear the result selection, clear suggestions,
***REMOVED******REMOVED***/ and reset the current query.
***REMOVED***public func clearSearch() {
***REMOVED******REMOVED******REMOVED*** Setting currentQuery to "" will reset everything necessary.
***REMOVED******REMOVED***currentQuery = ""
***REMOVED***
***REMOVED***

extension SearchViewModel {
***REMOVED***private func commitSearchTask(_ source: SearchSourceProtocol) -> Task<(), Never> {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await process(searchResults: source.search(currentQuery))
***REMOVED******REMOVED*** catch is CancellationError {
***REMOVED******REMOVED******REMOVED******REMOVED***results = nil
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***results = .failure(SearchError(error))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func updateSuggestionsTask(_ source: SearchSourceProtocol) -> Task<(), Never> {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***let suggestResult = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await source.suggest(currentQuery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch suggestResult {
***REMOVED******REMOVED******REMOVED***case .success(let suggestResults):
***REMOVED******REMOVED******REMOVED******REMOVED***suggestions = .success(suggestResults)
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***suggestions = .failure(SearchError(error))
***REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED******REMOVED***case nil:
***REMOVED******REMOVED******REMOVED******REMOVED***suggestions = nil
***REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func acceptSuggestionTask(_ searchSuggestion: SearchSuggestion) -> Task<(), Never> {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await process(searchResults: searchSuggestion.owningSource.search(searchSuggestion))
***REMOVED******REMOVED*** catch is CancellationError {
***REMOVED******REMOVED******REMOVED******REMOVED***results = nil
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***results = .failure(SearchError(error))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** once we are done searching for the suggestion, then reset it to nil
***REMOVED******REMOVED******REMOVED***currentSuggestion = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func process(searchResults: [SearchResult], isCollection: Bool = true) {
***REMOVED******REMOVED***let effectiveResults: [SearchResult]
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch (resultMode) {
***REMOVED******REMOVED***case .single:
***REMOVED******REMOVED******REMOVED***if let firstResult = searchResults.first {
***REMOVED******REMOVED******REMOVED******REMOVED***effectiveResults = [firstResult]
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***effectiveResults = []
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .multiple:
***REMOVED******REMOVED******REMOVED***effectiveResults = searchResults
***REMOVED******REMOVED***case .automatic:
***REMOVED******REMOVED******REMOVED***if isCollection {
***REMOVED******REMOVED******REMOVED******REMOVED***effectiveResults = searchResults
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***if let firstResult = searchResults.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***effectiveResults = [firstResult]
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***effectiveResults = []
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = .success(effectiveResults)
***REMOVED***
***REMOVED***

extension SearchViewModel {
***REMOVED******REMOVED***/ Returns the search source to be used in geocode operations.
***REMOVED******REMOVED***/ - Returns: The search source to use.
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

public extension String {
***REMOVED***static let defaultPlaceholder = "Find a place or address"
***REMOVED***
