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
***REMOVED******REMOVED***/ The outcome of a geocode operation (search or suggestion).
***REMOVED***public enum SearchOutcome {
***REMOVED******REMOVED***case results(result: Result<[SearchResult], SearchError>)
***REMOVED******REMOVED***case suggestions(result: Result<[SearchSuggestion], SearchError>)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `SearchViewModel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - activeSource: Tracks the currently active search source.
***REMOVED******REMOVED***/   - queryArea: The search area to be used for the current query.
***REMOVED******REMOVED***/   - queryCenter: Defines the center for the search.
***REMOVED******REMOVED***/   - resultMode: Defines how many results to return.
***REMOVED******REMOVED***/   - sources: Collection of search sources to be used.
***REMOVED***public convenience init(
***REMOVED******REMOVED***activeSource: SearchSource? = nil,
***REMOVED******REMOVED***queryArea: Geometry? = nil,
***REMOVED******REMOVED***queryCenter: Point? = nil,
***REMOVED******REMOVED***resultMode: SearchResultMode = .automatic,
***REMOVED******REMOVED***sources: [SearchSource] = []
***REMOVED***) {
***REMOVED******REMOVED***self.init()
***REMOVED******REMOVED***self.activeSource = activeSource
***REMOVED******REMOVED***self.queryArea = queryArea
***REMOVED******REMOVED***self.queryCenter = queryCenter
***REMOVED******REMOVED***self.resultMode = resultMode
***REMOVED******REMOVED***self.sources = sources
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The active search source.  If `nil`, the first item in `sources` is used.
***REMOVED***public var activeSource: SearchSource?
***REMOVED***
***REMOVED******REMOVED***/ Tracks the current user-entered query. This property drives both suggestions and searches.
***REMOVED***@Published
***REMOVED***public var currentQuery: String = "" {
***REMOVED******REMOVED***willSet {
***REMOVED******REMOVED******REMOVED***isEligibleForRequery = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch searchOutcome {
***REMOVED******REMOVED******REMOVED***case .results(_):
***REMOVED******REMOVED******REMOVED******REMOVED***searchOutcome = nil
***REMOVED******REMOVED******REMOVED***case .suggestions(_):
***REMOVED******REMOVED******REMOVED******REMOVED***if currentQuery.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchOutcome = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The extent at the time of the last search.  This is primarily set by the model, but in certain
***REMOVED******REMOVED***/ circumstances can be set by an external client, for example after a view zooms programmatically
***REMOVED******REMOVED***/ to an extent based on results of a search.
***REMOVED***public var lastSearchExtent: Envelope? = nil {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***isEligibleForRequery = false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current GeoView extent.  Defaults to null.  This should be updated as the user navigates
***REMOVED******REMOVED***/ the map/scene.  It will be used to determine the value of `IsEligibleForRequery`
***REMOVED******REMOVED***/ for the 'Repeat search here' behavior.  If that behavior is not wanted, it should be left `nil`.
***REMOVED***public var geoViewExtent: Envelope? = nil {
***REMOVED******REMOVED***willSet {
***REMOVED******REMOVED******REMOVED***guard !isEligibleForRequery,
***REMOVED******REMOVED******REMOVED******REMOVED***  !currentQuery.isEmpty,
***REMOVED******REMOVED******REMOVED******REMOVED***  let lastExtent = lastSearchExtent,
***REMOVED******REMOVED******REMOVED******REMOVED***  let newExtent = newValue
***REMOVED******REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Check extent difference.
***REMOVED******REMOVED******REMOVED***let widthDiff = abs(lastExtent.width - newExtent.width)
***REMOVED******REMOVED******REMOVED***let heightDiff = abs(lastExtent.height - newExtent.height)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let widthThreshold = lastExtent.width * 0.25
***REMOVED******REMOVED******REMOVED***let heightThreshold = lastExtent.height * 0.25
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isEligibleForRequery = widthDiff > widthThreshold || heightDiff > heightThreshold
***REMOVED******REMOVED******REMOVED***guard !isEligibleForRequery else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Check center difference.
***REMOVED******REMOVED******REMOVED***let centerDiff = GeometryEngine.distance(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry1: lastExtent.center,
***REMOVED******REMOVED******REMOVED******REMOVED***geometry2: newExtent.center
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let currentExtentAvg = (lastExtent.width + lastExtent.height) / 2.0
***REMOVED******REMOVED******REMOVED***let threshold = currentExtentAvg * 0.25
***REMOVED******REMOVED******REMOVED***isEligibleForRequery = (centerDiff ?? 0.0) > threshold
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ True if the Extent has changed by a set amount after a `Search` or `AcceptSuggestion` call.
***REMOVED******REMOVED***/ This property is used by the view to enable 'Repeat search here' functionality. This property is
***REMOVED******REMOVED***/ observable, and the view should use it to hide and show the 'repeat search' button.
***REMOVED******REMOVED***/ Changes to this property are driven by changes to the `geoViewExtent` property.  This value will be
***REMOVED******REMOVED***/ true if the extent center changes by more than 25% of the average of the extent's height and width
***REMOVED******REMOVED***/ at the time of the last search or if the extent width/height changes by the same amount.
***REMOVED***@Published
***REMOVED***public private(set) var isEligibleForRequery: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The search area to be used for the current query.  Results will be limited to those
***REMOVED******REMOVED***/ within `QueryArea`.  Defaults to `nil`.
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
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Collection of suggestion results. Defaults to `nil`. This collection will be set to empty when there
***REMOVED******REMOVED***/ are no suggestions, `nil` when no suggestions have been requested. If the list is empty,
***REMOVED******REMOVED***/ a useful 'no results' message should be shown by the view.
***REMOVED***
***REMOVED***@Published
***REMOVED***public private(set) var searchOutcome: SearchOutcome? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***switch searchOutcome {
***REMOVED******REMOVED******REMOVED***case .results(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***switch results {
***REMOVED******REMOVED******REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if results.count == 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = results.first
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = nil
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = nil
***REMOVED******REMOVED******REMOVED******REMOVED***break
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
***REMOVED***public var sources: [SearchSource] = []
***REMOVED***
***REMOVED******REMOVED***/ The currently executing async task.  `currentTask` should be cancelled
***REMOVED******REMOVED***/ prior to starting another async task.
***REMOVED***private var currentTask: Task<Void, Never>?
***REMOVED***
***REMOVED******REMOVED***/ Starts a search. `selectedResult` and `results`, among other properties, are set
***REMOVED******REMOVED***/ asynchronously. Other query properties are read to define the parameters of the search.
***REMOVED***public func commitSearch() {
***REMOVED******REMOVED***kickoffTask({ searchTask() ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Repeats the last search, limiting results to the extent specified in `geoViewExtent`.
***REMOVED***public func repeatSearch() {
***REMOVED******REMOVED***kickoffTask({ repeatSearchTask() ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates suggestions list asynchronously.
***REMOVED***public func updateSuggestions() {
***REMOVED******REMOVED***guard currentSuggestion == nil else {
***REMOVED******REMOVED******REMOVED******REMOVED*** don't update suggestions if currently searching for one
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***kickoffTask({ updateSuggestionsTask() ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***@Published
***REMOVED***public var currentSuggestion: SearchSuggestion? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***if let currentSuggestion = currentSuggestion {
***REMOVED******REMOVED******REMOVED******REMOVED***acceptSuggestion(currentSuggestion)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Commits a search from a specific suggestion. Results will be set asynchronously. Behavior is
***REMOVED******REMOVED***/ generally the same as `commitSearch`, except `searchSuggestion` is used instead of the
***REMOVED******REMOVED***/ `currentQuery` property.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - searchSuggestion: The suggestion to use to commit the search.
***REMOVED***public func acceptSuggestion(_ searchSuggestion: SearchSuggestion) {
***REMOVED******REMOVED***currentQuery = searchSuggestion.displayTitle
***REMOVED******REMOVED***kickoffTask({ acceptSuggestionTask(searchSuggestion) ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***private func kickoffTask(_ taskInit: () -> Task<(), Never>) {
***REMOVED******REMOVED***currentTask?.cancel()
***REMOVED******REMOVED***currentTask = taskInit()
***REMOVED***
***REMOVED***

extension SearchViewModel {
***REMOVED***private func repeatSearchTask() -> Task<(), Never> {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***guard !currentQuery.trimmingCharacters(in: .whitespaces).isEmpty,
***REMOVED******REMOVED******REMOVED******REMOVED***  let queryExtent = geoViewExtent,
***REMOVED******REMOVED******REMOVED******REMOVED***  let source = currentSource() else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  return
***REMOVED******REMOVED***  ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***await search(with: {
***REMOVED******REMOVED******REMOVED******REMOVED***try await source.repeatSearch(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentQuery,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchExtent: queryExtent
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** )
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func searchTask() -> Task<(), Never> {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***guard !currentQuery.trimmingCharacters(in: .whitespaces).isEmpty,
***REMOVED******REMOVED******REMOVED******REMOVED***  let source = currentSource() else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***await search(with: {
***REMOVED******REMOVED******REMOVED******REMOVED***try await source.search(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentQuery,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchArea: queryArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preferredSearchLocation: queryCenter
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** )
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func updateSuggestionsTask() -> Task<(), Never> {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***guard !currentQuery.trimmingCharacters(in: .whitespaces).isEmpty,
***REMOVED******REMOVED******REMOVED******REMOVED***  let source = currentSource() else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  return
***REMOVED******REMOVED***  ***REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let suggestions = try await source.suggest(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentQuery,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchArea: queryArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preferredSearchLocation: queryCenter
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***searchOutcome = .suggestions(result: .success(suggestions))
***REMOVED******REMOVED*** catch is CancellationError {
***REMOVED******REMOVED******REMOVED******REMOVED***searchOutcome = nil
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***searchOutcome = .suggestions(result: .failure(SearchError(error)))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func acceptSuggestionTask(_ searchSuggestion: SearchSuggestion) -> Task<(), Never> {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***await search(with: {
***REMOVED******REMOVED******REMOVED******REMOVED***try await searchSuggestion.owningSource.search(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchSuggestion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchArea: queryArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***preferredSearchLocation: queryCenter
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** )
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** once we are done searching for the suggestion, then reset it to nil
***REMOVED******REMOVED******REMOVED***currentSuggestion = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func search(with action: () async throws -> [SearchResult]) async {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED*** User is performing a search, so set `lastSearchExtent`.
***REMOVED******REMOVED******REMOVED***lastSearchExtent = geoViewExtent
***REMOVED******REMOVED******REMOVED***try await process(searchResults: action())
***REMOVED*** catch is CancellationError {
***REMOVED******REMOVED******REMOVED***searchOutcome = nil
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***searchOutcome = .results(result: .failure(SearchError(error)))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func process(searchResults: [SearchResult], isCollection: Bool = true) {
***REMOVED******REMOVED***let effectiveResults: [SearchResult]
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch (resultMode) {
***REMOVED******REMOVED***case .single:
***REMOVED******REMOVED******REMOVED***effectiveResults = Array(searchResults.prefix(1))
***REMOVED******REMOVED***case .multiple:
***REMOVED******REMOVED******REMOVED***effectiveResults = searchResults
***REMOVED******REMOVED***case .automatic:
***REMOVED******REMOVED******REMOVED***if isCollection {
***REMOVED******REMOVED******REMOVED******REMOVED***effectiveResults = searchResults
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***effectiveResults = Array(searchResults.prefix(1))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***searchOutcome = .results(result: .success(effectiveResults))
***REMOVED***
***REMOVED***

extension SearchViewModel {
***REMOVED******REMOVED***/ Returns the search source to be used in geocode operations.
***REMOVED******REMOVED***/ - Returns: The search source to use.
***REMOVED***func currentSource() -> SearchSource? {
***REMOVED******REMOVED***let source: SearchSource?
***REMOVED******REMOVED***if let activeSource = activeSource {
***REMOVED******REMOVED******REMOVED***source = activeSource
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***source = sources.first
***REMOVED***
***REMOVED******REMOVED***return source
***REMOVED***
***REMOVED***

extension SearchViewModel.SearchOutcome: Equatable {***REMOVED***
