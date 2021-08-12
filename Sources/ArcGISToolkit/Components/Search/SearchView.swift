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

/// SearchView presents a search experience, powered by an underlying SearchViewModel.
public struct SearchView: View {
    public init(searchViewModel: SearchViewModel? = nil) {
        if let searchViewModel = searchViewModel {
            self.searchViewModel = searchViewModel
        }
        else {
            self.searchViewModel = SearchViewModel(
                sources: [LocatorSearchSource()]
            )
        }
    }
    
    /// The view model used by the view. The `SearchViewModel` manages state and handles the
    /// activity of searching. The view observes `SearchViewModel` for changes in state. The view
    /// calls methods on `SearchViewModel` in response to user action.
    @ObservedObject
    var searchViewModel: SearchViewModel
    
    /// Determines whether a built-in result view will be shown. Defaults to true.
    /// If false, the result display/selection list is not shown. Set to false if you want to hide the results
    /// or define a custom result list. You might use a custom result list to show results in a separate list,
    /// disconnected from the rest of the search view.
    private var enableResultListView = true
    
    /// Message to show when there are no results or suggestions.  Defaults to "No results found".
    private var noResultMessage = "No results found"
    
    /// Indicates that the `SearchViewModel` should start a search.
    @State
    private var shouldCommitSearch = false
    
    /// The current suggestion selected by the user.
    @State
    private var currentSuggestion: SearchSuggestion?
    
    /// Determines whether the results lists are displayed.
    @State
    private var isResultDisplayHidden: Bool = false
    
    public var body: some View {
        VStack (alignment: .center) {
            TextField(
                searchViewModel.defaultPlaceholder,
                text: $searchViewModel.currentQuery
            ) { _ in
            } onCommit: {
                shouldCommitSearch = true
            }
            .esriDeleteTextButton(text: $searchViewModel.currentQuery)
            .esriSearchButton(performSearch: $shouldCommitSearch)
            .esriShowResultsButton(
                isEnabled: !enableResultListView,
                isHidden: $isResultDisplayHidden
            )
            .esriBorder()
            if enableResultListView, !isResultDisplayHidden {
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
        Spacer()
            .task(id: searchViewModel.currentQuery) {
                // User typed a new character
                if currentSuggestion == nil {
                    await searchViewModel.updateSuggestions()
                }
            }
            .task(id: shouldCommitSearch) {
                if shouldCommitSearch {
                    // User committed changes (hit Enter/Search button)
                    await searchViewModel.commitSearch(false)
                    shouldCommitSearch.toggle()
                }
            }
            .task(id: currentSuggestion) {
                if let suggestion = currentSuggestion {
                    // User selected a suggestion.
                    await searchViewModel.acceptSuggestion(suggestion)
                    currentSuggestion = nil
                }
            }
    }
    
    // MARK: Modifiers
    
    /// Determines whether a built-in result view will be shown. If `false`, the result display/selection
    /// list is not shown. Set to `false` if you want to define a custom result list. You might use a
    /// custom result list to show results in a separate list, disconnected from the rest of the search view.
    /// Defaults to `true`.
    /// - Parameter enableResultListView: The new value.
    /// - Returns: The `SearchView`.
    public func enableResultListView(_ enableResultListView: Bool) -> SearchView {
        var copy = self
        copy.enableResultListView = enableResultListView
        return copy
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
                        // Only show the list if we have more than one result.
                        PlainList {
                            ForEach(results) { result in
                                SearchResultRow(result: result)
                                    .onTapGesture {
                                        selectedResult = result
                                    }
                            }
                        }
                    }
                }
                else if results != nil {
                    PlainList {
                        Text(noResultMessage)
                    }
                }
            case .failure(let error):
                PlainList {
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
                    PlainList {
                        if suggestions.count > 0 {
                            ForEach(suggestions) { suggestion in
                                SuggestionResultRow(suggestion: suggestion)
                                    .onTapGesture() {
                                        currentSuggestion = suggestion
                                    }
                            }
                        }
                    }
                }
                else if results != nil {
                    PlainList {
                        Text(noResultMessage)
                    }
                }
            case .failure(let error):
                PlainList {
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
            ResultRow(
                title: result.displayTitle,
                subtitle: result.displaySubtitle
            )
        }
    }
}

struct SuggestionResultRow: View {
    var suggestion: SearchSuggestion
    
    var body: some View {
        HStack {
            let imageName = suggestion.isCollection ? "magnifyingglass" : "mappin"
            Image(systemName: imageName)
            ResultRow(
                title: suggestion.displayTitle,
                subtitle: suggestion.displaySubtitle
            )
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
