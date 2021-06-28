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
    public init(proxy: GeoViewProxy,
                searchViewModel: SearchViewModel,
                enableAutomaticConfiguration: Bool = true,
                enableRepeatSearchHereButton: Bool = true,
                enableResultListView: Bool = true,
                noResultMessage: String = "No results found") {
        self.proxy = proxy
        self.searchViewModel = searchViewModel
        self.enableAutomaticConfiguration = enableAutomaticConfiguration
        self.enableRepeatSearchHereButton = enableRepeatSearchHereButton
        self.enableResultListView = enableResultListView
        self.noResultMessage = noResultMessage
    }
    
    /// Used for accessing `GeoView` functionality for geocoding and searching.
    /// Reference to the GeoView used for automatic configuration.
    /// When connected to a GeoView, SearchView will automatically navigate the view in response to
    /// search result changes. Additionally, the view's current center and extent will be automatically
    /// provided to locators as parameters.
    var proxy: GeoViewProxy
    
    /// The view model used by the view. The `ViewModel` manages state and handles the activity of
    /// searching. The view observes `ViewModel` for changes in state. The view calls methods on
    /// `ViewModel` in response to user action. The `ViewModel` is created automatically by the
    /// view upon construction. If `enableAutomaticConfiguration` is true, the view calls
    /// `SearchViewModel.ConfigureForMap` for the map/scene whenever it changes. Both
    /// the associated `GeoView` and the `GeoView`'s document can change after initial configuration.
    @ObservedObject
    var searchViewModel: SearchViewModel
    
    /// Determines whether the view will update its configuration based on the attached geoview's
    /// document automatically.
    var enableAutomaticConfiguration: Bool = true
    
    /// Determines whether a button that allows the user to repeat a search with a spatial constraint
    /// is displayed automatically. Set to false if you want to use a custom button, for example so that
    /// you can place it elsewhere on the map. `SearchViewModel` has properties and methods
    /// you can use to determine when the custom button should be visible and to trigger the search
    /// repeat behavior.
    @State
    var enableRepeatSearchHereButton: Bool = true
    
    /// Determines whether a built-in result view will be shown. If false, the result display/selection
    /// list is not shown. Set to false if you want to define a custom result list. You might use a
    /// custom result list to show results in a separate list, disconnected from the rest of the search view.
    var enableResultListView: Bool = true
    
    /// Message to show when there are no results or suggestions.
    var noResultMessage: String = "No results found"
    
    /// Indicates that the `SearchViewModel` should start a search.
    @State
    private var shouldCommitSearch: Bool = false
    
    /// Indicates that the geoView's viewpoint has changed since the last search.
    @State
    private var viewpointChanged: Bool = false
    
    // TODO: Figure out better styling for list
    // TODO: continue fleshing out SearchViewModel and LocatorSearchSource/SmartSearchSource
    // TODO: following Nathan's lead on all this stuff, i.e., go through his code and duplicate it as I go.

    public var body: some View {
        VStack (alignment: .center) {
            TextField(searchViewModel.defaultPlaceHolder,
                      text: $searchViewModel.currentQuery) { editing in
                // For when editing state changes (becomes/looses firstResponder)
            } onCommit: {
                shouldCommitSearch.toggle()
            }
            .esriDeleteTextButton(text: $searchViewModel.currentQuery)
            .esriSearchButton(performSearch: $shouldCommitSearch)
            .esriBorder()
            if enableRepeatSearchHereButton, viewpointChanged {
                Button("Search Here") {
                    viewpointChanged = false
                    shouldCommitSearch.toggle()
                }
                .esriBorder()
            }
            switch searchViewModel.results {
            case .success(let results):
                if let results = results, results.count > 0 {
                    List(results) { result in
                        VStack (alignment: .leading){
                            Text(result.displayTitle)
                                .font(.callout)
                            if let subtitle = result.displaySubtitle {
                                Text(subtitle)
                                    .font(.caption)
                            }
                        }
                    }
                    //                    .listStyle(DefaultListStyle())
                }
            case .failure(let error):
                Text("Error occurred: \(error.localizedDescription)")
                Spacer()
            }
            switch searchViewModel.suggestions {
            case .success(let results):
                if let results = results, results.count > 0 {
                    List(results) { result in
                        VStack (alignment: .leading){
                            Text(result.displayTitle)
                                .font(.callout)
                            if let subtitle = result.displaySubtitle {
                                Text(subtitle)
                                    .font(.caption)
                            }
                        }
                    }
                    //                    .listStyle(DefaultListStyle())
                }
            case .failure(let error):
                Text("Error occurred: \(error.localizedDescription)")
                Spacer()
            }
        }
        .task(id: searchViewModel.currentQuery) {
            // For when user types a new character
            //            suggestionResult = await Result { try await searchViewModel.updateSuggestions() }
            await searchViewModel.updateSuggestions()
        }
        .task(id: shouldCommitSearch) {
            // For when user commits changes (hits Enter/Search button)
            await searchViewModel.commitSearch(true)
        }
    }
}
