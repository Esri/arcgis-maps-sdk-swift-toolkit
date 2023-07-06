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
***REMOVED******REMOVED***/ An error that is present when a length constraint is not met.
***REMOVED***@State private var validationError: LengthError?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the text entry field has previously satisfied the minimum
***REMOVED******REMOVED***/ length at any point in time.
***REMOVED***@State private var hasPreviouslySatisfiedMinimum: Bool
***REMOVED***
***REMOVED******REMOVED***/ The current length of the text in the text entry field.
***REMOVED***private let currentLength: Int
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the text entry field is focused.
***REMOVED***private let isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ The description of the text entry field.
***REMOVED***private let description: String
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the text entry field is required.
***REMOVED***private let isRequired: Bool
***REMOVED***
***REMOVED******REMOVED***/ The maximum allowable length of text in the text entry field.
***REMOVED***private let maxLength: Int
***REMOVED***
***REMOVED******REMOVED***/ The minimum allowable length of text in the text entry field.
***REMOVED***private let minLength: Int
***REMOVED***
***REMOVED******REMOVED***/ Creates a footer shown at the bottom of each text entry element in a form.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - currentLength: The current length of the text in the text entry field.
***REMOVED******REMOVED***/   - isFocused: A Boolean value indicating whether the text entry field is focused.
***REMOVED******REMOVED***/   - element: A field element that provides a description for the text entry and whether
***REMOVED******REMOVED***/  or not text is required for this entry.
***REMOVED******REMOVED***/   - input: A form input that provides length constraints for the text entry.
***REMOVED***init(
***REMOVED******REMOVED***currentLength: Int,
***REMOVED******REMOVED***isFocused: Bool,
***REMOVED******REMOVED***element: FieldFeatureFormElement,
***REMOVED******REMOVED***input: FeatureFormInput
***REMOVED***) {
***REMOVED******REMOVED***self.currentLength = currentLength
***REMOVED******REMOVED***self.isFocused = isFocused
***REMOVED******REMOVED***self.description = element.description ?? ""
***REMOVED******REMOVED***self.isRequired = element.required
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch input {
***REMOVED******REMOVED***case let input as TextBoxFeatureFormInput:
***REMOVED******REMOVED******REMOVED***self.maxLength = input.maxLength
***REMOVED******REMOVED******REMOVED***self.minLength = input.minLength
***REMOVED******REMOVED******REMOVED***_hasPreviouslySatisfiedMinimum = State(initialValue: currentLength >= input.minLength)
***REMOVED******REMOVED***case let input as TextAreaFeatureFormInput:
***REMOVED******REMOVED******REMOVED***self.maxLength = input.maxLength
***REMOVED******REMOVED******REMOVED***self.minLength = input.minLength
***REMOVED******REMOVED******REMOVED***_hasPreviouslySatisfiedMinimum = State(initialValue: currentLength >= input.minLength)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fatalError("TextEntryFooter can only be used with TextAreaFeatureFormInput or TextBoxFeatureFormInput")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack(alignment: .top) {
***REMOVED******REMOVED******REMOVED***if let validationError {
***REMOVED******REMOVED******REMOVED******REMOVED***switch validationError {
***REMOVED******REMOVED******REMOVED******REMOVED***case .emptyWhenRequired:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***requiredText
***REMOVED******REMOVED******REMOVED******REMOVED***case .tooLong:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maximumText
***REMOVED******REMOVED******REMOVED******REMOVED***case .tooShort:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***minAndMaxText
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else if !description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED*** else if isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***if !hasPreviouslySatisfiedMinimum {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***minAndMaxText
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maximumText
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(currentLength, format: .number)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***.foregroundColor(validationError == nil ? .secondary : .red)
***REMOVED******REMOVED***.onChange(of: currentLength) { newLength in
***REMOVED******REMOVED******REMOVED***if !hasPreviouslySatisfiedMinimum {
***REMOVED******REMOVED******REMOVED******REMOVED***if newLength >= minLength {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***hasPreviouslySatisfiedMinimum = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***validate(length: newLength, focused: isFocused)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: isFocused) { newFocus in
***REMOVED******REMOVED******REMOVED***validate(length: currentLength, focused: newFocus)
***REMOVED***
***REMOVED***
***REMOVED***

extension TextEntryFooter {
***REMOVED******REMOVED***/ Checks for any validation errors and updates the value of `validationError`.
***REMOVED******REMOVED***/ - Parameter length: The length of text to use for validation.
***REMOVED******REMOVED***/ - Parameter focused: The focus state to use for validation.
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
***REMOVED******REMOVED***/ Text indicating a field's exact number of allowed characters.
***REMOVED******REMOVED***/ - Note: This is intended to be used in instances where the character minimum and maximum are
***REMOVED******REMOVED***/ identical, such as an ID field; the implementation uses `minLength` but it could just as
***REMOVED******REMOVED***/ well reference `maxLength`.
***REMOVED***var exactText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(minLength) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's exact number of required characters."
***REMOVED******REMOVED***)
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
***REMOVED***var minAndMaxText: Text {
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
