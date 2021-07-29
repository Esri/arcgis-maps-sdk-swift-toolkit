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

extension SuggestResult {
***REMOVED******REMOVED***/ Converts a `SuggestResult` to a `SearchSuggestion`.
***REMOVED******REMOVED***/ - Parameter searchSource: The search source generating the result.
***REMOVED******REMOVED***/ - Returns: The new `SearchSuggestion`.
***REMOVED***func toSearchSuggestion(searchSource: SearchSourceProtocol) -> SearchSuggestion {
***REMOVED******REMOVED***return SearchSuggestion(displayTitle: label,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***displaySubtitle: nil,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***owningSource: searchSource,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***suggestResult: self,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isCollection: isCollection)
***REMOVED***
***REMOVED***
