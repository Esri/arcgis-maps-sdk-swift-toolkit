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
***REMOVED******REMOVED***/ Used for accessing `GeoView` functionality for geocoding and searching.
***REMOVED******REMOVED***/ Reference to the GeoView used for automatic configuration.
***REMOVED******REMOVED***/ When connected to a GeoView, SearchView will automatically navigate the view in response to
***REMOVED******REMOVED***/ search result changes. Additionally, the view's current center and extent will be automatically
***REMOVED******REMOVED***/ provided to locators as parameters.
***REMOVED***var proxy: GeoViewProxy
***REMOVED***
***REMOVED******REMOVED***/ Determines whether the view will update its configuration based on the attached geoview's
***REMOVED******REMOVED***/ document automatically.
***REMOVED***var enableAutoConfiguration: Bool = true
***REMOVED***
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
***REMOVED******REMOVED***/ The view model used by the view. The `ViewModel` manages state and handles the activity of
***REMOVED******REMOVED***/ searching. The view observes `ViewModel` for changes in state. The view calls methods on
***REMOVED******REMOVED***/ `ViewModel` in response to user action. The `ViewModel` is created automatically by the
***REMOVED******REMOVED***/ view upon construction. If `EnableAutoconfiguration` is true, the view calls
***REMOVED******REMOVED***/ `SearchViewModel.ConfigureForMap` for the map/scene whenever it changes. Both
***REMOVED******REMOVED***/ the associated `GeoView` and the `GeoView`'s document can change after initial configuration.
***REMOVED***var searchViewModel: SearchViewModel
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***TextField("Search",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  text: $searchText) { editing in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("editing changed")
***REMOVED******REMOVED******REMOVED*** onCommit: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("On commit")
***REMOVED******REMOVED******REMOVED***

***REMOVED***
***REMOVED***
***REMOVED***
