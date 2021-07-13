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

***REMOVED***/ SearchView presents a search experience, powered by underlying SearchViewModel.
public struct SearchView: View {
***REMOVED***public init(proxy: GeoViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel: SearchViewModel,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.proxy = proxy
***REMOVED******REMOVED***self.searchViewModel = searchViewModel
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Used for accessing `GeoView` functionality for geocoding and searching.
***REMOVED******REMOVED***/ Reference to the GeoView used for automatic configuration.
***REMOVED******REMOVED***/ When connected to a GeoView, SearchView will automatically navigate the view in response to
***REMOVED******REMOVED***/ search result changes. Additionally, the view's current center and extent will be automatically
***REMOVED******REMOVED***/ provided to locators as parameters.
***REMOVED***var proxy: GeoViewProxy
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `ViewModel` manages state and handles the activity of
***REMOVED******REMOVED***/ searching. The view observes `ViewModel` for changes in state. The view calls methods on
***REMOVED******REMOVED***/ `ViewModel` in response to user action. The `ViewModel` is created automatically by the
***REMOVED******REMOVED***/ view upon construction. If `enableAutomaticConfiguration` is true, the view calls
***REMOVED******REMOVED***/ `SearchViewModel.ConfigureForMap` for the map/scene whenever it changes. Both
***REMOVED******REMOVED***/ the associated `GeoView` and the `GeoView`'s document can change after initial configuration.
***REMOVED***@ObservedObject
***REMOVED***var searchViewModel: SearchViewModel
***REMOVED***
***REMOVED***private var enableAutomaticConfiguration = true
***REMOVED***
***REMOVED***@State
***REMOVED***private var enableRepeatSearchHereButton = true
***REMOVED***
***REMOVED***@State
***REMOVED***private var enableResultListView = true
***REMOVED***
***REMOVED***@State
***REMOVED***private var noResultMessage = "No results found"
***REMOVED***
***REMOVED******REMOVED***/ Indicates that the `SearchViewModel` should start a search.
***REMOVED***@State
***REMOVED***private var commitSearch = false
***REMOVED***
***REMOVED******REMOVED***/ Indicates that the `SearchViewModel` should accept a suggestion.
***REMOVED***@State
***REMOVED***private var currentSuggestion: SearchSuggestion?
***REMOVED***
***REMOVED***private var viewpoint: Binding<Viewpoint?>?
***REMOVED***
***REMOVED******REMOVED***/ Indicates that the geoView's viewpoint has changed since the last search.
***REMOVED***@State
***REMOVED***private var viewpointChanged: Bool = false

***REMOVED******REMOVED*** TODO: Figure out better styling for list
***REMOVED******REMOVED*** TODO: continue fleshing out SearchViewModel and LocatorSearchSource/SmartSearchSource
***REMOVED******REMOVED*** TODO: following Nathan's lead on all this stuff, i.e., go through his code and duplicate it as I go.
***REMOVED******REMOVED*** TODO: better modifiers for search text field; maybe SearchTextField or something...
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack (alignment: .center) {
***REMOVED******REMOVED******REMOVED***TextField(searchViewModel.defaultPlaceHolder,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  text: $searchViewModel.currentQuery) { editing in
***REMOVED******REMOVED*** onCommit: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Editing state changed (becomes/looses firstResponder)
***REMOVED******REMOVED******REMOVED******REMOVED***commitSearch.toggle()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.esriDeleteTextButton(text: $searchViewModel.currentQuery)
***REMOVED******REMOVED******REMOVED***.esriSearchButton(performSearch: $commitSearch)
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED***if enableRepeatSearchHereButton, viewpointChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Search Here") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpointChanged = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***commitSearch.toggle()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if enableResultListView {
***REMOVED******REMOVED******REMOVED******REMOVED***SearchResultList(searchViewModel: searchViewModel)
***REMOVED******REMOVED******REMOVED******REMOVED***SearchSuggestionList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel: searchViewModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion: $currentSuggestion
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task(id: searchViewModel.currentQuery) {
***REMOVED******REMOVED******REMOVED******REMOVED*** User typed a new character
***REMOVED******REMOVED******REMOVED***if currentSuggestion == nil {
***REMOVED******REMOVED******REMOVED******REMOVED***await searchViewModel.updateSuggestions()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task(id: commitSearch) {
***REMOVED******REMOVED******REMOVED******REMOVED*** User committed changes (hit Enter/Search button)
***REMOVED******REMOVED******REMOVED***await searchViewModel.commitSearch(true)
***REMOVED***
***REMOVED******REMOVED***.task(id: currentSuggestion) {
***REMOVED******REMOVED******REMOVED******REMOVED*** User committed changes (hit Enter/Search button)
***REMOVED******REMOVED******REMOVED***if let suggestion = currentSuggestion {
***REMOVED******REMOVED******REMOVED******REMOVED***await searchViewModel.acceptSuggestion(suggestion)
***REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Modifiers

***REMOVED******REMOVED***/ Determines whether the view will update its configuration based on the geoview's
***REMOVED******REMOVED***/ document automatically.  Defaults to `true`.
***REMOVED******REMOVED***/ - Parameter enableAutomaticConfiguration: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func enableAutomaticConfiguration(_ enableAutomaticConfiguration: Bool) -> SearchView {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.enableAutomaticConfiguration = enableAutomaticConfiguration
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a button that allows the user to repeat a search with a spatial constraint
***REMOVED******REMOVED***/ is displayed automatically. Set to `false` if you want to use a custom button, for example so that
***REMOVED******REMOVED***/ you can place it elsewhere on the map. `SearchViewModel` has properties and methods
***REMOVED******REMOVED***/ you can use to determine when the custom button should be visible and to trigger the search
***REMOVED******REMOVED***/ repeat behavior.  Defaults to `true`.
***REMOVED******REMOVED***/ - Parameter enableRepeatSearchHereButton: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func enableRepeatSearchHereButton(
***REMOVED******REMOVED***_ enableRepeatSearchHereButton: Bool
***REMOVED***) -> SearchView {
***REMOVED******REMOVED***self.enableRepeatSearchHereButton = enableRepeatSearchHereButton
***REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a built-in result view will be shown. If `false`, the result display/selection
***REMOVED******REMOVED***/ list is not shown. Set to `false` if you want to define a custom result list. You might use a
***REMOVED******REMOVED***/ custom result list to show results in a separate list, disconnected from the rest of the search view.
***REMOVED******REMOVED***/ Defaults to `true`.
***REMOVED******REMOVED***/ - Parameter enableResultListView: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func enableResultListView(_ enableResultListView: Bool) -> SearchView {
***REMOVED******REMOVED******REMOVED*** TODO: this doesn't work; the view doesn't redraw
***REMOVED******REMOVED******REMOVED***self._enableResultListView.wrappedValue = enableResultListView
***REMOVED******REMOVED***self.enableResultListView = enableResultListView
***REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Message to show when there are no results or suggestions.  Defaults to "No results found".
***REMOVED******REMOVED***/ - Parameter noResultMessage: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func noResultMessage(_ noResultMessage: String) -> SearchView {
***REMOVED******REMOVED***self.noResultMessage = noResultMessage
***REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***

***REMOVED*** TODO:  why no results?  Why .onChange for results/suggestions don't work
***REMOVED*** TODO: get currentResult working in Example.

***REMOVED*** TODO: look at consolidating SearchResultView and SearchSuggestionView with
***REMOVED*** TODO: new SearchDisplayProtocol containing only displayTitle and displaySubtitle
***REMOVED*** TODO: That would mean we only needed one of these.
struct SearchResultList: View {
***REMOVED***var searchViewModel: SearchViewModel

***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch searchViewModel.results {
***REMOVED******REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***if let results = results, results.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Get array of unique search source displayNames.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let sourceDisplayNames = Array(Set(results.map { $0.owningSource.displayName ***REMOVED***)).sorted()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(sourceDisplayNames, id: \.self) { displayName in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section(header: Text(displayName)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Get results filtered by displayName
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let sourceResults = results.filter { $0.owningSource.displayName == displayName ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if sourceResults.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(sourceResults) { result in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "mappin")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(.red))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchResultRow(title: result.displayTitle, subtitle: result.displaySubtitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.selectedResult = result
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("user selected result: \(result.displayTitle)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO: figure out why this isn't triggered.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("No results found")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(DefaultListStyle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(_):
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

struct SearchSuggestionList: View {
***REMOVED***var searchViewModel: SearchViewModel
***REMOVED***var currentSuggestion: Binding<SearchSuggestion?>
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch searchViewModel.suggestions {
***REMOVED******REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***if let suggestions = results, suggestions.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Get array of unique search source displayNames.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let sourceDisplayNames = Array(Set(suggestions.map { $0.owningSource.displayName ***REMOVED***)).sorted()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(sourceDisplayNames, id: \.self) { displayName in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section(header: Text(displayName)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Get results filtered by displayName
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let sourceSuggestions = suggestions.filter { $0.owningSource.displayName == displayName ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if sourceSuggestions.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(sourceSuggestions) { suggestion in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let imageName = suggestion.isCollection ? "magnifyingglass" : "mappin"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: imageName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchResultRow(title: suggestion.displayTitle, subtitle: suggestion.displaySubtitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion.wrappedValue = suggestion
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(DefaultListStyle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO: figure out why this isn't triggered.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("No results found")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(_):
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***TODO:***REMOVED******REMOVED******REMOVED*** NoResultMessage = "No Results";

struct SearchResultRow: View {
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
