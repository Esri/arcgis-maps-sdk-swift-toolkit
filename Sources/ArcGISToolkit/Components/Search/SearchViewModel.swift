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
import Combine

/// Performs searches and manages search state for a Search, or optionally without a UI connection.
public class SearchViewModel: ObservableObject {
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
    
    /// Creates a `SearchViewModel`.
    /// - Parameters:
    ///   - defaultPlaceholder: The string shown in the search view when no user query is entered.
    ///   - activeSource: Tracks the currently active search source.
    ///   - queryArea: The search area to be used for the current query.
    ///   - queryCenter: Defines the center for the search.
    ///   - resultMode: Defines how many results to return.
    ///   - sources: Collection of search sources to be used.
    public convenience init(
        defaultPlaceholder: String = .defaultPlaceholder,
        activeSource: SearchSourceProtocol? = nil,
        queryArea: Geometry? = nil,
        queryCenter: Point? = nil,
        resultMode: SearchResultMode = .automatic,
        sources: [SearchSourceProtocol] = []
    ) {
        self.init()
        self.defaultPlaceholder = defaultPlaceholder
        self.activeSource = activeSource
        self.queryArea = queryArea
        self.queryCenter = queryCenter
        self.resultMode = resultMode
        self.sources = sources
    }
    
    /// The string shown in the search view when no user query is entered.
    /// Default is "Find a place or address".
    public var defaultPlaceholder: String = .defaultPlaceholder
    
    /// The active search source.  If `nil`, the first item in `sources` is used.
    public var activeSource: SearchSourceProtocol?
    
    /// Tracks the current user-entered query. This property drives both suggestions and searches.
    @Published
    public var currentQuery: String = "" {
        didSet {
            results = .success(nil)
            if currentQuery.isEmpty {
                suggestions = .success(nil)
            }
        }
    }
    
    /// The search area to be used for the current query.  This property should be updated
    /// as the user navigates the map/scene, or at minimum before calling `commitSearch`.
    public var queryArea: Geometry? = nil
    
    /// Defines the center for the search. For most use cases, this should be updated by the view
    /// every time the user navigates the map.
    public var queryCenter: Point?
    
    /// Defines how many results to return. Defaults to Automatic. In automatic mode, an appropriate
    /// number of results is returned based on the type of suggestion chosen
    /// (driven by the IsCollection property).
    public var resultMode: SearchResultMode = .automatic
    
    /// Collection of results. `nil` means no query has been made. An empty array means there
    /// were no results, and the view should show an appropriate 'no results' message.
    @Published
    public private(set) var results: Result<[SearchResult]?, SearchError> = .success(nil) {
        didSet {
            switch results {
            case .success(let results):
                if results != nil && results?.count == 1 {
                    selectedResult = results?.first
                }
                else {
                    selectedResult = nil
                }
            case .failure(_):
                selectedResult = nil
            }
        }
    }
    
    /// Tracks selection of results from the `results` collection. When there is only one result,
    /// that result is automatically assigned to this property. If there are multiple results, the view sets
    /// this property upon user selection. This property is observable. The view should observe this
    /// property and update the associated GeoView's viewpoint, if configured.
    @Published
    public var selectedResult: SearchResult?
    
    /// Collection of search sources to be used. This list is maintained over time and is not nullable.
    /// The view should observe this list for changes. Consumers should add and remove sources from
    /// this list as needed.
    /// NOTE:  only the first source is currently used; multiple sources are not yet supported.
    public var sources: [SearchSourceProtocol] = []
    
    /// Collection of suggestion results. Defaults to `nil`. This collection will be set to empty when there
    /// are no suggestions, `nil` when no suggestions have been requested. If the list is empty,
    /// a useful 'no results' message should be shown by the view.
    @Published
    public private(set) var suggestions: Result<[SearchSuggestion]?, SearchError> = .success(nil)
    
    private var subscriptions = Set<AnyCancellable>()
    
    /// The currently executing async task.  `currentTask` should be cancelled
    /// prior to starting another async task.
    private var currentTask: Task<Void, Never>?
    
    /// Starts a search. `selectedResult` and `results`, among other properties, are set
    /// asynchronously. Other query properties are read to define the parameters of the search.
    public func commitSearch(_ searchArea: Geometry? = nil) async -> Void {
        guard !currentQuery.trimmingCharacters(in: .whitespaces).isEmpty,
              var source = currentSource() else { return }
        
        source.searchArea = searchArea != nil ? searchArea : queryArea
        source.preferredSearchLocation = queryCenter
        
        suggestions = .success(nil)
        
        currentTask?.cancel()
        currentTask = commitSearchTask(source)
        await currentTask?.value
    }
    
    /// Updates suggestions list asynchronously.
    public func updateSuggestions() async -> Void {
        guard !currentQuery.trimmingCharacters(in: .whitespaces).isEmpty,
              var source = currentSource() else { return }
        
        source.searchArea = queryArea
        source.preferredSearchLocation = queryCenter
        
        results = .success(nil)
        
        currentTask?.cancel()
        currentTask = updateSuggestionsTask(source)
        await currentTask?.value
    }
    
    /// Commits a search from a specific suggestion. Results will be set asynchronously. Behavior is
    /// generally the same as `commitSearch`, except `searchSuggestion` is used instead of the
    /// `currentQuery` property.
    /// - Parameters:
    ///   - searchSuggestion: The suggestion to use to commit the search.
    public func acceptSuggestion(
        _ searchSuggestion: SearchSuggestion
    ) async -> Void {
        currentQuery = searchSuggestion.displayTitle
        
        suggestions = .success(nil)
        
        currentTask?.cancel()
        currentTask = acceptSuggestionTask(searchSuggestion)
        await currentTask?.value
    }
    
    /// Clears the search. This will set the results list to null, clear the result selection, clear suggestions,
    /// and reset the current query.
    public func clearSearch() {
        // Setting currentQuery to "" will reset everything necessary.
        currentQuery = ""
    }
}

extension SearchViewModel {
    private func commitSearchTask(
        _ source: SearchSourceProtocol
    ) -> Task<(), Never> {
        let task = Task(operation: {
            let searchResult = await Result {
                try await source.search(currentQuery)
            }
            processSearchResults(searchResult)
        })
        return task
    }
    
    private func updateSuggestionsTask(
        _ source: SearchSourceProtocol
    ) -> Task<(), Never> {
        let task = Task(operation: {
            let suggestResult = await Result {
                try await source.suggest(currentQuery)
            }
            
            DispatchQueue.main.sync {
                switch suggestResult {
                case .success(let suggestResults):
                    suggestions = .success(suggestResults)
                case .failure(let error):
                    suggestions = .failure(SearchError(error))
                    break
                case .none:
                    suggestions = .success(nil)
                    break
                }
            }
        })
        return task
    }
    
    private func acceptSuggestionTask(
        _ searchSuggestion: SearchSuggestion
    ) -> Task<(), Never> {
        let task = Task(operation: {
            let searchResult = await Result {
                try await searchSuggestion.owningSource.search(searchSuggestion)
            }
            
            processSearchResults(
                searchResult,
                isCollection: searchSuggestion.suggestResult?.isCollection ?? true
            )
        })
        return task
    }
    
    private func processSearchResults(
        _ result: Result<[SearchResult], Error>?,
        isCollection: Bool = true
    ) {
        guard let result = result else {
            results = .success([])
            return
        }
        
        DispatchQueue.main.sync {
            var searchResults = [SearchResult]()
            var searchError: Error?
            
            switch result {
            case .success(let results):
                switch (resultMode) {
                case .single:
                    if let firstResult = results.first {
                        searchResults = [firstResult]
                    }
                case .multiple:
                    searchResults = results
                case .automatic:
                    if isCollection {
                        searchResults = results
                    } else {
                        if let firstResult = results.first {
                            searchResults = [firstResult]
                        }
                    }
                }
            case .failure(let error):
                searchError = error
            }
            
            if let error = searchError {
                results = .failure(SearchError(error))
            }
            else {
                results = .success(searchResults)
            }
        }
    }
}

extension SearchViewModel {
    /// Returns the search source to be used in geocode operations.
    /// - Returns: The search source to use.
    func currentSource() -> SearchSourceProtocol? {
        var source: SearchSourceProtocol?
        if let activeSource = activeSource {
            source = activeSource
        } else {
            source = sources.first
        }
        return source
    }
}

public extension String {
    static let defaultPlaceholder = "Find a place or address"
}
