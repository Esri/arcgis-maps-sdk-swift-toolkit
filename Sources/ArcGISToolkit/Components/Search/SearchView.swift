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
    public init(
        searchViewModel: SearchViewModel
    ) {
        self.searchViewModel = searchViewModel
    }
    
    /// The view model used by the view. The `ViewModel` manages state and handles the activity of
    /// searching. The view observes `ViewModel` for changes in state. The view calls methods on
    /// `ViewModel` in response to user action. The `ViewModel` is created automatically by the
    /// view upon construction. If `enableAutomaticConfiguration` is true, the view calls
    /// `SearchViewModel.ConfigureForMap` for the map/scene whenever it changes. Both
    /// the associated `GeoView` and the `GeoView`'s document can change after initial configuration.
    @ObservedObject
    var searchViewModel: SearchViewModel
    
    private var enableAutomaticConfiguration = true
    
    @State
    private var enableRepeatSearchHereButton = true
    
    @State
    private var enableResultListView = true
    
    private var noResultMessage = "No results found"
    
    /// Indicates that the `SearchViewModel` should start a search.
    @State
    private var commitSearch = false
    
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
    // TODO: Get proper pins for example app. - How to use SF font with PictureMarkerSymbol?? How to tint calcite icons/images.
    public var body: some View {
        VStack (alignment: .center) {
            TextField(searchViewModel.defaultPlaceHolder,
                      text: $searchViewModel.currentQuery) { editing in
            } onCommit: {
                commitSearch.toggle()
            }
            .esriDeleteTextButton(text: $searchViewModel.currentQuery)
            .esriSearchButton(performSearch: $commitSearch)
            .esriShowResultsButton(showResults: $enableResultListView)
            .esriBorder()
            if enableRepeatSearchHereButton, viewpointChanged {
                Button("Search Here") {
                    viewpointChanged = false
                    commitSearch.toggle()
                }
            }
            if enableResultListView {
                SearchResultList(
                    searchResults: searchViewModel.results,
                    selectedResult: $searchViewModel.selectedResult,
                    noResultMessage: noResultMessage
                )
                SearchSuggestionList(
                    suggestionResults: searchViewModel.suggestions,
                    currentSuggestion: $currentSuggestion,
                    noResultMessage: noResultMessage
                )
            }
        }
        // TODO:  Not sure how to get the list to constrain itself if there's less than a screen full of rows.
        Spacer()
            .task(id: searchViewModel.currentQuery) {
                // User typed a new character
                if currentSuggestion == nil {
                    await searchViewModel.updateSuggestions()
                }
            }
            .task(id: commitSearch) {
                if commitSearch {
                    await searchViewModel.commitSearch(false)
                }
            }
            .task(id: currentSuggestion) {
                // User committed changes (hit Enter/Search button)
                if let suggestion = currentSuggestion {
                    await searchViewModel.acceptSuggestion(suggestion)
                    currentSuggestion = nil
                }
            }
    }

    // MARK: Modifiers
    
    /// Determines whether the view will update its configuration based on the geoview's
    /// document automatically.  Defaults to `true`.
    /// - Parameter enableAutomaticConfiguration: The new value.
    /// - Returns: The `SearchView`.
    public func enableAutomaticConfiguration(_ enableAutomaticConfiguration: Bool) -> SearchView {
        var copy = self
        copy.enableAutomaticConfiguration = enableAutomaticConfiguration
        return copy
    }
    
    /// Determines whether a button that allows the user to repeat a search with a spatial constraint
    /// is displayed automatically. Set to `false` if you want to use a custom button, for example so that
    /// you can place it elsewhere on the map. `SearchViewModel` has properties and methods
    /// you can use to determine when the custom button should be visible and to trigger the search
    /// repeat behavior.  Defaults to `true`.
    /// - Parameter enableRepeatSearchHereButton: The new value.
    /// - Returns: The `SearchView`.
    public func enableRepeatSearchHereButton(
        _ enableRepeatSearchHereButton: Bool
    ) -> SearchView {
        self.enableRepeatSearchHereButton = enableRepeatSearchHereButton
        return self
    }
    
    /// Determines whether a built-in result view will be shown. If `false`, the result display/selection
    /// list is not shown. Set to `false` if you want to define a custom result list. You might use a
    /// custom result list to show results in a separate list, disconnected from the rest of the search view.
    /// Defaults to `true`.
    /// - Parameter enableResultListView: The new value.
    /// - Returns: The `SearchView`.
    public func enableResultListView(_ enableResultListView: Bool) -> SearchView {
        self.enableResultListView = enableResultListView
        return self
    }
    
    /// Message to show when there are no results or suggestions.  Defaults to "No results found".
    /// - Parameter noResultMessage: The new value.
    /// - Returns: The `SearchView`.
    public func noResultMessage(_ noResultMessage: String) -> SearchView {
        var copy = self
        copy.noResultMessage = noResultMessage
        return copy
    }
}

struct SearchResultList: View {
    var searchResults: Result<[SearchResult]?, SearchError>
    @Binding var selectedResult: SearchResult?
    var noResultMessage: String
    
    var body: some View {
        Group {
            switch searchResults {
            case .success(let results):
                if let results = results, results.count > 0 {
                    if results.count > 1 {
                        // If we have only 1 results, don't show the list.
                        List {
                            ForEach(results) { result in
                                SearchResultRow(result: result)
                                .onTapGesture {
                                    selectedResult = result
                                }
                            }
                        }
                        //                    .listStyle(DefaultListStyle())
                    }
                }
                else if results != nil {
                    List {
                        Text(noResultMessage)
                    }
                }
            case .failure(let error):
                List {
                    Text(error.localizedDescription)
                }
            }
        }
        .esriBorder(edgeInsets: EdgeInsets())
    }
}

struct SearchSuggestionList: View {
    var suggestionResults: Result<[SearchSuggestion]?, SearchError>
    @Binding var currentSuggestion: SearchSuggestion?
    var noResultMessage: String
    
    var body: some View {
        Group {
            switch suggestionResults {
            case .success(let results):
                if let suggestions = results, suggestions.count > 0 {
                    List {
                        if suggestions.count > 0 {
                            ForEach(suggestions) { suggestion in
                                SuggestionResultRow(suggestion: suggestion)
                                .onTapGesture() {
                                    currentSuggestion = suggestion
                                }
                            }
                            //                    .listStyle(DefaultListStyle())
                        }
                    }
                }
                else if results != nil {
                    List {
                        Text(noResultMessage)
                    }
                }
            case .failure(let error):
                List {
                    Text(error.errorDescription)
                }
            }
        }
        .esriBorder(edgeInsets: EdgeInsets())
    }
}

struct SearchResultRow: View {
    var result: SearchResult

    var body: some View {
        HStack {
            Image(systemName: "mappin")
                .foregroundColor(Color(.red))
            ResultRow(title: result.displayTitle, subtitle: result.displaySubtitle)
        }
    }
}

struct SuggestionResultRow: View {
    var suggestion: SearchSuggestion

    var body: some View {
        HStack {
            let imageName = suggestion.isCollection ? "magnifyingglass" : "mappin"
            Image(systemName: imageName)
            ResultRow(title: suggestion.displayTitle, subtitle: suggestion.displaySubtitle)
        }
    }
}

struct ResultRow: View {
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
