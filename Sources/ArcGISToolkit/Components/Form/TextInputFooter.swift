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

***REMOVED***
***REMOVED***

***REMOVED***/ A view shown at the bottom of each text input element in a form.
struct TextInputFooter: View {
***REMOVED******REMOVED***/ An error that is present when a length constraint is not met.
***REMOVED***@State private var validationError: LengthError?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the text input field has previously satisfied the minimum
***REMOVED******REMOVED***/ length at any point in time.
***REMOVED***@State private var hasPreviouslySatisfiedMinimum: Bool
***REMOVED***
***REMOVED******REMOVED***/ The current length of the text in the text input field.
***REMOVED***private let currentLength: Int
***REMOVED***
***REMOVED******REMOVED***/ The input's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the text input field is focused.
***REMOVED***private let isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ The description of the text input field.
***REMOVED***private let description: String
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the text input field is required.
***REMOVED***@State private var isRequired: Bool
***REMOVED***
***REMOVED******REMOVED***/ The maximum allowable length of text in the text input field.
***REMOVED***private let maxLength: Int
***REMOVED***
***REMOVED******REMOVED***/ The minimum allowable length of text in the text input field.
***REMOVED***private let minLength: Int
***REMOVED***
***REMOVED******REMOVED***/ Creates a footer shown at the bottom of each text input element in a form.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - currentLength: The current length of the text in the text input field.
***REMOVED******REMOVED***/   - isFocused: A Boolean value indicating whether the text input field is focused.
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED******REMOVED***/   - input: A form input that provides length constraints for the text input.
***REMOVED***init(
***REMOVED******REMOVED***currentLength: Int,
***REMOVED******REMOVED***isFocused: Bool,
***REMOVED******REMOVED***element: FieldFormElement,
***REMOVED******REMOVED***input: FormInput,
***REMOVED******REMOVED***isRequired: Bool? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.currentLength = currentLength
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.isFocused = isFocused
***REMOVED******REMOVED***self.description = element.description
***REMOVED******REMOVED***self.isRequired = (isRequired == nil ? element.isRequired : isRequired!)
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch input {
***REMOVED******REMOVED***case let input as TextBoxFormInput:
***REMOVED******REMOVED******REMOVED***self.maxLength = input.maxLength
***REMOVED******REMOVED******REMOVED***self.minLength = input.minLength
***REMOVED******REMOVED******REMOVED***_hasPreviouslySatisfiedMinimum = State(initialValue: currentLength >= input.minLength)
***REMOVED******REMOVED***case let input as TextAreaFormInput:
***REMOVED******REMOVED******REMOVED***self.maxLength = input.maxLength
***REMOVED******REMOVED******REMOVED***self.minLength = input.minLength
***REMOVED******REMOVED******REMOVED***_hasPreviouslySatisfiedMinimum = State(initialValue: currentLength >= input.minLength)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fatalError("\(Self.self) can only be used with \(TextAreaFormInput.self) or \(TextBoxFormInput.self)")
***REMOVED***
***REMOVED******REMOVED***validate(length: currentLength, focused: isFocused, isRequired: self.isRequired)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack(alignment: .top) {
***REMOVED******REMOVED******REMOVED***if let primaryMessage {
***REMOVED******REMOVED******REMOVED******REMOVED***primaryMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Footer")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if isFocused, description.isEmpty || validationError != nil {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(currentLength, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Character Indicator")
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
***REMOVED******REMOVED******REMOVED******REMOVED***validate(length: newLength, focused: isFocused, isRequired: isRequired)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: isFocused) { newIsFocused in
***REMOVED******REMOVED******REMOVED***if hasPreviouslySatisfiedMinimum || !newIsFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***validate(length: currentLength, focused: newIsFocused, isRequired: isRequired)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension TextInputFooter {
***REMOVED******REMOVED***/ The primary message to be shown in the footer, if any, dependent on the presence of a
***REMOVED******REMOVED***/ validation error, description, and focus state.
***REMOVED***var primaryMessage: Text? {
***REMOVED******REMOVED***switch (validationError, description.isEmpty, isFocused) {
***REMOVED******REMOVED***case (.none, true, true):
***REMOVED******REMOVED******REMOVED***return validationText
***REMOVED******REMOVED***case (.none, true, false):
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***case (.none, false, _):
***REMOVED******REMOVED******REMOVED***return Text(description)
***REMOVED******REMOVED***case (.some(let lengthError), _, _):
***REMOVED******REMOVED******REMOVED***switch (lengthError, scheme) {
***REMOVED******REMOVED******REMOVED***case (.emptyWhenRequired, .max):
***REMOVED******REMOVED******REMOVED******REMOVED***return .required
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***return validationText
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The length validation scheme performed on the text input, determined by the minimum and
***REMOVED******REMOVED***/ maximum lengths.
***REMOVED***var scheme: LengthValidationScheme {
***REMOVED******REMOVED***if minLength == 0 {
***REMOVED******REMOVED******REMOVED***return .max
***REMOVED*** else if minLength == maxLength {
***REMOVED******REMOVED******REMOVED***return .exact
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .minAndMax
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The length validation text, dependent on the length validation scheme.
***REMOVED***var validationText: Text {
***REMOVED******REMOVED***switch scheme {
***REMOVED******REMOVED***case .max:
***REMOVED******REMOVED******REMOVED***return maximumText
***REMOVED******REMOVED***case .minAndMax:
***REMOVED******REMOVED******REMOVED***return minAndMaxText
***REMOVED******REMOVED***case .exact:
***REMOVED******REMOVED******REMOVED***return exactText
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Checks for any validation errors and updates the value of `validationError`.
***REMOVED******REMOVED***/ - Parameter length: The length of text to use for validation.
***REMOVED******REMOVED***/ - Parameter focused: The focus state to use for validation.
***REMOVED***func validate(length: Int, focused: Bool, isRequired: Bool) {
***REMOVED******REMOVED***if length == .zero && isRequired && !focused {
***REMOVED******REMOVED******REMOVED***validationError = .emptyWhenRequired
***REMOVED*** else if length < minLength || length > maxLength {
***REMOVED******REMOVED******REMOVED***validationError = .minOrMaxUnmet
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***validationError = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's exact number of allowed characters.
***REMOVED******REMOVED***/ - Note: This is intended to be used in instances where the character minimum and maximum are
***REMOVED******REMOVED***/ identical, such as an ID field; the implementation uses `minLength` but it could just as
***REMOVED******REMOVED***/ well use `maxLength`.
***REMOVED***var exactText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(minLength) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating the user should enter a field's exact number of required characters."
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
***REMOVED******REMOVED***/ Text indicating the user should enter a number of characters between a field's minimum and maximum number of allowed characters.
***REMOVED***var minAndMaxText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(minLength) to \(maxLength) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating the user should enter a number of characters between a field's minimum and maximum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
