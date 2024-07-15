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

import Foundation
import ArcGIS

/// Wraps a suggestion for display.
public struct SearchSuggestion: Sendable {
    /// Creates a `SearchSuggestion`.
    /// - Parameters:
    ///   - displayTitle: The string to be used when displaying a suggestion.
    ///   - owningSource: Reference to the `SearchSource` that created this suggestion.
    ///   - isCollection: `true` if the search from this suggestion should be treated like a collection search, `false` if the search would return a single result.
    ///   - displaySubtitle: Optional subtitle that can be displayed when showing a suggestion.
    ///   - suggestResult: Underlying suggest result if this suggestion was created by a LocatorTask.
    public init(
        displayTitle: String,
        owningSource: SearchSource,
        isCollection: Bool = false,
        displaySubtitle: String = "",
        suggestResult: SuggestResult? = nil
    ) {
        self.displayTitle = displayTitle
        self.owningSource = owningSource
        self.isCollection = isCollection
        self.displaySubtitle = displaySubtitle
        self.suggestResult = suggestResult
    }
    
    /// The string to be used when displaying a suggestion.
    public let displayTitle: String
    
    /// Reference to the `SearchSource` that created this suggestion. This property is necessary for the
    /// view model to be able to accept a suggestion because a suggestion should only be used with the
    /// locator that created it.
    public let owningSource: SearchSource
    
    /// `true` if the search from this suggestion should be treated like a collection search, `false` if the
    /// search would return a single result. This property should be used to display a different icon
    /// in the UI depending on if this is a category search (like 'Coffee', 'Pizza', or 'Starbucks') and
    /// `false` if it is a search for a specific result (e.g. '380 New York St. Redlands CA').
    public let isCollection: Bool
    
    /// Optional subtitle that can be displayed when showing a suggestion.
    public let displaySubtitle: String
    
    /// Underlying suggest result if this suggestion was created by a LocatorTask. This can be `nil`, and
    /// is likely to be `nil` when using custom `SearchSource` implementations.
    public let suggestResult: SuggestResult?
    
    public let id = UUID()
}

extension SearchSuggestion: Identifiable {}

extension SearchSuggestion: Equatable {
    public static func == (lhs: SearchSuggestion, rhs: SearchSuggestion) -> Bool {
        lhs.id == rhs.id
    }
}

extension SearchSuggestion: Hashable {
    public func hash(into hasher: inout Hasher) {
        // Note: We're not hashing `suggestResult` as `SearchSuggestion` is
        // created from a `SuggestResult` and `suggestResult` will be different
        // for two separate geocode operations even though they represent the
        // same suggestion.
        hasher.combine(id)
    }
}

extension SearchSuggestion {
    init(suggestResult: SuggestResult, searchSource: SearchSource) {
        self.init(
            displayTitle: suggestResult.label,
            owningSource: searchSource,
            isCollection: suggestResult.isCollection,
            suggestResult: suggestResult
        )
    }
}
