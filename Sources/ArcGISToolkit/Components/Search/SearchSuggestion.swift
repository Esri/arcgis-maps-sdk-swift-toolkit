***REMOVED***.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***

***REMOVED***/ Wraps a suggestion for display.
public class SearchSuggestion {
***REMOVED***internal init(
***REMOVED******REMOVED***displayTitle: String,
***REMOVED******REMOVED***displaySubtitle: String? = nil,
***REMOVED******REMOVED***owningSource: SearchSourceProtocol,
***REMOVED******REMOVED***suggestResult: SuggestResult? = nil,
***REMOVED******REMOVED***isCollection: Bool
***REMOVED***) {
***REMOVED******REMOVED***self.displayTitle = displayTitle
***REMOVED******REMOVED***self.displaySubtitle = displaySubtitle
***REMOVED******REMOVED***self.owningSource = owningSource
***REMOVED******REMOVED***self.suggestResult = suggestResult
***REMOVED******REMOVED***self.isCollection = isCollection
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Title that should be used when displaying a suggestion.
***REMOVED***var displayTitle: String
***REMOVED***
***REMOVED******REMOVED***/ Optional subtitle that can be displayed when showing a suggestion.
***REMOVED***var displaySubtitle: String?
***REMOVED***
***REMOVED******REMOVED***/ Reference to the `SearchSourceProtocol` that created this suggestion. This property is necessary for the
***REMOVED******REMOVED***/ view model to be able to accept a suggestion, because a suggestion should only be used with the
***REMOVED******REMOVED***/ locator that created it.
***REMOVED***var owningSource: SearchSourceProtocol
***REMOVED***
***REMOVED******REMOVED***/ Underlying suggest result if this suggestion was created by a LocatorTask. This can be `nil`, and
***REMOVED******REMOVED***/ is likely to be `nil` when using custom `SearchSourceProtocol` implementations.
***REMOVED***var suggestResult: SuggestResult?
***REMOVED***
***REMOVED******REMOVED***/ True if the search from this suggestion should be treated like a collection search, false if the
***REMOVED******REMOVED***/ search would return a single result. This property should be used to display a different icon
***REMOVED******REMOVED***/ in the UI depending on if this is a category search (like 'Coffee', 'Pizza', or 'Starbucks') and
***REMOVED******REMOVED***/ false if it is a search for a specific result (e.g. '380 New York St. Redlands CA').
***REMOVED***var isCollection: Bool
***REMOVED***

extension SearchSuggestion: Identifiable {
***REMOVED***public var id: ObjectIdentifier { ObjectIdentifier(self) ***REMOVED***
***REMOVED***

extension SearchSuggestion: Equatable {
***REMOVED***public static func == (lhs: SearchSuggestion, rhs: SearchSuggestion) -> Bool {
***REMOVED******REMOVED***lhs.hashValue == rhs.hashValue
***REMOVED***
***REMOVED***

extension SearchSuggestion: Hashable {
***REMOVED******REMOVED***/ Note:  we're not hashing `suggestResult` as `SearchSuggestion` is created from
***REMOVED******REMOVED***/ a `SuggestResult` and `suggestResult` will be different for two sepate geocode
***REMOVED******REMOVED***/ operations even though they represent the same suggestion.
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(displayTitle)
***REMOVED******REMOVED***hasher.combine(displaySubtitle)
***REMOVED******REMOVED***hasher.combine(isCollection)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let locatorSource = owningSource as? LocatorSearchSource {
***REMOVED******REMOVED******REMOVED***hasher.combine(ObjectIdentifier(locatorSource))
***REMOVED***
***REMOVED******REMOVED******REMOVED*** If you define a custom type that does NOT inherit from
***REMOVED******REMOVED******REMOVED*** `LocatorSearchSource`, you will need to add an `else if` check
***REMOVED******REMOVED******REMOVED*** for your custom type.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else if let customSearchSource = owningSource as? MyCustomSearchSource {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***hasher.combine(ObjectIdentifier(customSearchSource))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
