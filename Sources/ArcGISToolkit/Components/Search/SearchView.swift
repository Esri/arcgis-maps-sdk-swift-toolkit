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
***REMOVED******REMOVED******REMOVED******REMOVED***enableAutomaticConfiguration: Bool = true,
***REMOVED******REMOVED******REMOVED******REMOVED***enableRepeatSearchHereButton: Bool = true,
***REMOVED******REMOVED******REMOVED******REMOVED***enableResultListView: Bool = true,
***REMOVED******REMOVED******REMOVED******REMOVED***noResultMessage: String = "No results found") {
***REMOVED******REMOVED***self.proxy = proxy
***REMOVED******REMOVED***self.searchViewModel = searchViewModel
***REMOVED******REMOVED***self.enableAutomaticConfiguration = enableAutomaticConfiguration
***REMOVED******REMOVED***self.enableRepeatSearchHereButton = enableRepeatSearchHereButton
***REMOVED******REMOVED***self.enableResultListView = enableResultListView
***REMOVED******REMOVED***self.noResultMessage = noResultMessage
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
***REMOVED******REMOVED***/ Determines whether the view will update its configuration based on the attached geoview's
***REMOVED******REMOVED***/ document automatically.
***REMOVED***var enableAutomaticConfiguration: Bool = true
***REMOVED***
***REMOVED***@State
***REMOVED******REMOVED***/ Determines whether a button that allows the user to repeat a search with a spatial constraint
***REMOVED******REMOVED***/ is displayed automatically. Set to false if you want to use a custom button, for example so that
***REMOVED******REMOVED***/ you can place it elsewhere on the map. `SearchViewModel` has properties and methods
***REMOVED******REMOVED***/ you can use to determine when the custom button should be visible and to trigger the search
***REMOVED******REMOVED***/ repeat behavior.
***REMOVED***var enableRepeatSearchHereButton: Bool = true
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a built-in result view will be shown. If false, the result display/selection
***REMOVED******REMOVED***/ list is not shown. Set to false if you want to define a custom result list. You might use a
***REMOVED******REMOVED***/ custom result list to show results in a separate list, disconnected from the rest of the search view.
***REMOVED***var enableResultListView: Bool = true
***REMOVED***
***REMOVED******REMOVED***/ Message to show when there are no results or suggestions.
***REMOVED***var noResultMessage: String = "No results found"
***REMOVED***
***REMOVED***@State
***REMOVED******REMOVED***/ Indicates that the `SearchViewModel` should start a search.
***REMOVED***private var shouldCommitSearch: Bool = false
***REMOVED***
***REMOVED***@State
***REMOVED******REMOVED***/ Indicates that the geoView's viewpoint has changed since the last search.
***REMOVED***private var viewpointChanged: Bool = false
***REMOVED***
***REMOVED***@State
***REMOVED***private var result: Result<[SearchResult], Error> = .success([])
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack (alignment: .center) {
***REMOVED******REMOVED******REMOVED***TextField(searchViewModel.defaultPlaceHolder,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  text: $searchViewModel.currentQuery) { editing in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** For when editing state changes (becomes/looses firstResponder)
***REMOVED******REMOVED*** onCommit: {
***REMOVED******REMOVED******REMOVED******REMOVED***shouldCommitSearch.toggle()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.esriDeleteTextButton(text: $searchViewModel.currentQuery)
***REMOVED******REMOVED******REMOVED***.esriSearchButton(performSearch: $shouldCommitSearch)
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED***if enableRepeatSearchHereButton, viewpointChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Search Here") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpointChanged = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***shouldCommitSearch.toggle()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***if results.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List(results) { result in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack (alignment: .leading){
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(result.displayTitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.callout)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let subtitle = result.displaySubtitle {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(subtitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO: Figure out better styling for list
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO: continue fleshing out SearchViewModel and LocatorSearchSource/SmartSearchSource
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(DefaultListStyle())
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Error occurred: \(error.localizedDescription)")
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task(id: searchViewModel.currentQuery) {
***REMOVED******REMOVED******REMOVED******REMOVED*** For when user types a new character
***REMOVED******REMOVED******REMOVED***guard !searchViewModel.currentQuery.isEmpty else {
***REMOVED******REMOVED******REMOVED******REMOVED***result = .success([])
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***await searchViewModel.updateSuggestions(nil)
***REMOVED***
***REMOVED******REMOVED***.task(id: shouldCommitSearch) {
***REMOVED******REMOVED******REMOVED******REMOVED*** For when user commits changes (hits Enter/Search button)
***REMOVED******REMOVED******REMOVED***print("geocoding...")
***REMOVED******REMOVED******REMOVED***result = await Result { try await searchViewModel.commitSearch(true) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Extensions

extension SearchResult: Identifiable {
***REMOVED***public var id: ObjectIdentifier { ObjectIdentifier(self) ***REMOVED***
***REMOVED***
