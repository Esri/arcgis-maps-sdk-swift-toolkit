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
    private var commitSearch: Bool = false
    
    /// Indicates that the `SearchViewModel` should accept a suggestion.
    @State
    private var currentSuggestion: SearchSuggestion?
    
    /// Indicates that the geoView's viewpoint has changed since the last search.
    @State
    private var viewpointChanged: Bool = false
    
    // TODO: Figure out better styling for list
    // TODO: continue fleshing out SearchViewModel and LocatorSearchSource/SmartSearchSource
    // TODO: following Nathan's lead on all this stuff, i.e., go through his code and duplicate it as I go.
    // TODO: better modifiers for search text field; maybe SearchTextField or something...
    public var body: some View {
        VStack (alignment: .center) {
            TextField(searchViewModel.defaultPlaceHolder,
                      text: $searchViewModel.currentQuery) { editing in
            } onCommit: {
                // Editing state changed (becomes/looses firstResponder)
                commitSearch.toggle()
            }
            .esriDeleteTextButton(text: $searchViewModel.currentQuery)
            .esriSearchButton(performSearch: $commitSearch)
            .esriBorder()
            if enableRepeatSearchHereButton, viewpointChanged {
                Button("Search Here") {
                    viewpointChanged = false
                    commitSearch.toggle()
                }
            }
            SearchResultList(searchResults: searchViewModel.results)
            SearchSuggestionList(searchSuggestions: searchViewModel.suggestions,
                                 currentSuggestion: $currentSuggestion
            )
        }
        .task(id: searchViewModel.currentQuery) {
            // User typed a new character
            if currentSuggestion == nil {
                await searchViewModel.updateSuggestions()
            }
        }
        .task(id: commitSearch) {
            // User committed changes (hit Enter/Search button)
            await searchViewModel.commitSearch(true)
        }
        .task(id: currentSuggestion) {
            // User committed changes (hit Enter/Search button)
            if let suggestion = currentSuggestion {
                await searchViewModel.acceptSuggestion(suggestion)
                currentSuggestion = nil
            }
        }
    }
}

// TODO: look at consolidating SearchResultView and SearchSuggestionView with
// TODO: new SearchDisplayProtocol containing only displayTitle and displaySubtitle
// TODO: That would mean we only needed one of these.
struct SearchResultList: View {
    var searchResults: Result<[SearchResult]?, Error>
    
    var body: some View {
        Group {
            switch searchResults {
            case .success(let results):
                if let results = results, results.count > 0 {
                    List {
                        // Get array of unique search source displayNames.
                        let sourceDisplayNames = Array(Set(results.map { $0.owningSource.displayName })).sorted()
                        ForEach(sourceDisplayNames, id: \.self) { displayName in
                            Section(header: Text(displayName)) {
                                // Get results filtered by displayName
                                let sourceResults = results.filter { $0.owningSource.displayName == displayName }
                                if sourceResults.count > 0 {
                                    ForEach(sourceResults) { result in
                                        HStack {
                                            Image(systemName: "mappin")
                                                .foregroundColor(Color(.red))
                                            SearchResultRow(title: result.displayTitle, subtitle: result.displaySubtitle)
                                        }
                                        .onTapGesture {
                                            print("user selected result: \(result.displayTitle)")
                                        }
                                    }
                                }
                                else {
                                    // TODO: figure out why this isn't triggered.
                                    Text("No results found")
                                }
                                //                    .listStyle(DefaultListStyle())
                            }
                        }
                    }
                }
            case .failure(_):
                Spacer()
            }
        }
    }
}

struct SearchSuggestionList: View {
    var searchSuggestions: Result<[SearchSuggestion]?, Error>
    var currentSuggestion: Binding<SearchSuggestion?>
    
    var body: some View {
        Group {
            switch searchSuggestions {
            case .success(let results):
                if let suggestions = results, suggestions.count > 0 {
                    List {
                        // Get array of unique search source displayNames.
                        let sourceDisplayNames = Array(Set(suggestions.map { $0.owningSource.displayName })).sorted()
                        ForEach(sourceDisplayNames, id: \.self) { displayName in
                            Section(header: Text(displayName)) {
                                // Get results filtered by displayName
                                let sourceSuggestions = suggestions.filter { $0.owningSource.displayName == displayName }
                                if sourceSuggestions.count > 0 {
                                    ForEach(sourceSuggestions) { suggestion in
                                        HStack {
                                            let imageName = suggestion.isCollection ? "magnifyingglass" : "mappin"
                                            Image(systemName: imageName)
                                            SearchResultRow(title: suggestion.displayTitle, subtitle: suggestion.displaySubtitle)
                                        }
                                        .onTapGesture() {
                                            currentSuggestion.wrappedValue = suggestion
                                        }
                                    }
                                    //                    .listStyle(DefaultListStyle())
                                }
                                else {
                                    // TODO: figure out why this isn't triggered.
                                    Text("No results found")
                                }
                            }
                        }
                    }
                }
            case .failure(_):
                Spacer()
            }
        }
    }
}
//TODO:             NoResultMessage = "No Results";

struct SearchResultRow: View {
    var title: String
    var subtitle: String?
    
    var body: some View {
        VStack (alignment: .leading){
            Text(title)
                .font(.callout)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
            }
        }
    }
}
