***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import FormsPlugin
***REMOVED***

***REMOVED***/ A view shown at the bottom of each text entry element in a form.
struct TextEntryFooter: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var validationError: LengthError? = nil
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let currentLength: Int
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let description: String
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let isRequired: Bool
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let maxLength: Int
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let minLength: Int
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***if !description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(currentLength, format: .number)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***.foregroundColor(validationError == nil ? .secondary : .red)
***REMOVED******REMOVED***.onChange(of: currentLength) { _ in validateLength() ***REMOVED***
***REMOVED******REMOVED***.onChange(of: isFocused) { _ in validateLength() ***REMOVED***
***REMOVED***
***REMOVED***

extension TextEntryFooter {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***func validateLength() {
***REMOVED******REMOVED***if currentLength == .zero && isRequired {
***REMOVED******REMOVED******REMOVED***validationError = .emptyWhenRequired
***REMOVED*** else if currentLength < minLength {
***REMOVED******REMOVED******REMOVED***validationError = .tooShort
***REMOVED*** else if currentLength > maxLength {
***REMOVED******REMOVED******REMOVED***validationError = .tooLong
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***validationError = nil
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ <#Description#>
enum LengthError {
***REMOVED***case emptyWhenRequired
***REMOVED***case tooLong
***REMOVED***case tooShort
***REMOVED***
