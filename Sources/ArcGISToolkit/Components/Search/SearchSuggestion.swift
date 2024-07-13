***REMOVED***
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import Foundation
***REMOVED***

***REMOVED***/ Wraps a suggestion for display.
public struct SearchSuggestion: Sendable {
***REMOVED******REMOVED***/ Creates a `SearchSuggestion`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - displayTitle: The string to be used when displaying a suggestion.
***REMOVED******REMOVED***/   - owningSource: Reference to the `SearchSource` that created this suggestion.
***REMOVED******REMOVED***/   - isCollection: `true` if the search from this suggestion should be treated like a collection search, `false` if the search would return a single result.
***REMOVED******REMOVED***/   - displaySubtitle: Optional subtitle that can be displayed when showing a suggestion.
***REMOVED******REMOVED***/   - suggestResult: Underlying suggest result if this suggestion was created by a LocatorTask.
***REMOVED***public init(
***REMOVED******REMOVED***displayTitle: String,
***REMOVED******REMOVED***owningSource: SearchSource,
***REMOVED******REMOVED***isCollection: Bool = false,
***REMOVED******REMOVED***displaySubtitle: String = "",
***REMOVED******REMOVED***suggestResult: SuggestResult? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.displayTitle = displayTitle
***REMOVED******REMOVED***self.owningSource = owningSource
***REMOVED******REMOVED***self.isCollection = isCollection
***REMOVED******REMOVED***self.displaySubtitle = displaySubtitle
***REMOVED******REMOVED***self.suggestResult = suggestResult
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The string to be used when displaying a suggestion.
***REMOVED***public let displayTitle: String
***REMOVED***
***REMOVED******REMOVED***/ Reference to the `SearchSource` that created this suggestion. This property is necessary for the
***REMOVED******REMOVED***/ view model to be able to accept a suggestion because a suggestion should only be used with the
***REMOVED******REMOVED***/ locator that created it.
***REMOVED***public let owningSource: SearchSource
***REMOVED***
***REMOVED******REMOVED***/ `true` if the search from this suggestion should be treated like a collection search, `false` if the
***REMOVED******REMOVED***/ search would return a single result. This property should be used to display a different icon
***REMOVED******REMOVED***/ in the UI depending on if this is a category search (like 'Coffee', 'Pizza', or 'Starbucks') and
***REMOVED******REMOVED***/ `false` if it is a search for a specific result (e.g. '380 New York St. Redlands CA').
***REMOVED***public let isCollection: Bool
***REMOVED***
***REMOVED******REMOVED***/ Optional subtitle that can be displayed when showing a suggestion.
***REMOVED***public let displaySubtitle: String
***REMOVED***
***REMOVED******REMOVED***/ Underlying suggest result if this suggestion was created by a LocatorTask. This can be `nil`, and
***REMOVED******REMOVED***/ is likely to be `nil` when using custom `SearchSource` implementations.
***REMOVED***public let suggestResult: SuggestResult?
***REMOVED***
***REMOVED***public let id = UUID()
***REMOVED***

extension SearchSuggestion: Identifiable {***REMOVED***

extension SearchSuggestion: Equatable {
***REMOVED***public static func == (lhs: SearchSuggestion, rhs: SearchSuggestion) -> Bool {
***REMOVED******REMOVED***lhs.id == rhs.id
***REMOVED***
***REMOVED***

extension SearchSuggestion: Hashable {
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED******REMOVED*** Note: We're not hashing `suggestResult` as `SearchSuggestion` is
***REMOVED******REMOVED******REMOVED*** created from a `SuggestResult` and `suggestResult` will be different
***REMOVED******REMOVED******REMOVED*** for two separate geocode operations even though they represent the
***REMOVED******REMOVED******REMOVED*** same suggestion.
***REMOVED******REMOVED***hasher.combine(id)
***REMOVED***
***REMOVED***

extension SearchSuggestion {
***REMOVED***init(suggestResult: SuggestResult, searchSource: SearchSource) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***displayTitle: suggestResult.label,
***REMOVED******REMOVED******REMOVED***owningSource: searchSource,
***REMOVED******REMOVED******REMOVED***isCollection: suggestResult.isCollection,
***REMOVED******REMOVED******REMOVED***suggestResult: suggestResult
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
