// Copyright 2021 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS

/// Defines the contract for a search result provider.
@preconcurrency
public protocol SearchSource: Sendable {
    /// Name to show when presenting this source in the UI.
    var name: String { get set }
    
    /// The maximum results to return when performing a search. Most sources default to `6`.
    var maximumResults: Int { get set }
    
    /// The maximum suggestions to return. Most sources default to `6`.
    var maximumSuggestions: Int { get set }
    
    /// Returns the search suggestions for the specified query.
    /// - Parameters:
    ///   - query: The query for which to provide search suggestions.
    ///   - searchArea: The area used to limit results.
    ///   - preferredSearchLocation: The location used as a starting point for searches.
    /// - Returns: An array of search suggestions.
    func suggest(
        _ query: String,
        searchArea: Geometry?,
        preferredSearchLocation: Point?
    ) async throws -> [SearchSuggestion]
    
    /// Gets search results.
    /// - Parameters:
    ///   - query: Text to be used for query.
    ///   - searchArea: The area used to limit results.
    ///   - preferredSearchLocation: The location used as a starting point for searches.
    /// - Returns: An array of search results.
    func search(
        _ query: String,
        searchArea: Geometry?,
        preferredSearchLocation: Point?
    ) async throws -> [SearchResult]
    
    /// Returns the search results for the specified search suggestion.
    /// - Parameters:
    ///   - searchSuggestion: The search suggestion for which to provide search results.
    ///   - searchArea: The area used to limit results.
    ///   - preferredSearchLocation: The location used as a starting point for searches.
    /// - Returns: An array of search results.
    func search(
        _ searchSuggestion: SearchSuggestion,
        searchArea: Geometry?,
        preferredSearchLocation: Point?
    ) async throws -> [SearchResult]
    
    /// Repeats the last search.
    /// - Parameters:
    ///   - query: Text to be used for query.
    ///   - searchExtent: Extent used to limit the results.
    /// - Returns: An array of search results.
    func repeatSearch(
        _ query: String,
        searchExtent: Envelope
    ) async throws -> [SearchResult]
}
