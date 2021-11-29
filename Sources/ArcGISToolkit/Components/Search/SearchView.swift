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

***REMOVED***/ `SearchView` presents a search experience, powered by an underlying `SearchViewModel`.
public struct SearchView: View {
***REMOVED******REMOVED***/ Creates a new `SearchView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - searchViewModel: The view model used by `SearchView`.
***REMOVED***public init(searchViewModel: SearchViewModel? = nil) {
***REMOVED******REMOVED***self.searchViewModel = searchViewModel ?? SearchViewModel(
***REMOVED******REMOVED******REMOVED***sources: [LocatorSearchSource()]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `SearchViewModel` manages state and handles the
***REMOVED******REMOVED***/ activity of searching. The view observes `SearchViewModel` for changes in state. The view
***REMOVED******REMOVED***/ calls methods on `SearchViewModel` in response to user action.
***REMOVED***@ObservedObject
***REMOVED***var searchViewModel: SearchViewModel
***REMOVED***
***REMOVED******REMOVED***/ The string shown in the search view when no user query is entered.
***REMOVED******REMOVED***/ Defaults to "Find a place or address". Note: this is set using the
***REMOVED******REMOVED***/ `prompt` modifier.
***REMOVED***private var prompt: String = "Find a place or address"
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a built-in result view will be shown. Defaults to true.
***REMOVED******REMOVED***/ If false, the result display/selection list is not shown. Set to false if you want to hide the results
***REMOVED******REMOVED***/ or define a custom result list. You might use a custom result list to show results in a separate list,
***REMOVED******REMOVED***/ disconnected from the rest of the search view.
***REMOVED******REMOVED***/ Note: this is set using the `enableResultListView` modifier.
***REMOVED***private var enableResultListView = true
***REMOVED***
***REMOVED******REMOVED***/ Message to show when there are no results or suggestions. Defaults to "No results found".
***REMOVED******REMOVED***/ Note: this is set using the `noResultsMessage` modifier.
***REMOVED***private var noResultsMessage = "No results found"
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED***@Environment(\.verticalSizeClass)
***REMOVED***private var verticalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED******REMOVED***/ The width of the search bar, taking into account the horizontal and vertical size classes
***REMOVED******REMOVED***/ of the device.  This will cause the search field to display full-width on an iPhone in portrait
***REMOVED******REMOVED***/ orientation (and certain iPad multitasking configurations) and limit the width to `360` in other cases.
***REMOVED***private var searchBarWidth: CGFloat? {
***REMOVED******REMOVED***horizontalSizeClass == .compact && verticalSizeClass == .regular ? nil : 360
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ If `true`, will draw the results list view at half height, exposing a portion of the
***REMOVED******REMOVED***/ underlying map below the list on an iPhone in portrait orientation (and certain iPad multitasking
***REMOVED******REMOVED***/ configurations).  If `false`, will draw the results list view full size.
***REMOVED***private var useHalfHeightResults: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .compact && verticalSizeClass == .regular
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines whether the results lists are displayed.
***REMOVED***@State
***REMOVED***private var isResultListHidden: Bool = false
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchField(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***query: $searchViewModel.currentQuery,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***prompt: prompt,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isResultsButtonHidden: !enableResultListView,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isResultListHidden: $isResultListHidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { searchViewModel.commitSearch() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.submitLabel(.search)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if enableResultListView,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   !isResultListHidden,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let searchOutcome = searchViewModel.searchOutcome {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch searchOutcome {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .results(let results):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchResultList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchResults: results,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult: $searchViewModel.selectedResult,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noResultsMessage: noResultsMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: useHalfHeightResults ? geometry.size.height / 2 : nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .suggestions(let suggestions):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchSuggestionList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***suggestionResults: suggestions,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion: $searchViewModel.currentSuggestion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noResultsMessage: noResultsMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .failure(let errorString):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(errorString)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder(padding: EdgeInsets())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: searchBarWidth)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if searchViewModel.isEligibleForRequery {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Repeat Search Here") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.repeatSearch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED***.onReceive(searchViewModel.$currentQuery) { _ in
***REMOVED******REMOVED******REMOVED***searchViewModel.updateSuggestions()
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Modifiers
extension SearchView {
***REMOVED******REMOVED***/ Specifies whether a built-in result view will be shown. If `false`, the result display/selection
***REMOVED******REMOVED***/ list is not shown. Set to `false` if you want to define a custom result list. You might use a
***REMOVED******REMOVED***/ custom result list to show results in a separate list, disconnected from the rest of the search view.
***REMOVED******REMOVED***/ Defaults to `true`.
***REMOVED******REMOVED***/ - Parameter newEnableResultListView: The new value.
***REMOVED******REMOVED***/ - Returns: A new `SearchView`.
***REMOVED***public func enableResultListView(_ newEnableResultListView: Bool) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.enableResultListView = newEnableResultListView
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The string shown in the search view when no user query is entered.
***REMOVED******REMOVED***/ Defaults to "Find a place or address".
***REMOVED******REMOVED***/ - Parameter newPrompt: The new value.
***REMOVED******REMOVED***/ - Returns: A new `SearchView`.
***REMOVED***public func prompt(_ newPrompt: String) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.prompt = newPrompt
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the message to show when there are no results or suggestions.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The default message is "No results found".
***REMOVED******REMOVED***/ - Parameter newNoResultsMessage: The new value.
***REMOVED******REMOVED***/ - Returns: A new `SearchView`.
***REMOVED***public func noResultsMessage(_ newNoResultsMessage: String) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.noResultsMessage = newNoResultsMessage
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

struct SearchResultList: View {
***REMOVED***var searchResults: [SearchResult]
***REMOVED***@Binding var selectedResult: SearchResult?
***REMOVED***var noResultsMessage: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if searchResults.count != 1 {
***REMOVED******REMOVED******REMOVED***if searchResults.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Only show the list if we have more than one result.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(searchResults) { result in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ResultRow(searchResult: result)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = result
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.selected(result == selectedResult)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else if searchResults.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***NoResultsView(message: noResultsMessage)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

struct SearchSuggestionList: View {
***REMOVED***var suggestionResults: [SearchSuggestion]
***REMOVED***@Binding var currentSuggestion: SearchSuggestion?
***REMOVED***var noResultsMessage: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if !suggestionResults.isEmpty {
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(suggestionResults) { suggestion in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ResultRow(searchSuggestion: suggestion)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion = suggestion
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***NoResultsView(message: noResultsMessage)
***REMOVED***
***REMOVED***
***REMOVED***

struct NoResultsView: View {
***REMOVED***var message: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***LazyVStack {
***REMOVED******REMOVED******REMOVED***Text(message)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***

struct ResultRow: View {
***REMOVED***var title: String
***REMOVED***var subtitle: String = ""
***REMOVED***var image: AnyView
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***image
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.callout)
***REMOVED******REMOVED******REMOVED******REMOVED***if !subtitle.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(subtitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
***REMOVED***
***REMOVED***

extension ResultRow {
***REMOVED***init(searchSuggestion: SearchSuggestion) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: searchSuggestion.displayTitle,
***REMOVED******REMOVED******REMOVED***subtitle: searchSuggestion.displaySubtitle,
***REMOVED******REMOVED******REMOVED***image: AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED***(searchSuggestion.isCollection ?
***REMOVED******REMOVED******REMOVED******REMOVED*** Image(systemName: "magnifyingglass") :
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***uiImage: UIImage(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***named: "pin",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***in: Bundle.module, with: nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***init(searchResult: SearchResult) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: searchResult.displayTitle,
***REMOVED******REMOVED******REMOVED***subtitle: searchResult.displaySubtitle,
***REMOVED******REMOVED******REMOVED***image: AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: UIImage.mapPin)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.scaleEffect(0.65)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ A modifier which displays a 2 point width border and a shadow around a view.
struct SelectedModifier: ViewModifier {
***REMOVED***var isSelected: Bool
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***let roundedRect = RoundedRectangle(cornerRadius: 4)
***REMOVED******REMOVED***if isSelected {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***.background(Color.secondary.opacity(0.8))
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(roundedRect)
***REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: Color.secondary.opacity(0.8),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: 2
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***content
***REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED***func selected(
***REMOVED******REMOVED***_ isSelected: Bool = false
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(SelectedModifier(isSelected: isSelected))
***REMOVED***
***REMOVED***
