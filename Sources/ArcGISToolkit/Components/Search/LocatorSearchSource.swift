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

import Foundation
import ArcGIS

/// Uses a Locator to provide search and suggest results. Most configuration should be done on the
/// `GeocodeParameters` directly.
public class LocatorSearchSource: ObservableObject, SearchSourceProtocol {
    /// Creates a locator search source.
    /// - Parameters:
    ///   - displayName: Name to show when presenting this source in the UI.
    ///   - maximumResults: The maximum results to return when performing a search. Most sources default to 6.
    ///   - maximumSuggestions: The maximum suggestions to return. Most sources default to 6.
    ///   - searchArea: Area to be used as a constraint for searches and suggestions.
    ///   - preferredSearchLocation: Point to be used as an input to searches and suggestions.
    public init(
        displayName: String = "Locator",
        locatorTask: LocatorTask = LocatorTask(
            url: URL(
                string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
            )!
        ),
        maximumResults: Int32 = 6,
        maximumSuggestions: Int32 = 6,
        searchArea: Geometry? = nil,
        preferredSearchLocation: Point? = nil
    ) {
        self.displayName = displayName
        self.locatorTask = locatorTask
        self.maximumResults = maximumResults
        self.maximumSuggestions = maximumSuggestions
        self.searchArea = searchArea
        self.preferredSearchLocation = preferredSearchLocation
    }
    
    /// Name to show when presenting this source in the UI.
    public var displayName: String
    
    /// The maximum results to return when performing a search. Most sources default to 6
    public var maximumResults: Int32 {
        get {
            geocodeParameters.maxResults
        }
        set {
            geocodeParameters.maxResults = newValue
        }
    }
    
    /// The maximum suggestions to return. Most sources default to 6.
    public var maximumSuggestions: Int32 {
        get {
            suggestParameters.maxResults
        }
        set {
            suggestParameters.maxResults = newValue
        }
    }
    
    /// Area to be used as a constraint for searches and suggestions.
    public var searchArea: Geometry?
    
    /// Point to be used as an input to searches and suggestions.
    public var preferredSearchLocation: Point?
    
    /// The locator used by this search source.
    public private(set) var locatorTask: LocatorTask
    
    /// Parameters used for geocoding. Some properties on parameters will be updated automatically
    /// based on searches.
    public private(set) var geocodeParameters: GeocodeParameters = GeocodeParameters()
    
    /// Parameters used for getting suggestions. Some properties will be updated automatically
    /// based on searches.
    public private(set) var suggestParameters: SuggestParameters = SuggestParameters()
    
    public func search(_ queryString: String) async throws -> [SearchResult] {
        geocodeParameters.searchArea = searchArea
        geocodeParameters.preferredSearchLocation = preferredSearchLocation
        
        let geocodeResults = try await locatorTask.geocode(
            searchText: queryString,
            parameters: geocodeParameters
        )
        
        // Convert to SearchResults and return.
        return geocodeResults.map{ $0.toSearchResult(searchSource: self) }
    }
    
    public func search(
        _ searchSuggestion: SearchSuggestion
    ) async throws -> [SearchResult] {
        guard let suggestResult = searchSuggestion.suggestResult else { return [] }
        
        geocodeParameters.searchArea = searchArea
        geocodeParameters.preferredSearchLocation = preferredSearchLocation
        
        let geocodeResults = try await locatorTask.geocode(
            suggestResult: suggestResult,
            parameters: geocodeParameters
        )
        
        // Convert to SearchResults and return.
        return geocodeResults.map{ $0.toSearchResult(searchSource: self) }
    }
    
    public func suggest(
        _ queryString: String
    ) async throws -> [SearchSuggestion] {
        suggestParameters.searchArea = searchArea
        suggestParameters.preferredSearchLocation = preferredSearchLocation
        
        let geocodeResults = try await locatorTask.suggest(
            searchText: queryString,
            parameters: suggestParameters
        )
        // Convert to SearchSuggestions and return.
        return geocodeResults.map{ $0.toSearchSuggestion(searchSource: self) }
    }
}
