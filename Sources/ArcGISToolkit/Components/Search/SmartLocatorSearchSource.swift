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
import ArcGIS

/// Extends `LocatorSearchSource` with intelligent search behaviors; adds support for features like
/// type-specific placemarks, repeated search, and more. Advanced functionality requires knowledge of the
/// underlying locator to be used well; this class implements behaviors that make assumptions about the
/// locator being the world geocode service.
public class SmartLocatorSearchSource: LocatorSearchSource {
    public convenience init(
        displayName: String = "Search",
        maximumResults: Int = 6,
        maximumSuggestions: Int,
        searchArea: Geometry? = nil,
        preferredSearchLocation: Point? = nil,
        repeatSearchResultThreshold: Int = 1,
        repeatSuggestResultThreshold: Int = 6,
        resultSymbolStyle: SymbolStyle? = nil
    ) {
        self.init()
        self.displayName = displayName
        self.maximumResults = maximumResults
        self.maximumSuggestions = maximumSuggestions
        self.searchArea = searchArea
        self.preferredSearchLocation = preferredSearchLocation
        self.repeatSearchResultThreshold = repeatSearchResultThreshold
        self.repeatSuggestResultThreshold = repeatSuggestResultThreshold
        self.resultSymbolStyle = resultSymbolStyle
        
        geocodeParameters.maxResults = Int32(maximumResults)
        suggestParameters.maxResults = Int32(maximumSuggestions)
    }
    
    /// The minimum number of results to attempt to return. If there are too few results, the search is
    /// repeated with loosened parameters until enough results are accumulated. If no search is
    /// successful, it is still possible to have a total number of results less than this threshold. Does not
    /// apply to repeated search with area constraint. Set to zero to disable search repeat behavior.
    var repeatSearchResultThreshold: Int = 1
    
    /// The minimum number of suggestions to attempt to return. If there are too few suggestions,
    /// request is repeated with loosened constraints until enough suggestions are accumulated.
    /// If no search is successful, it is still possible to have a total number of results less than this
    /// threshold. Does not apply to repeated search with area constraint. Set to zero to disable search
    /// repeat behavior.
    var repeatSuggestResultThreshold: Int = 6
    
    /// Web style used to find symbols for results. When set, symbols are found for results based on the
    /// result's `Type` field, if available. Defaults to the style identified by the name
    /// "Esri2DPointSymbolsStyle". The default Esri 2D point symbol has good results for many of the
    /// types returned by the world geocode service. You can use this property to customize result icons
    /// by publishing a web style, taking care to ensure that symbol keys match the `Type` attribute
    /// returned by the locator.
    var resultSymbolStyle: SymbolStyle?

    public override func search(
        _ queryString: String,
        area: Geometry?
    ) async throws -> [SearchResult] {
        // First, peform super class search.
        var results = try await super.search(queryString, area: area)
        if results.count > repeatSearchResultThreshold ||
           area == nil,
           searchArea == nil,
           preferredSearchLocation == nil {
            // Result count meets threshold or there were no geographic
            // constraints on the search, so return results.
            return results
        }
        
        // Remove geographic constraints and re-run search.
        geocodeParameters.searchArea = nil
        geocodeParameters.preferredSearchLocation = nil
        let geocodeResults = try await locator.geocode(
            searchText: queryString,
            parameters: geocodeParameters
        )
        
        // Union results and return.
        let searchResults = geocodeResults.map{ $0.toSearchResult(searchSource: self) }
        results.append(contentsOf: searchResults)
        var allResults: [SearchResult] = Array(Set(results))

        // Limit results to `maximumResults`.
        if allResults.count > maximumResults {
            let dropCount = allResults.count - maximumResults
            allResults = allResults.dropLast(dropCount)
        }
        return allResults
    }

    public override func search(
        _ searchSuggestion: SearchSuggestion
    ) async throws -> [SearchResult] {
        guard let suggestResult = searchSuggestion.suggestResult else { return [] }

        var results = try await super.search(searchSuggestion)
        if results.count > repeatSearchResultThreshold ||
           searchArea == nil,
           preferredSearchLocation == nil {
            // Result count meets threshold or there were no geographic
            // constraints on the search, so return results.
            return results
        }

        // Remove geographic constraints and re-run search.
        geocodeParameters.searchArea = nil
        geocodeParameters.preferredSearchLocation = nil
        let geocodeResults = try await locator.geocode(suggestResult: suggestResult,
                                                        parameters: geocodeParameters
        )
        
        // Union results and return.
        let searchResults = geocodeResults.map{ $0.toSearchResult(searchSource: self) }
        results.append(contentsOf: searchResults)
        var allResults: [SearchResult] = Array(Set(results))

        // Limit results to `maximumResults`.
        if allResults.count > maximumResults {
            let dropCount = allResults.count - maximumResults
            allResults = allResults.dropLast(dropCount)
        }
        return allResults
    }
    
    public override func suggest(
        _ queryString: String
    ) async throws -> [SearchSuggestion] {
        var results = try await super.suggest(queryString)
        if results.count > repeatSuggestResultThreshold ||
           searchArea == nil,
           preferredSearchLocation == nil {
            // Result count meets threshold or there were no geographic
            // constraints on the search, so return results.
            return results
        }

        // Remove geographic constraints and re-run search.
        suggestParameters.searchArea = nil
        suggestParameters.preferredSearchLocation = nil
        let geocodeResults =  try await locator.suggest(
            searchText: queryString,
            parameters: suggestParameters
        )
        
        // Union results and return.
        let suggestResults = geocodeResults.map{ $0.toSearchSuggestion(searchSource: self) }
        results.append(contentsOf: suggestResults)
        var allResults: [SearchSuggestion] = Array(Set(results))

        // Limit results to `maximumResults`.
        if allResults.count > maximumSuggestions {
            let dropCount = allResults.count - maximumSuggestions
            allResults = allResults.dropLast(dropCount)
        }
        return allResults
    }
}
