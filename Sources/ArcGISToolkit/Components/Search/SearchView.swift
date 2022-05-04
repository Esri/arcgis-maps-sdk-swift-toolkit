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
***REMOVED******REMOVED***/ Creates a `SearchView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - queryArea: The search area to be used for the current query.
***REMOVED******REMOVED***/   - queryCenter: Defines the center for the search.
***REMOVED******REMOVED***/   - resultMode: Defines how many results to return.
***REMOVED******REMOVED***/   - sources: Collection of search sources to be used.
***REMOVED***public init(
***REMOVED******REMOVED***queryArea: Geometry? = nil,
***REMOVED******REMOVED***queryCenter: Point? = nil,
***REMOVED******REMOVED***resultMode: SearchResultMode = .automatic,
***REMOVED******REMOVED***sources: [SearchSource] = []
***REMOVED***) {
***REMOVED******REMOVED***_viewModel = StateObject(wrappedValue: SearchViewModel(
***REMOVED******REMOVED******REMOVED***queryArea: queryArea,
***REMOVED******REMOVED******REMOVED***queryCenter: queryCenter,
***REMOVED******REMOVED******REMOVED***resultMode: resultMode,
***REMOVED******REMOVED******REMOVED***sources: sources.isEmpty ? [LocatorSearchSource()] : sources
***REMOVED******REMOVED***))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `SearchViewModel` manages state and handles the
***REMOVED******REMOVED***/ activity of searching. The view observes `SearchViewModel` for changes in state. The view
***REMOVED******REMOVED***/ calls methods on `SearchViewModel` in response to user action.
***REMOVED***@StateObject private var viewModel: SearchViewModel

***REMOVED******REMOVED***/ Tracks the current user-entered query. This property drives both suggestions and searches.
***REMOVED***public var currentQuery: String {
***REMOVED******REMOVED***viewModel.currentQuery
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current map/scene view extent. Defaults to `nil`.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This should be updated via `geoViewExtent(:)`as the user navigates the map/scene. It will be
***REMOVED******REMOVED***/ used to determine the value of `isEligibleForRequery` for the 'Repeat
***REMOVED******REMOVED***/ search here' behavior. If that behavior is not wanted, it should be left `nil`.
***REMOVED***public var geoViewExtent: Envelope? {
***REMOVED******REMOVED***viewModel.geoViewExtent
***REMOVED***

***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to results. If `nil`, there will be no zooming to results.
***REMOVED***public var viewpoint: Binding<Viewpoint?>? {
***REMOVED******REMOVED***viewModel.viewpoint
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `GraphicsOverlay` used to display results. If `nil`, no results will be displayed.
***REMOVED***public var resultsOverlay: GraphicsOverlay? {
***REMOVED******REMOVED***viewModel.resultsOverlay
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The search area to be used for the current query. Results will be limited to those.
***REMOVED******REMOVED***/ within `QueryArea`. Defaults to `nil`.
***REMOVED***public var queryArea: Geometry? {
***REMOVED******REMOVED***viewModel.queryArea
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Defines the center for the search. For most use cases, this should be updated by the view
***REMOVED******REMOVED***/ every time the user navigates the map.
***REMOVED***public var queryCenter: Point? {
***REMOVED******REMOVED***viewModel.queryCenter
***REMOVED***

***REMOVED******REMOVED***/ Defines how many results to return. Defaults to Automatic. In automatic mode, an appropriate
***REMOVED******REMOVED***/ number of results is returned based on the type of suggestion chosen
***REMOVED******REMOVED***/ (driven by the suggestion's `isCollection` property).
***REMOVED***public var resultMode: SearchResultMode {
***REMOVED******REMOVED***viewModel.resultMode
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The collection of search and suggestion results. A `nil` value means no query has been made.
***REMOVED***var searchOutcome: SearchOutcome? {
***REMOVED******REMOVED***viewModel.searchOutcome
***REMOVED***

***REMOVED******REMOVED***/ Tracks selection of results from the `results` collection. When there is only one result,
***REMOVED******REMOVED***/ that result is automatically assigned to this property. If there are multiple results, the view sets
***REMOVED******REMOVED***/ this property upon user selection. This property is observable. The view should observe this
***REMOVED******REMOVED***/ property and update the associated GeoView's viewpoint, if configured.
***REMOVED***public var selectedResult: SearchResult? {
***REMOVED******REMOVED***viewModel.selectedResult
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Collection of search sources to be used. This list is maintained over time and is not nullable.
***REMOVED******REMOVED***/ The view should observe this list for changes. Consumers should add and remove sources from
***REMOVED******REMOVED***/ this list as needed.
***REMOVED******REMOVED***/ NOTE: Only the first source is currently used; multiple sources are not yet supported.
***REMOVED***public var sources: [SearchSource] {
***REMOVED******REMOVED***viewModel.sources
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The suggestion currently selected by the user.
***REMOVED***public var currentSuggestion: SearchSuggestion? {
***REMOVED******REMOVED***viewModel.currentSuggestion
***REMOVED***
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass) var horizontalSizeClass
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass

***REMOVED******REMOVED***/ The string shown in the search view when no user query is entered.
***REMOVED******REMOVED***/ Defaults to "Find a place or address". Note: this is set using the
***REMOVED******REMOVED***/ `prompt` modifier.
***REMOVED***private var prompt: String = "Find a place or address"
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a built-in result view will be shown. Defaults to `true`.
***REMOVED******REMOVED***/ If `false`, the result display/selection list is not shown. Set to false if you want to hide the results
***REMOVED******REMOVED***/ or define a custom result list. You might use a custom result list to show results in a separate list,
***REMOVED******REMOVED***/ disconnected from the rest of the search view.
***REMOVED******REMOVED***/ Note: this is set using the `enableResultListView` modifier.
***REMOVED***private var enableResultListView = true
***REMOVED***
***REMOVED******REMOVED***/ Message to show when there are no results or suggestions. Defaults to "No results found".
***REMOVED******REMOVED***/ Note: this is set using the `noResultsMessage` modifier.
***REMOVED***private var noResultsMessage = "No results found"

***REMOVED******REMOVED***/ The width of the search bar, taking into account the horizontal and vertical size classes
***REMOVED******REMOVED***/ of the device. This will cause the search field to display full-width on an iPhone in portrait
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
***REMOVED***@State private var isResultListHidden: Bool = false
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchField(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***query: $viewModel.currentQuery,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***prompt: prompt,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isResultsButtonHidden: !enableResultListView,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isResultListHidden: $isResultListHidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { viewModel.commitSearch() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.submitLabel(.search)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if enableResultListView,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   !isResultListHidden,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let searchOutcome = viewModel.searchOutcome {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch searchOutcome {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .results(let results):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchResultList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchResults: results,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult: $viewModel.selectedResult,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noResultsMessage: noResultsMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: useHalfHeightResults ? geometry.size.height / 2 : nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .suggestions(let suggestions):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchSuggestionList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***suggestionResults: suggestions,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion: $viewModel.currentSuggestion,
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
***REMOVED******REMOVED******REMOVED***if viewModel.isEligibleForRequery {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Repeat Search Here") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.repeatSearch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED***.onReceive(viewModel.$currentQuery) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.updateSuggestions()
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

***REMOVED******REMOVED***/ Sets the current query.
***REMOVED******REMOVED***/ - Parameter newQueryString: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func currentQuery(_ newQuery: String) -> Self {
***REMOVED******REMOVED***viewModel.currentQuery = newQuery
***REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current map/scene view extent. Defaults to `nil`.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This should be updated as the user navigates the map/scene. It will be
***REMOVED******REMOVED***/ used to determine the value of `isEligibleForRequery` for the 'Repeat
***REMOVED******REMOVED***/ search here' behavior. If that behavior is not wanted, it should be left `nil`.
***REMOVED******REMOVED***/ - Parameter newExtent: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func geoViewExtent(_ newExtent: Envelope?) -> Self {
***REMOVED******REMOVED***viewModel.geoViewExtent = newExtent
***REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ `true` when the geoView is navigating, `false` otherwise. Set by the external client.
***REMOVED******REMOVED***/ - Parameter newIsGeoViewNavigating: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func isGeoViewNavigating(_ newIsGeoViewNavigating: Bool) -> Self {
***REMOVED******REMOVED***viewModel.isGeoViewNavigating = newIsGeoViewNavigating
***REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to results. If `nil`, there will be no zooming to results.
***REMOVED******REMOVED***/ - Parameter newViewpoint: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func viewpoint(_ newViewpoint: Binding<Viewpoint?>?) -> Self {
***REMOVED******REMOVED***viewModel.viewpoint = newViewpoint
***REMOVED******REMOVED***return self
***REMOVED***

***REMOVED******REMOVED***/ The `GraphicsOverlay` used to display results. If `nil`, no results will be displayed.
***REMOVED******REMOVED***/ - Parameter newResultsOverlay: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func resultsOverlay(_ newResultsOverlay: GraphicsOverlay?) -> Self {
***REMOVED******REMOVED***viewModel.resultsOverlay = newResultsOverlay
***REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***

***REMOVED***/ A View displaying the list of search results.
struct SearchResultList: View {
***REMOVED******REMOVED***/ The array of search results to display.
***REMOVED***var searchResults: [SearchResult]
***REMOVED******REMOVED***/ The result the user selects.
***REMOVED***@Binding var selectedResult: SearchResult?
***REMOVED******REMOVED***/ The message to display when there are no results.
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

***REMOVED***/ A View displaying the list of search suggestion results.
struct SearchSuggestionList: View {
***REMOVED******REMOVED***/ The array of suggestion results to display.
***REMOVED***var suggestionResults: [SearchSuggestion]
***REMOVED******REMOVED***/ The suggestion the user selects.
***REMOVED***@Binding var currentSuggestion: SearchSuggestion?
***REMOVED******REMOVED***/ The message to display when there are no results.
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

***REMOVED***/ A View displaying the "no results" message when there are no search or suggestion results.
struct NoResultsView: View {
***REMOVED******REMOVED***/ The message to display when there are no results.
***REMOVED***var message: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***LazyVStack {
***REMOVED******REMOVED******REMOVED***Text(message)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view representing a row containing one search or suggestion result.
struct ResultRow: View {
***REMOVED******REMOVED***/ The title of the result.
***REMOVED***var title: String
***REMOVED******REMOVED***/ Additional result information, if available.
***REMOVED***var subtitle: String = ""
***REMOVED******REMOVED***/ The image to display for the result.
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
***REMOVED***
***REMOVED***

extension ResultRow {
***REMOVED******REMOVED***/ Creates a `ResultRow` from a search suggestion.
***REMOVED******REMOVED***/ - Parameter searchSuggestion: The search suggestion displayed in the row.
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
***REMOVED******REMOVED***/ Creates a `ResultRow` from a search result.
***REMOVED******REMOVED***/ - Parameter searchResult: The search result displayed in the view.
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
