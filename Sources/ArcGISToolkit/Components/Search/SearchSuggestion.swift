// Copyright 2021 Esri.

import ArcGIS

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Wraps a suggestion for display.
public struct SearchSuggestion {
    /// Title that should be used when displaying a suggestion.
    var displayTitle: String
    
    /// Optional subtitle that can be displayed when showing a suggestion.
    var displaySubtitle: String
    
    /// Reference to the ISearchSource that created this suggestion. This property is necessary for the
    /// view model to be able to accept a suggestion, because a suggestion should only be used with the
    /// locator that created it.
    var owningSource: SearchSourceProtocol
    
    /// Underlying suggest result if this suggestion was created by a LocatorTask. This can be `nil`, and
    /// is likely to be `nil` when using custom `SearchSourceProtocol` implementations.
    var suggestResult: SuggestResult?
    
    /// True if the search from this suggestion should be treated like a collection search, false if the
    /// search would return a single result. This property should be used to display a different icon
    /// in the UI depending on if this is a category search (like 'Coffee', 'Pizza', or 'Starbucks') and
    /// false if it is a search for a specific result (e.g. '380 New York St. Redlands CA').
    var isCollection: Bool
}
