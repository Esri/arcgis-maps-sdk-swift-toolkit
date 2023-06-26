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
***REMOVED******REMOVED******REMOVED***if let validationError {
***REMOVED******REMOVED******REMOVED******REMOVED***switch validationError {
***REMOVED******REMOVED******REMOVED******REMOVED***case .emptyWhenRequired:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***requiredText
***REMOVED******REMOVED******REMOVED******REMOVED***case .tooLong:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maximumText
***REMOVED******REMOVED******REMOVED******REMOVED***case .tooShort:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***minimumText
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else if !description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED*** else if description.isEmpty && isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***maximumText
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(currentLength, format: .number)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***.foregroundColor(validationError == nil ? .secondary : .red)
***REMOVED******REMOVED***.onChange(of: currentLength) { newLength in
***REMOVED******REMOVED******REMOVED***validate(length: newLength, focused: isFocused)
***REMOVED***
***REMOVED******REMOVED***.onChange(of: isFocused) { newFocus in
***REMOVED******REMOVED******REMOVED***validate(length: currentLength, focused: newFocus)
***REMOVED***
***REMOVED***
***REMOVED***

extension TextEntryFooter {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***/ - Parameter length: <#length description#>
***REMOVED******REMOVED***/ - Parameter focused: <#focused description#>
***REMOVED***func validate(length: Int, focused: Bool) {
***REMOVED******REMOVED***if length == .zero && isRequired && !focused {
***REMOVED******REMOVED******REMOVED***validationError = .emptyWhenRequired
***REMOVED*** else if length < minLength {
***REMOVED******REMOVED******REMOVED***validationError = .tooShort
***REMOVED*** else if length > maxLength {
***REMOVED******REMOVED******REMOVED***validationError = .tooLong
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***validationError = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's maximum number of allowed characters.
***REMOVED***var maximumText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Maximum \(maxLength) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's maximum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's minimum and maximum number of allowed characters.
***REMOVED***var minimumText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(minLength) to \(maxLength) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's minimum and maximum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field is required.
***REMOVED***var requiredText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Required",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field is required"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ <#Description#>
enum LengthError {
***REMOVED***case emptyWhenRequired
***REMOVED***case tooLong
***REMOVED***case tooShort
***REMOVED***
