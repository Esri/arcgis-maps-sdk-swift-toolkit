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

import ArcGIS

/// Uses a Locator to provide search and suggest results. Most configuration should be done on the
/// `GeocodeParameters` directly.
public protocol LocatorSearchSourceProtocol: SearchSourceProtocol {
    /// The locator used by this search source.
    var locator: LocatorTask { get }
    
    /// Parameters used for geocoding. Some properties on parameters will be updated automatically
    /// based on searches.
    var geocodeParameters: GeocodeParameters { get }
    
    /// Parameters used for getting suggestions. Some properties will be updated automatically
    /// based on searches.
    var suggestParameters: SuggestParameters { get }
}
