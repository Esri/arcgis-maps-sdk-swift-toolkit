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
    public func suggest(_ queryString: String, cancelationToken: String) async throws -> [SearchSuggestion] {
        return []
    }
    
    public func search(_ queryString: String, area: Geometry?, cancellationToken: String?) async throws -> [SearchResult] {
        let geocodeResults =  try await locator.geocode(searchText: queryString)
        //convert to search results
        return geocodeResults.map{ $0.toSearchResult(searchSource: self) }
    }
    
    public func search(_ searchSuggestion: SearchSuggestion, area: Geometry?, cancellationToken: String?) async throws -> [SearchResult] {
        return []
    }
    
    
}

// TODO: add locator name from Locator.locatorInfo.name (can't do it here because search source is no LocatorSearchSource, but maybe could subclass toSearchResult....
// TODO: following Nathan's lead on all this stuff, i.e., go through his code and duplicate it as I go.
// TODO: Should move this to the Extensions folder in it's own file (along with Identifieable compliance).
extension GeocodeResult {
    func toSearchResult(searchSource: SearchSourceProtocol) -> SearchResult {
        return SearchResult(displayTitle: self.label,
                            displaySubtitle: "Score: \((self.score).formatted(.percent))",
                            markerImage: nil,
                            owningSource: searchSource,
                            geoElement: nil,
                            selectionViewpoint: nil)
    }
}
