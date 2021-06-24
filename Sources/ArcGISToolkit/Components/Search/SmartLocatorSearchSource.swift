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
    
    //    @State
    //    private var address: String = ""
    //
    //    @State
    //    private var result: Result<[GeocodeResult], Error> = .success([])
}
