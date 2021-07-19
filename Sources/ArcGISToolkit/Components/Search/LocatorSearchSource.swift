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
    public init(displayName: String = "Search",
                maximumResults: Int = 6,
                maximumSuggestions: Int = 6,
                searchArea: Geometry? = nil,
                preferredSearchLocation: Point? = nil) {
        self.displayName = displayName
        self.maximumResults = maximumResults
        self.maximumSuggestions = maximumSuggestions
        self.searchArea = searchArea
        self.preferredSearchLocation = preferredSearchLocation
        
        geocodeParameters.maxResults = Int32(maximumResults)
        suggestParameters.maxResults = Int32(maximumSuggestions)
    }
    
    /// The locator used by this search source.
    private(set) var locator: LocatorTask = LocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
    
    /// Parameters used for geocoding. Some properties on parameters will be updated automatically
    /// based on searches.
    private(set) var geocodeParameters: GeocodeParameters = GeocodeParameters()
    
    /// Parameters used for getting suggestions. Some properties will be updated automatically
    /// based on searches.
    private(set) var suggestParameters: SuggestParameters = SuggestParameters()
    
    public var displayName: String = "Search"
    
    public var maximumResults: Int {
        didSet {
            geocodeParameters.maxResults = Int32(maximumResults)
        }
    }
    
    public var maximumSuggestions: Int {
        didSet {
            suggestParameters.maxResults = Int32(maximumResults)
        }
    }
    
    public var searchArea: Geometry?
    
    public var preferredSearchLocation: Point?

    public func search(_ queryString: String, area: Geometry? = nil) async throws -> [SearchResult] {
        geocodeParameters.searchArea = (area != nil) ? area : searchArea
        geocodeParameters.preferredSearchLocation = preferredSearchLocation
        
        let geocodeResults = try await locator.geocode(searchText: queryString,
                                                       parameters: geocodeParameters
        )
        
        //convert to SearchResults
        return geocodeResults.map{ $0.toSearchResult(searchSource: self) }
    }
    
    public func search(_ searchSuggestion: SearchSuggestion, area: Geometry? = nil) async throws -> [SearchResult] {
        guard let suggestResult = searchSuggestion.suggestResult else { return [] }

        geocodeParameters.searchArea = (area != nil) ? area : searchArea
        geocodeParameters.preferredSearchLocation = preferredSearchLocation

        let geocodeResults = try await locator.geocode(suggestResult: suggestResult,
                                                        parameters: geocodeParameters
        )
        return geocodeResults.map{ $0.toSearchResult(searchSource: self) }
    }

    public func suggest(_ queryString: String) async throws -> [SearchSuggestion] {
        suggestParameters.searchArea = searchArea
        suggestParameters.preferredSearchLocation = preferredSearchLocation

        let suggestResults =  try await locator.suggest(searchText: queryString,
                                                        parameters: suggestParameters
        )
        //convert to SearchSuggestions
        return suggestResults.map{ $0.toSearchSuggestion(searchSource: self) }
    }
}
