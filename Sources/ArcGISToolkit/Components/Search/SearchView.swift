// Copyright 2021 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import Combine
import ArcGIS

/// SearchView presents a search experience, powered by underlying SearchViewModel.
public struct SearchView: View {
    /// Used for accessing `GeoView` functionality for geocoding and searching.
    /// Reference to the GeoView used for automatic configuration.
    /// When connected to a GeoView, SearchView will automatically navigate the view in response to
    /// search result changes. Additionally, the view's current center and extent will be automatically
    /// provided to locators as parameters.
    var proxy: GeoViewProxy
    
    /// Determines whether the view will update its configuration based on the attached geoview's
    /// document automatically.
    var enableAutoConfiguration: Bool = true
    
    /// Determines whether a button that allows the user to repeat a search with a spatial constraint
    /// is displayed automatically. Set to false if you want to use a custom button, for example so that
    /// you can place it elsewhere on the map. `SearchViewModel` has properties and methods
    /// you can use to determine when the custom button should be visible and to trigger the search
    /// repeat behavior.
    var enableRepeatSearchHereButton: Bool = true
    
    /// Determines whether a built-in result view will be shown. If false, the result display/selection
    /// list is not shown. Set to false if you want to define a custom result list. You might use a
    /// custom result list to show results in a separate list, disconnected from the rest of the search view.
    var enableResultListView: Bool = true
    
    /// Message to show when there are no results or suggestions.
    var noResultMessage: String = "No results found"
    
    /// The view model used by the view. The `ViewModel` manages state and handles the activity of
    /// searching. The view observes `ViewModel` for changes in state. The view calls methods on
    /// `ViewModel` in response to user action. The `ViewModel` is created automatically by the
    /// view upon construction. If `EnableAutoconfiguration` is true, the view calls
    /// `SearchViewModel.ConfigureForMap` for the map/scene whenever it changes. Both
    /// the associated `GeoView` and the `GeoView`'s document can change after initial configuration.
    var searchViewModel: SearchViewModel
    
    public var body: some View {
        ZStack {
//            TextField("Search",
//                      text: $searchText) { editing in
//                print("editing changed")
//            } onCommit: {
//                print("On commit")
//            }

        }
    }
}
