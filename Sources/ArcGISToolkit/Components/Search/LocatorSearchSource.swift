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
public class LocatorSearchSource {
    public init(locator: LocatorTask = LocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!),
                geocodeParameters: GeocodeParameters = GeocodeParameters(),
                suggestParameters: SuggestParameters = SuggestParameters(),
                displayName: String = "Search",
                maximumResults: Int = 6,
                maximumSuggestions: Int = 6,
                searchArea: Geometry? = nil,
                preferredSearchLocation: Point? = nil) {
        self.locator = locator
        self.geocodeParameters = geocodeParameters
        self.suggestParameters = suggestParameters
        self.displayName = displayName
        self.maximumResults = maximumResults
        self.maximumSuggestions = maximumSuggestions
        self.searchArea = searchArea
        self.preferredSearchLocation = preferredSearchLocation
    }
    
    /// The locator used by this search source.
    var locator: LocatorTask = LocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
    
    /// Parameters used for geocoding. Some properties on parameters will be updated automatically
    /// based on searches.
    var geocodeParameters: GeocodeParameters = GeocodeParameters()
    
    /// Parameters used for getting suggestions. Some properties will be updated automatically
    /// based on searches.
    var suggestParameters: SuggestParameters = SuggestParameters()
    
    public var displayName: String = "Search"
    
    public var maximumResults: Int = 6
    
    public var maximumSuggestions: Int = 6
    
    public var searchArea: Geometry?
    
    public var preferredSearchLocation: Point?
}

extension LocatorSearchSource: SearchSourceProtocol {
    public func suggest(_ queryString: String) async throws -> [SearchSuggestion] {
        let suggestResults =  try await locator.suggest(searchText: queryString)
        //convert to search results
        return suggestResults.map{ $0.toSearchSuggestion(searchSource: self) }
    }
    
    public func search(_ queryString: String, area: Geometry? = nil) async throws -> [SearchResult] {
        let geocodeResults =  try await locator.geocode(searchText: queryString)
        //convert to search results
        return geocodeResults.map{ $0.toSearchResult(searchSource: self) }
    }
    
    public func search(_ searchSuggestion: SearchSuggestion, area: Geometry? = nil) async throws -> [SearchResult] {
        guard let query = searchSuggestion.suggestResult?.label else { return [] }
        let geocodeResults =  try await locator.geocode(searchText: query)
        return geocodeResults.map{ $0.toSearchResult(searchSource: self) }
    }
}
