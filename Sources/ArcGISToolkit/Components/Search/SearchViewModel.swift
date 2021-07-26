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

import Swift
import SwiftUI
import ArcGIS

/// Defines how many results to return; one, many, or automatic based on circumstance.
public enum SearchResultMode {
    /// Search should always result in at most one result.
    case single
    /// Search should always try to return multiple results.
    case multiple
    /// Search should make a choice based on context. E.g. 'coffee shop' should be multiple results,
    /// while '380 New York St. Redlands' should be one result.
    case automatic
}

/// Performs searches and manages search state for a Search, or optionally without a UI connection.
public class SearchViewModel: ObservableObject {
    public convenience init(
defaultPlaceHolder: String = "Find a place or address",
activeSource: SearchSourceProtocol? = nil,
queryArea: Geometry? = nil,
queryCenter: Point? = nil,
resultMode: SearchResultMode = .automatic,
results: Result<[SearchResult]?, RuntimeError> = .success(nil),
sources: [SearchSourceProtocol] = [],
suggestions: Result<[SearchSuggestion]?, RuntimeError> = .success(nil)
    ) {
        self.init()
        self.defaultPlaceHolder = defaultPlaceHolder
        self.activeSource = activeSource
        self.queryArea = queryArea
        self.queryCenter = queryCenter
        self.resultMode = resultMode
        self.results = results
        self.sources = sources
        self.suggestions = suggestions
    }
    
    /// The string shown in the search view when no user query is entered.
    /// Default is "Find a place or address", or read from web map JSON if specified in the web map configuration.
    public var defaultPlaceHolder: String = "Find a place or address"
    
    /// Tracks the currently active search source.  All sources are used if this property is `nil`.
    public var activeSource: SearchSourceProtocol?
    
    /// Tracks the current user-entered query. This should be updated by the view after every key press.
    /// This property drives both suggestions and searches. This property can be changed by
    /// other method calls and property changes within the view model, so the view should take care to
    /// observe for changes.
    @Published
    public var currentQuery: String = "" {
        didSet {
            selectedResult = nil
            if currentQuery.isEmpty {
                results = .success(nil)
                suggestions = .success(nil)
            }
        }
    }
    
    /// The search area to be used for the current query. Ignored in most queries, unless the
    /// `restrictToArea` property is set to true when calling `commitSearch`. This property
    /// should be updated as the user navigates the map/scene, or at minimum before calling `commitSearch`.
    public var queryArea: Geometry? {
        didSet {
            isEligibleForRequery = true
        }
    }
    
    /// Defines the center for the search. This should be updated by the view every time the
    /// user navigates the map.
    public var queryCenter: Point?
    
    /// Defines how many results to return. Defaults to Automatic. In automatic mode, an appropriate
    /// number of results is returned based on the type of suggestion chosen (driven by the IsCollection property).
    public var resultMode: SearchResultMode = .automatic
    
    /// Collection of results. `nil` means no query has been made. An empty array means there
    /// were no results, and the view should show an appropriate 'no results' message.
    @Published
    public var results: Result<[SearchResult]?, RuntimeError> = .success(nil)

    /// Tracks selection of results from the `results` collection. When there is only one result,
    /// that result is automatically assigned to this property. If there are multiple results, the view sets
    /// this property upon user selection. This property is observable. The view should observe this
    /// property and update the associated GeoView's viewpoint, if configured.
    @Published
    public var selectedResult: SearchResult?
    
    /// Collection of search sources to be used. This list is maintained over time and is not nullable.
    /// The view should observe this list for changes. Consumers should add and remove sources from
    /// this list as needed.
    public var sources: [SearchSourceProtocol] = []
    
    /// Collection of suggestion results. Defaults to `nil`. This collection will be set to empty when there
    /// are no suggestions, `nil` when no suggestions have been requested. If the list is empty,
    /// a useful 'no results' message should be shown by the view.
    @Published
    public var suggestions: Result<[SearchSuggestion]?, RuntimeError> = .success(nil)

    /// True if the `queryArea` has changed since the `results` collection has been set.
    /// This property is used by the view to enable 'Repeat search here' functionality. This property is
    /// observable, and the view should use it to hide and show the 'repeat search' button. Changes to
    /// this property are driven by changes to the `queryArea` property.
    private(set) var isEligibleForRequery: Bool = false
    
    /// Starts a search. `selectedResult` and `results`, among other properties, are set
    /// asynchronously. Other query properties are read to define the parameters of the search.
    /// If `restrictToArea` is true, only results in the query area will be returned.
    /// - Parameter restrictToArea: If true, the search is restricted to results within the extent
    /// of the `queryArea` property. Behavior when called with `restrictToArea` set to true
    /// when the `queryArea` property is null, a line, a point, or an empty geometry is undefined.
    func commitSearch(_ restrictToArea: Bool) async -> Void {
        guard !currentQuery.isEmpty else { return }
        
        selectedResult = nil
        isEligibleForRequery = false
        
        var searchResults = [SearchResult]()
        let searchSources = sourcesToSearch()
        for i in 0...searchSources.count - 1 {
            var searchSource = searchSources[i]
            searchSource.searchArea = queryArea
            searchSource.preferredSearchLocation = queryCenter
            
            let searchResult = await Result {
                try await searchSource.search(
                    currentQuery,
                    area: restrictToArea ? queryArea : nil
                )
            }
            switch searchResult {
            case .success(let results):
                searchResults.append(contentsOf: results)
            case .failure(let error):
                print("\(searchSource.displayName) encountered an error: \(error.localizedDescription)")
            case .none:
                break
            }
        }
        suggestions = .success(nil)
        results = .success(searchResults)
        if searchResults.count == 1 {
            selectedResult = searchResults.first
        }
    }
    
    /// Updates suggestions list asynchronously. View should take care to cancel previous suggestion
    /// requests before initiating new ones. The view should also wait for some time after user finishes
    /// typing before making suggestions. The JavaScript implementation uses 150ms by default.
    func updateSuggestions() async -> Void {
        guard !currentQuery.isEmpty else { return }
        print("SearchViewModel.updateSuggestions: \(currentQuery)")

        var suggestionResults = [SearchSuggestion]()
        let searchSources = sourcesToSearch()
        for i in 0...searchSources.count - 1 {
            var searchSource = searchSources[i]
            searchSource.searchArea = queryArea
            searchSource.preferredSearchLocation = queryCenter
            
            let suggestResults = await Result {
                try await searchSource.suggest(currentQuery)
            }
            switch suggestResults {
            case .success(let results):
                suggestionResults.append(contentsOf: results)
            case .failure(let error):
                print("\(searchSource.displayName) encountered an error: \(error.localizedDescription)")
            case .none:
                break
            }
        }

        results = .success(nil)
        suggestions = .success(suggestionResults)
        
        selectedResult = nil
        isEligibleForRequery = false
    }
    
    /// Commits a search from a specific suggestion. Results will be set asynchronously. Behavior is
    /// generally the same as `commitSearch`, except the suggestion is used instead of the
    /// `currentQuery` property. When a suggestion is accepted, `currentQuery` is updated to
    /// match the suggestion text. The view should take care not to submit a separate search in response
    /// to changes to `currentQuery` initiated by a call to this method.
    /// - Parameters:
    ///   - searchSuggestion: The suggestion to use to commit the search.
    func acceptSuggestion(_ searchSuggestion: SearchSuggestion) async -> Void {
        currentQuery = searchSuggestion.displayTitle
        
        isEligibleForRequery = false
        selectedResult = nil

        var searchResults = [SearchResult]()
        let searchResult = await Result {
            try await searchSuggestion.owningSource.search(searchSuggestion)
        }
        switch searchResult {
        case .success(let results):
            switch (resultMode)
            {
            case .single:
                if let firstResult = results.first {
                    searchResults = [firstResult]
                    selectedResult = firstResult
                }
            case .multiple:
                searchResults = results
            case .automatic:
                if searchSuggestion.suggestResult?.isCollection ?? true {
                    searchResults = results
                } else {
                    if let firstResult = results.first {
                        searchResults = [firstResult]
                        selectedResult = firstResult
                    }
                }
            }
        case .failure(let error):
            print("\(searchSuggestion.owningSource.displayName) encountered an error: \(error.localizedDescription)")
        case .none:
            break
        }
        
        results = .success(searchResults)
        if searchResults.count == 1 {
            selectedResult = searchResults.first
        }
        suggestions = .success(nil)
    }
    
    /// Configures the view model for the provided map. By default, will only configure the view model
    /// with the default world geocoder. In future updates, additional functionality may be added to take
    /// web map configuration into account.
    /// - Parameters:
    ///   - map: Map to use for configuration.
    func configureForMap(_ map: Map) {
        print("SearchViewModel.configureForMap")
    }
    
    /// Configures the view model for the provided scene. By default, will only configure the view model
    /// with the default world geocoder. In future updates, additional functionality may be added to take
    /// web scene configuration into account.
    /// - Parameters:
    ///   - scene: Scene used for configuration.
    func configureForScene(_ scene: ArcGIS.Scene) {
        print("SearchViewModel.configureForScene")
    }
    
    /// Clears the search. This will set the results list to null, clear the result selection, clear suggestions,
    /// and reset the current query.
    func clearSearch() {
        print("SearchViewModel.clearSearch")
    }
}

extension SearchViewModel {
    func sourcesToSearch() -> [SearchSourceProtocol] {
        var selectedSources = [SearchSourceProtocol]()
        if let activeSource = activeSource {
            selectedSources.append(activeSource)
        } else {
            selectedSources.append(contentsOf: sources)
        }
        return selectedSources
    }
}
