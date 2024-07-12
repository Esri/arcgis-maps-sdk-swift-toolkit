***REMOVED***
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

***REMOVED***/ `SearchView` enables searching using one or more locators, with support for suggestions,
***REMOVED***/ automatic zooming, and custom search sources.
***REMOVED***/
***REMOVED***/ | iPhone | iPad |
***REMOVED***/ | ------ | ---- |
***REMOVED***/ | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203608897-5f3bf34a-0931-4d11-b3fc-18a5dd07131a.png) | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203608708-45a0096c-a8d6-457c-9ee1-8cdb9e5bb15a.png) |
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ - Updates search suggestions as you type.
***REMOVED***/ - Supports using the Esri world geocoder or any other ArcGIS locators.
***REMOVED***/ - Supports searching using custom search sources.
***REMOVED***/ - Allows for customization of the display of search results.
***REMOVED***/ - Allows you to repeat a search within a defined area, and displays a button to enable that
***REMOVED***/ search when the view's viewpoint changes.
***REMOVED***/
***REMOVED***/ `SearchView` uses search sources which implement the ``SearchSource`` protocol.
***REMOVED***/
***REMOVED***/ `SearchView` provides the following search sources:
***REMOVED***/
***REMOVED***/ - ``LocatorSearchSource``
***REMOVED***/ - ``SmartLocatorSearchSource``
***REMOVED***/
***REMOVED***/ `SearchView` provides several instance methods, allowing customization and additional search
***REMOVED***/ behaviors (such as displaying a "Repeat search here" button). See "Instance Methods" below.
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ The `SearchView` will display the results list view at half height, exposing a portion of the
***REMOVED***/ underlying map below the list, in compact environments. The user can hide or show the result
***REMOVED***/ list after searching by clicking on the up/down chevron symbol on the right of the search bar.
***REMOVED***/
***REMOVED***/ **Associated Types**
***REMOVED***/
***REMOVED***/ `SearchView` has the following associated types:
***REMOVED***/
***REMOVED***/ - ``SearchField``
***REMOVED***/ - ``SearchResult``
***REMOVED***/ - ``SearchSuggestion``
***REMOVED***/ - ``SearchOutcome``
***REMOVED***/ - ``SearchResultMode``
***REMOVED***/
***REMOVED***/ To see the `SearchView` in action, and for examples of `Search` customization, check out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [SearchExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/SearchExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `SearchView` see the <doc:SearchViewTutorial>.
@MainActor
@preconcurrency
public struct SearchView: View {
***REMOVED******REMOVED***/ Creates a `SearchView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - sources: A collection of search sources to be used.
***REMOVED******REMOVED***/   - viewpoint: The `Viewpoint` used to pan/zoom to results. If `nil`, there will be
***REMOVED******REMOVED***/   no zooming to results.
***REMOVED******REMOVED***/   - geoViewProxy: The proxy to provide access to geo view operations.
***REMOVED***public init(
***REMOVED******REMOVED***sources: [SearchSource] = [],
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil,
***REMOVED******REMOVED***geoViewProxy: GeoViewProxy? = nil
***REMOVED***) {
***REMOVED******REMOVED***_viewModel = StateObject(wrappedValue: SearchViewModel(
***REMOVED******REMOVED******REMOVED***sources: sources.isEmpty ? [LocatorSearchSource()] : sources,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED***geoViewProxy: geoViewProxy
***REMOVED******REMOVED***))
***REMOVED******REMOVED***
***REMOVED******REMOVED***_queryArea = .constant(nil)
***REMOVED******REMOVED***_queryCenter = .constant(nil)
***REMOVED******REMOVED***_geoViewExtent = .constant(nil)
***REMOVED******REMOVED***_isGeoViewNavigating = .constant(false)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `SearchViewModel` manages state and handles the
***REMOVED******REMOVED***/ activity of searching. The view observes `SearchViewModel` for changes in state. The view
***REMOVED******REMOVED***/ calls methods on `SearchViewModel` in response to user action.
***REMOVED***@StateObject private var viewModel: SearchViewModel

***REMOVED******REMOVED***/ Tracks the current user-entered query. This property drives both suggestions and searches.
***REMOVED***var currentQuery = ""

***REMOVED******REMOVED***/ Tracks the current user-entered query. This property drives both suggestions and searches.
***REMOVED***var resultMode: SearchResultMode = .automatic

***REMOVED******REMOVED***/ The search area to be used for the current query. If `nil`, then there is no limiting of the
***REMOVED******REMOVED***/ search results to a given area.
***REMOVED***@Binding var queryArea: Geometry?

***REMOVED******REMOVED***/ Defines the center for the search. Defaults to `nil`.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ If `nil`, does not prioritize the search results around any point.
***REMOVED***@Binding var queryCenter: Point?
***REMOVED***
***REMOVED******REMOVED***/ A closure performed when the query has changed.
***REMOVED***private var onQueryChangedAction: ((String) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The current map/scene view extent. Defaults to `nil`.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This will be used to determine the value of `isEligibleForRequery` for the 'Repeat
***REMOVED******REMOVED***/ search here' behavior. If that behavior is not wanted, it should be left as `nil`.
***REMOVED***@Binding var geoViewExtent: Envelope?
***REMOVED***
***REMOVED******REMOVED***/ Determines whether the `geoView` is navigating in response to user interaction.
***REMOVED***@Binding private var isGeoViewNavigating: Bool

***REMOVED******REMOVED***/ The `GraphicsOverlay` used to display results. If `nil`, no results will be displayed.
***REMOVED***var resultsOverlay: GraphicsOverlay? = nil
***REMOVED***
***REMOVED******REMOVED***/ A collection of search sources to be used. This list is maintained over time.
***REMOVED******REMOVED***/ The view should observe this list for changes. Consumers should add and remove sources from
***REMOVED******REMOVED***/ this list as needed.
***REMOVED******REMOVED***/ NOTE: Only the first source is currently used; multiple sources are not yet supported.
***REMOVED***var sources: [SearchSource] {
***REMOVED******REMOVED***viewModel.sources
***REMOVED***
***REMOVED***
***REMOVED***@Environment(\.isPortraitOrientation) var isPortraitOrientation
***REMOVED***
***REMOVED******REMOVED***/ The string shown in the search view when no user query is entered.
***REMOVED******REMOVED***/ Defaults to "Find a place or address". Note: this is set using the
***REMOVED******REMOVED***/ `prompt` modifier.
***REMOVED***private var prompt = String(
***REMOVED******REMOVED***localized: "Find a place or address",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "A hint for the user on what to search for in a search bar."
***REMOVED***)
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
***REMOVED***private var noResultsMessage = String(
***REMOVED******REMOVED***localized: "No results found",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "A message to show when there are no results or suggestions."
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The width of the search bar, taking into account the horizontal and vertical size classes
***REMOVED******REMOVED***/ of the device. This will cause the search field to display full-width on an iPhone in portrait
***REMOVED******REMOVED***/ orientation (and certain iPad multitasking configurations) and limit the width to `360` in other cases.
***REMOVED***private var searchBarWidth: CGFloat? {
***REMOVED******REMOVED***isPortraitOrientation ? nil : 360
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ If `true`, will draw the results list view at half height, exposing a portion of the
***REMOVED******REMOVED***/ underlying map below the list on an iPhone in portrait orientation (and certain iPad multitasking
***REMOVED******REMOVED***/ configurations).  If `false`, will draw the results list view full size.
***REMOVED***private var useHalfHeightResults: Bool {
***REMOVED******REMOVED***isPortraitOrientation
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines whether the results lists are displayed.
***REMOVED***@State private var isResultListHidden = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the search field is focused or not.
***REMOVED***@FocusState private var searchFieldIsFocused: Bool
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused: $searchFieldIsFocused,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isResultsButtonHidden: !enableResultListView,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isResultListHidden: $isResultListHidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { viewModel.commitSearch() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.submitLabel(.search)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: useHalfHeightResults ? geometry.size.height / 2 : nil)
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
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.repeatSearch()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Repeat Search Here",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  A label for button to show when the user has panned the map away
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  from the original search location. 'Here' is in reference to the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  current visible extent of the map or scene.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED***.onReceive(viewModel.$currentQuery) { _ in
***REMOVED******REMOVED******REMOVED***onQueryChangedAction?(viewModel.currentQuery)
***REMOVED******REMOVED******REMOVED***viewModel.updateSuggestions()
***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewModel.selectedResult) { _ in
***REMOVED******REMOVED******REMOVED***searchFieldIsFocused = false
***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewModel.currentSuggestion) { _ in
***REMOVED******REMOVED******REMOVED***searchFieldIsFocused = false
***REMOVED***
***REMOVED******REMOVED***.onChange(of: geoViewExtent) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.geoViewExtent = geoViewExtent
***REMOVED***
***REMOVED******REMOVED***.onChange(of: isGeoViewNavigating) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.isGeoViewNavigating = isGeoViewNavigating
***REMOVED***
***REMOVED******REMOVED***.onChange(of: queryCenter) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.queryCenter = queryCenter
***REMOVED***
***REMOVED******REMOVED***.onChange(of: queryArea) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.queryArea = queryArea
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***viewModel.currentQuery = currentQuery
***REMOVED******REMOVED******REMOVED***viewModel.resultsOverlay = resultsOverlay
***REMOVED******REMOVED******REMOVED***viewModel.resultMode = resultMode
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
***REMOVED******REMOVED***/ Sets the current query.
***REMOVED******REMOVED***/ - Parameter newQueryString: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func currentQuery(_ newQuery: String) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.currentQuery = newQuery
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a closure to perform when the query changes.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - action: The closure to performed when the query has changed.
***REMOVED******REMOVED***/   - query: The new query.
***REMOVED***public func onQueryChanged(perform action: @escaping (_ query: String) -> Void) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onQueryChangedAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `GraphicsOverlay` used to display results. If `nil`, no results will be displayed.
***REMOVED******REMOVED***/ - Parameter newResultsOverlay: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func resultsOverlay(_ newResultsOverlay: GraphicsOverlay?) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.resultsOverlay = newResultsOverlay
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Defines how many results to return.
***REMOVED******REMOVED***/ - Parameter newResultMode: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func resultMode(_ newResultMode: SearchResultMode) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.resultMode = newResultMode
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The search area to be used for the current query.
***REMOVED******REMOVED***/ - Parameter newQueryArea: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func queryArea(_ newQueryArea: Binding<Geometry?>) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy._queryArea = newQueryArea
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Defines the center for the search.
***REMOVED******REMOVED***/ - Parameter newQueryCenter: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func queryCenter(_ newQueryCenter: Binding<Point?>) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy._queryCenter = newQueryCenter
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current map/scene view extent. Defaults to `nil`. Used to allow repeat searches after
***REMOVED******REMOVED***/ panning/zooming the map. Set to `nil` if repeat search behavior is not wanted.
***REMOVED******REMOVED***/ - Parameter newGeoViewExtent: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func geoViewExtent(_ newGeoViewExtent: Binding<Envelope?>) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy._geoViewExtent = newGeoViewExtent
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Denotes whether the `GeoView` is navigating. Used for the repeat search behavior.
***REMOVED******REMOVED***/ - Parameter newIsGeoViewNavigating: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func isGeoViewNavigating(_ newIsGeoViewNavigating: Binding<Bool>) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy._isGeoViewNavigating = newIsGeoViewNavigating
***REMOVED******REMOVED***return copy
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
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***in: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: nil
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
