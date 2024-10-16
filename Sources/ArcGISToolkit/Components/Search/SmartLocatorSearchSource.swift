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

import SwiftUI
import ArcGIS

/// Extends `LocatorSearchSource` with intelligent search behaviors; adds support for features like
/// type-specific placemarks, repeated search, and more on the world geocode service.
@available(visionOS, unavailable)
public class SmartLocatorSearchSource: LocatorSearchSource {
    /// Creates a smart locator search source.
    /// - Parameters:
    ///   - name: Name to show when presenting this source in the UI.
    ///   - maximumResults: The maximum results to return when performing a search. Most sources default to `6`.
    ///   - maximumSuggestions: The maximum suggestions to return. Most sources default to `6`.
    ///   - repeatSearchResultThreshold: The minimum number of search results to attempt to return.
    ///   - repeatSuggestResultThreshold: The minimum number of suggestions to attempt to return.
    public init(
        name: String = "Smart Locator",
        maximumResults: Int = 6,
        maximumSuggestions: Int = 6,
        repeatSearchResultThreshold: Int? = 1,
        repeatSuggestResultThreshold: Int? = 6
    ) {
        super.init(
            name: name,
            locatorTask: LocatorTask(
                url: URL(
                    string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
                )!
            ),
            maximumResults: maximumResults,
            maximumSuggestions: maximumSuggestions
        )
        self.repeatSearchResultThreshold = repeatSearchResultThreshold
        self.repeatSuggestResultThreshold = repeatSuggestResultThreshold
    }
    
    /// The minimum number of results to attempt to return. If there are too few results, the search is
    /// repeated with loosened parameters until enough results are accumulated. If no search is
    /// successful, it is still possible to have a total number of results less than this threshold. Does not
    /// apply to repeated search with area constraint. Set to `nil` to disable search repeat behavior.
    public var repeatSearchResultThreshold: Int? = 1
    
    /// The minimum number of suggestions to attempt to return. If there are too few suggestions,
    /// request is repeated with loosened constraints until enough suggestions are accumulated.
    /// If no search is successful, it is still possible to have a total number of results less than this
    /// threshold. Does not apply to repeated search with area constraint. Set to `nil` to disable search
    /// repeat behavior.
    public var repeatSuggestResultThreshold: Int? = 6
    
    public override func search(
        _ query: String,
        searchArea: Geometry? = nil,
        preferredSearchLocation: Point? = nil
    ) async throws -> [SearchResult] {
        // First, perform super class search.
        var results = try await super.search(
            query,
            searchArea: searchArea,
            preferredSearchLocation: preferredSearchLocation
        )
        if repeatSearchResultThreshold == nil ||
            results.count > repeatSearchResultThreshold! ||
            geocodeParameters.searchArea == nil {
            // Result count meets threshold or there were no geographic
            // constraints on the search, so return results.
            return results
        }
        
        // Remove geographic constraints and re-run search.
        geocodeParameters.searchArea = nil
        let geocodeResults = try await locatorTask.geocode(
            forSearchText: query,
            using: geocodeParameters
        )
        
        // Union results and return.
        let searchResults = geocodeResults.map {
            SearchResult(geocodeResult: $0, searchSource: self)
        }
        results.append(contentsOf: searchResults)
        
        // Limit results to `maximumResults`.
        return Array(results.prefix(Int(maximumResults)))
    }
    
    public override func search(
        _ searchSuggestion: SearchSuggestion,
        searchArea: Geometry? = nil,
        preferredSearchLocation: Point? = nil
    ) async throws -> [SearchResult] {
        guard let suggestResult = searchSuggestion.suggestResult
        else { return [] }
        
        var results = try await super.search(
            searchSuggestion,
            searchArea: searchArea,
            preferredSearchLocation: preferredSearchLocation
        )
        
        if repeatSearchResultThreshold == nil ||
            results.count > repeatSearchResultThreshold! ||
            geocodeParameters.searchArea == nil {
            // Result count meets threshold or there were no geographic
            // constraints on the search, so return results.
            return results
        }
        
        // Remove geographic constraints and re-run search.
        geocodeParameters.searchArea = nil
        let geocodeResults = try await locatorTask.geocode(
            forSuggestResult: suggestResult,
            using: geocodeParameters
        )
        
        // Union results and return.
        let searchResults = geocodeResults.map {
            SearchResult(geocodeResult: $0, searchSource: self)
        }
        results.append(contentsOf: searchResults)
        
        // Limit results to `maximumResults`.
        return Array(results.prefix(Int(maximumResults)))
    }
    
    public override func suggest(
        _ query: String,
        searchArea: Geometry? = nil,
        preferredSearchLocation: Point? = nil
    ) async throws -> [SearchSuggestion] {
        var results = try await super.suggest(
            query,
            searchArea: searchArea,
            preferredSearchLocation: preferredSearchLocation
        )
        if repeatSuggestResultThreshold == nil ||
            results.count > repeatSuggestResultThreshold! ||
            suggestParameters.searchArea == nil {
            // Result count meets threshold or there were no geographic
            // constraints on the search, so return results.
            return results
        }
        
        // Remove geographic constraints and re-run search.
        suggestParameters.searchArea = nil
        let geocodeResults =  try await locatorTask.suggest(
            forSearchText: query,
            parameters: suggestParameters
        )
        
        // Union results and return.
        let suggestResults = geocodeResults.map {
            SearchSuggestion(suggestResult: $0, searchSource: self)
        }
        results.append(contentsOf: suggestResults)
        
        // Limit results to `maximumSuggestions`.
        return Array(results.prefix(Int(maximumSuggestions)))
    }
}
