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
import Combine
***REMOVED***

***REMOVED***/ SearchView presents a search experience, powered by an underlying SearchViewModel.
public struct SearchView: View {
***REMOVED***public init(searchViewModel: SearchViewModel? = nil) {
***REMOVED******REMOVED***if let searchViewModel = searchViewModel {
***REMOVED******REMOVED******REMOVED***self.searchViewModel = searchViewModel
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***self.searchViewModel = SearchViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***sources: [LocatorSearchSource()]
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `SearchViewModel` manages state and handles the
***REMOVED******REMOVED***/ activity of searching. The view observes `SearchViewModel` for changes in state. The view
***REMOVED******REMOVED***/ calls methods on `SearchViewModel` in response to user action.
***REMOVED***@ObservedObject
***REMOVED***var searchViewModel: SearchViewModel
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a built-in result view will be shown. Defaults to true.
***REMOVED******REMOVED***/ If false, the result display/selection list is not shown. Set to false if you want to hide the results
***REMOVED******REMOVED***/ or define a custom result list. You might use a custom result list to show results in a separate list,
***REMOVED******REMOVED***/ disconnected from the rest of the search view.
***REMOVED***private var enableResultListView = true
***REMOVED***
***REMOVED******REMOVED***/ Message to show when there are no results or suggestions.  Defaults to "No results found".
***REMOVED***private var noResultMessage = "No results found"
***REMOVED***
***REMOVED******REMOVED***/ Indicates that the `SearchViewModel` should start a search.
***REMOVED***@State
***REMOVED***private var shouldCommitSearch = false
***REMOVED***
***REMOVED******REMOVED***/ The current suggestion selected by the user.
***REMOVED***@State
***REMOVED***private var currentSuggestion: SearchSuggestion?
***REMOVED***
***REMOVED******REMOVED***/ Determines whether the results lists are displayed.
***REMOVED***@State
***REMOVED***private var isResultDisplayHidden: Bool = false
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack (alignment: .center) {
***REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.defaultPlaceholder,
***REMOVED******REMOVED******REMOVED******REMOVED***text: $searchViewModel.currentQuery
***REMOVED******REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED*** onCommit: {
***REMOVED******REMOVED******REMOVED******REMOVED***shouldCommitSearch = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.esriDeleteTextButton(text: $searchViewModel.currentQuery)
***REMOVED******REMOVED******REMOVED***.esriSearchButton(performSearch: $shouldCommitSearch)
***REMOVED******REMOVED******REMOVED***.esriShowResultsButton(
***REMOVED******REMOVED******REMOVED******REMOVED***isEnabled: !enableResultListView,
***REMOVED******REMOVED******REMOVED******REMOVED***isHidden: $isResultDisplayHidden
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED***if enableResultListView, !isResultDisplayHidden {
***REMOVED******REMOVED******REMOVED******REMOVED***SearchResultList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchResults: searchViewModel.results,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult: $searchViewModel.selectedResult,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noResultMessage: noResultMessage
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***SearchSuggestionList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***suggestionResults: searchViewModel.suggestions,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion: $currentSuggestion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noResultMessage: noResultMessage
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***.task(id: searchViewModel.currentQuery) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** User typed a new character
***REMOVED******REMOVED******REMOVED******REMOVED***if currentSuggestion == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await searchViewModel.updateSuggestions()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task(id: shouldCommitSearch) {
***REMOVED******REMOVED******REMOVED******REMOVED***if shouldCommitSearch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** User committed changes (hit Enter/Search button)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await searchViewModel.commitSearch()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***shouldCommitSearch.toggle()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task(id: currentSuggestion) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let suggestion = currentSuggestion {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** User selected a suggestion.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await searchViewModel.acceptSuggestion(suggestion)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Modifiers
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a built-in result view will be shown. If `false`, the result display/selection
***REMOVED******REMOVED***/ list is not shown. Set to `false` if you want to define a custom result list. You might use a
***REMOVED******REMOVED***/ custom result list to show results in a separate list, disconnected from the rest of the search view.
***REMOVED******REMOVED***/ Defaults to `true`.
***REMOVED******REMOVED***/ - Parameter enableResultListView: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func enableResultListView(_ enableResultListView: Bool) -> SearchView {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.enableResultListView = enableResultListView
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Message to show when there are no results or suggestions.  Defaults to "No results found".
***REMOVED******REMOVED***/ - Parameter noResultMessage: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func noResultMessage(_ noResultMessage: String) -> SearchView {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.noResultMessage = noResultMessage
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

struct SearchResultList: View {
***REMOVED***var searchResults: Result<[SearchResult]?, SearchError>
***REMOVED***@Binding var selectedResult: SearchResult?
***REMOVED***var noResultMessage: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch searchResults {
***REMOVED******REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***if let results = results, results.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if results.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Only show the list if we have more than one result.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PlainList {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(results) { result in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchResultRow(result: result)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = result
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else if results != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PlainList {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(noResultMessage)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***PlainList {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder(edgeInsets: EdgeInsets())
***REMOVED***
***REMOVED***

struct SearchSuggestionList: View {
***REMOVED***var suggestionResults: Result<[SearchSuggestion]?, SearchError>
***REMOVED***@Binding var currentSuggestion: SearchSuggestion?
***REMOVED***var noResultMessage: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch suggestionResults {
***REMOVED******REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***if let suggestions = results, suggestions.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PlainList {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if suggestions.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(suggestions) { suggestion in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SuggestionResultRow(suggestion: suggestion)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion = suggestion
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else if results != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PlainList {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(noResultMessage)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***PlainList {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(error.errorDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder(edgeInsets: EdgeInsets())
***REMOVED***
***REMOVED***

struct SearchResultRow: View {
***REMOVED***var result: SearchResult
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Image(systemName: "mappin")
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(.red))
***REMOVED******REMOVED******REMOVED***ResultRow(
***REMOVED******REMOVED******REMOVED******REMOVED***title: result.displayTitle,
***REMOVED******REMOVED******REMOVED******REMOVED***subtitle: result.displaySubtitle
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

struct SuggestionResultRow: View {
***REMOVED***var suggestion: SearchSuggestion
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***let imageName = suggestion.isCollection ? "magnifyingglass" : "mappin"
***REMOVED******REMOVED******REMOVED***Image(systemName: imageName)
***REMOVED******REMOVED******REMOVED***ResultRow(
***REMOVED******REMOVED******REMOVED******REMOVED***title: suggestion.displayTitle,
***REMOVED******REMOVED******REMOVED******REMOVED***subtitle: suggestion.displaySubtitle
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

struct ResultRow: View {
***REMOVED***var title: String
***REMOVED***var subtitle: String?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack (alignment: .leading){
***REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.callout)
***REMOVED******REMOVED******REMOVED***if let subtitle = subtitle {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(subtitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
