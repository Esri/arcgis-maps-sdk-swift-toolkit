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
public struct SmartLocatorSearchSource {
    public init(repeatSearchResultThreshold: Int = 1,
                repeatSuggestResultThreshold: Int = 6,
                resultSymbolStyle: SymbolStyle? = nil,
                locator: LocatorTask = LocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!),
                geocodeParameters: GeocodeParameters,
                suggestParameters: SuggestParameters,
                displayName: String = "Search",
                maximumResults: Int = 6,
                maximumSuggestions: Int = 6,
                searchArea: Geometry? = nil,
                preferredSearchLocation: Point? = nil
    ){
        self.repeatSearchResultThreshold = repeatSearchResultThreshold
        self.repeatSuggestResultThreshold = repeatSuggestResultThreshold
        self.resultSymbolStyle = resultSymbolStyle
        self._locator = locator
        self._geocodeParameters = geocodeParameters
        self._suggestParameters = suggestParameters
        self._displayName = displayName
        self._maximumResults = maximumResults
        self._maximumSuggestions = maximumSuggestions
        self._searchArea = searchArea
        self._preferredSearchLocation = preferredSearchLocation
    }
    
    /// The minimum number of results to attempt to return. If there are too few results, the search is
    /// repeated with loosened parameters until enough results are accumulated. If no search is
    /// successful, it is still possible to have a total number of results less than this threshold. Does not
    /// apply to repeated search with area constraint. Set to zero to disable search repeat behavior.
    var repeatSearchResultThreshold: Int
    
    /// The minimum number of suggestions to attempt to return. If there are too few suggestions,
    /// request is repeated with loosened constraints until enough suggestions are accumulated.
    /// If no search is successful, it is still possible to have a total number of results less than this
    /// threshold. Does not apply to repeated search with area constraint. Set to zero to disable search
    /// repeat behavior.
    var repeatSuggestResultThreshold: Int
    
    /// Web style used to find symbols for results. When set, symbols are found for results based on the
    /// result's `Type` field, if available. Defaults to the style identified by the name
    /// "Esri2DPointSymbolsStyle". The default Esri 2D point symbol has good results for many of the
    /// types returned by the world geocode service. You can use this property to customize result icons
    /// by publishing a web style, taking care to ensure that symbol keys match the `Type` attribute
    /// returned by the locator.
    var resultSymbolStyle: SymbolStyle?
    
    /// The locator used by this search source.
    private var _locator: LocatorTask = LocatorTask(url: URL(string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
    
    /// Parameters used for geocoding. Some properties on parameters will be updated automatically
    /// based on searches.
    private var _geocodeParameters: GeocodeParameters
    
    /// Parameters used for getting suggestions. Some properties will be updated automatically
    /// based on searches.
    private var _suggestParameters: SuggestParameters
    
    /// Name to show when presenting this source in the UI.
    private var _displayName: String
    
    /// The maximum results to return when performing a search. Most sources default to 6.
    private var _maximumResults: Int
    
    /// The maximum suggestions to return. Most sources default to 6.
    private var _maximumSuggestions: Int
    
    /// Area to be used as a constraint for searches and suggestions.
    private var _searchArea: Geometry?
    
    /// Point to be used as an input to searches and suggestions.
    private var _preferredSearchLocation: Point?
    
    //    @State
    //    private var address: String = ""
    //
    //    @State
    //    private var result: Result<[GeocodeResult], Error> = .success([])
}

extension SmartLocatorSearchSource: LocatorSearchSourceProtocol {
    public var locator: LocatorTask {
        get {
            return _locator
        }
    }
    
    public var geocodeParameters: GeocodeParameters {
        get {
            return _geocodeParameters
        }
    }
    
    public var suggestParameters: SuggestParameters {
        get {
            return _suggestParameters
        }
    }
    
    public var displayName: String {
        get {
            return _displayName
        }
        set {
            _displayName = newValue
        }
    }
    
    public var maximumResults: Int {
        get {
            return _maximumResults
        }
        set {
            _maximumResults = newValue
        }
    }
    
    public var maximumSuggestions: Int {
        get {
            return _maximumSuggestions
        }
        set {
            _maximumSuggestions = newValue
        }
    }
    
    public var searchArea: Geometry? {
        get {
            return _searchArea
        }
        set {
            _searchArea = newValue
        }
    }
    
    public var preferredSearchLocation: Point? {
        get {
            return _preferredSearchLocation
        }
        set {
            _preferredSearchLocation = newValue
        }
    }
    
    public func suggest(_ queryString: String,
                        cancelationToken: String) async throws -> [SearchSuggestion] {
        return []
    }
    
    public func search(_ queryString: String,
                       area: Geometry?,
                       cancellationToken: String?) async throws -> [SearchResult] {
        //        result = await Result { try await locator.geocode(searchText: address) }
        return []
    }
    
    public func search(_ searchSuggestion: SearchSuggestion,
                       area: Geometry?,
                       cancellationToken: String?) async throws -> [SearchResult] {
        return []
    }
}
