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
***REMOVED******REMOVED***/ An error present when a validation constraint is unmet.
***REMOVED***@State private var validationError: TextValidationError?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the text input field has previously satisfied the minimum
***REMOVED******REMOVED***/ length at any point in time.
***REMOVED***@State private var hasPreviouslySatisfiedMinimum: Bool
***REMOVED***
***REMOVED******REMOVED***/ The current text in the text input field.
***REMOVED***private let text: String
***REMOVED***
***REMOVED******REMOVED***/ The current length of the text in the text input field.
***REMOVED***private let currentLength: Int
***REMOVED***
***REMOVED******REMOVED***/ The footer's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The field type of the text input.
***REMOVED***private let fieldType: FieldType
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the text input field is focused.
***REMOVED***private let isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ The description of the text input field.
***REMOVED***private let description: String
***REMOVED***
***REMOVED******REMOVED***/ The allowable length of text in the text input field.
***REMOVED***private let lengthRange: ClosedRange<Int>?
***REMOVED***
***REMOVED******REMOVED***/ The allowable range of numeric values in the text input field.
***REMOVED***private let rangeDomain: RangeDomain?
***REMOVED***
***REMOVED******REMOVED***/ Creates a footer shown at the bottom of each text input element in a form.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - text: The current text in the text input field.
***REMOVED******REMOVED***/   - isFocused: A Boolean value indicating whether the text input field is focused.
***REMOVED******REMOVED***/   - element: The footer's parent element.
***REMOVED******REMOVED***/   - input: A form input that provides length constraints for the text input.
***REMOVED******REMOVED***/   - rangeDomain: The allowable range of numeric values in the text input field.
***REMOVED******REMOVED***/   - fieldType: The field type of the text input.
***REMOVED***init(
***REMOVED******REMOVED***text: String,
***REMOVED******REMOVED***isFocused: Bool,
***REMOVED******REMOVED***element: FieldFormElement,
***REMOVED******REMOVED***input: FormInput,
***REMOVED******REMOVED***rangeDomain: RangeDomain? = nil,
***REMOVED******REMOVED***fieldType: FieldType
***REMOVED***) {
***REMOVED******REMOVED***self.text = text
***REMOVED******REMOVED***self.currentLength = text.count
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.isFocused = isFocused
***REMOVED******REMOVED***self.description = element.description
***REMOVED******REMOVED***self.rangeDomain = rangeDomain
***REMOVED******REMOVED***self.fieldType = fieldType
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch input {
***REMOVED******REMOVED***case let input as TextBoxFormInput:
***REMOVED******REMOVED******REMOVED***lengthRange = fieldType == .text ? input.minLength...input.maxLength : nil
***REMOVED******REMOVED******REMOVED***_hasPreviouslySatisfiedMinimum = State(
***REMOVED******REMOVED******REMOVED******REMOVED***initialValue: !fieldType.isNumeric && currentLength >= input.minLength
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case let input as TextAreaFormInput:
***REMOVED******REMOVED******REMOVED***lengthRange = input.minLength...input.maxLength
***REMOVED******REMOVED******REMOVED***_hasPreviouslySatisfiedMinimum = State(
***REMOVED******REMOVED******REMOVED******REMOVED***initialValue: !fieldType.isNumeric && currentLength >= input.minLength
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fatalError("\(Self.self) can only be used with \(TextAreaFormInput.self) or \(TextBoxFormInput.self)")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack(alignment: .top) {
***REMOVED******REMOVED******REMOVED***if let primaryMessage {
***REMOVED******REMOVED******REMOVED******REMOVED***primaryMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Footer")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if isFocused, description.isEmpty || validationError != nil, !fieldType.isNumeric {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(currentLength, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Character Indicator")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***.foregroundColor(validationError == nil ? .secondary : .red)
***REMOVED******REMOVED***.onChange(of: text) { newText in
***REMOVED******REMOVED******REMOVED***if !hasPreviouslySatisfiedMinimum && !fieldType.isNumeric {
***REMOVED******REMOVED******REMOVED******REMOVED***if newText.count >= lengthRange!.lowerBound {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***hasPreviouslySatisfiedMinimum = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***validate(text: newText, focused: isFocused)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: isFocused) { newIsFocused in
***REMOVED******REMOVED******REMOVED***if hasPreviouslySatisfiedMinimum || !newIsFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***validate(text: text, focused: newIsFocused)
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
***REMOVED******REMOVED***case (.some(let validationError), _, _):
***REMOVED******REMOVED******REMOVED***switch (validationError, scheme) {
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
***REMOVED******REMOVED***if lengthRange?.lowerBound == 0 {
***REMOVED******REMOVED******REMOVED***return .max
***REMOVED*** else if lengthRange?.lowerBound == lengthRange?.upperBound {
***REMOVED******REMOVED******REMOVED***return .exact
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .minAndMax
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The length validation text, dependent on the length validation scheme.
***REMOVED***var validationText: Text {
***REMOVED******REMOVED***if fieldType.isNumeric {
***REMOVED******REMOVED******REMOVED***if validationError == .nonInteger {
***REMOVED******REMOVED******REMOVED******REMOVED***return expectedInteger
***REMOVED******REMOVED*** else if  validationError == .nonDecimal {
***REMOVED******REMOVED******REMOVED******REMOVED***return expectedDecimal
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return rangeDomain == nil ? Text("") : minAndMaxValue
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***switch scheme {
***REMOVED******REMOVED******REMOVED***case .max:
***REMOVED******REMOVED******REMOVED******REMOVED***return maximumText
***REMOVED******REMOVED******REMOVED***case .minAndMax:
***REMOVED******REMOVED******REMOVED******REMOVED***return minAndMaxText
***REMOVED******REMOVED******REMOVED***case .exact:
***REMOVED******REMOVED******REMOVED******REMOVED***return exactText
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Checks for any validation errors and updates the value of `validationError`.
***REMOVED******REMOVED***/ - Parameter text: The text to use for validation.
***REMOVED******REMOVED***/ - Parameter focused: The focus state to use for validation.
***REMOVED***func validate(text: String, focused: Bool) {
***REMOVED******REMOVED***if fieldType.isNumeric {
***REMOVED******REMOVED******REMOVED***if !fieldType.isFloatingPoint && !text.isInteger {
***REMOVED******REMOVED******REMOVED******REMOVED***validationError = .nonInteger
***REMOVED******REMOVED*** else if fieldType.isFloatingPoint && !text.isDecimal {
***REMOVED******REMOVED******REMOVED******REMOVED***validationError = .nonDecimal
***REMOVED******REMOVED*** else if !(rangeDomain?.contains(text) ?? false) {
***REMOVED******REMOVED******REMOVED******REMOVED***validationError = .outOfRange
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***validationError = nil
***REMOVED******REMOVED***
***REMOVED*** else if text.count == .zero && element.isRequired && !focused {
***REMOVED******REMOVED******REMOVED***validationError = .emptyWhenRequired
***REMOVED*** else if !(lengthRange?.contains(text.count) ?? false) {
***REMOVED******REMOVED******REMOVED***validationError = .minOrMaxUnmet
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***validationError = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's exact number of allowed characters.
***REMOVED******REMOVED***/ - Note: This is intended to be used in instances where the character minimum and maximum are
***REMOVED******REMOVED***/ identical, such as an ID field.
***REMOVED***var exactText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(lengthRange!.lowerBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating the user should enter a field's exact number of required characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's value must be convertible to a number.
***REMOVED***var expectedDecimal: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Value must be a number",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be convertible to a number."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's value must be convertible to a whole number.
***REMOVED***var expectedInteger: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Value must be a whole number",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be convertible to a whole number."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's maximum number of allowed characters.
***REMOVED***var maximumText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Maximum \(lengthRange!.upperBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's maximum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating the user should enter a number of characters between a field's minimum and maximum number of allowed characters.
***REMOVED***var minAndMaxText: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(lengthRange!.lowerBound) to \(lengthRange!.upperBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating the user should enter a number of characters between a field's minimum and maximum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's number value is not in the correct range of acceptable values.
***REMOVED***var minAndMaxValue: Text {
***REMOVED******REMOVED***let minAndMax = rangeDomain?.displayableMinAndMax
***REMOVED******REMOVED***if let minAndMax {
***REMOVED******REMOVED******REMOVED***return Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Enter value from \(minAndMax.min) to \(minAndMax.max)",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's number value is not in the correct range of acceptable values."
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Enter value in the allowed range",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's number value is not in the correct range of acceptable values."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

private extension String {
***REMOVED******REMOVED***/ A Boolean value indicating that the string contains no alphabetic or special characters and
***REMOVED******REMOVED***/ can be cast to numeric value.
***REMOVED***var isInteger: Bool {
***REMOVED******REMOVED***return Int(self) != nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating that the string be cast to decimal value.
***REMOVED***var isDecimal: Bool {
***REMOVED******REMOVED***return Double(self) != nil
***REMOVED***
***REMOVED***

extension RangeDomain {
***REMOVED******REMOVED***/ String representations of the minimum and maximum value of the range domain.
***REMOVED***var displayableMinAndMax: (min: String, max: String)? {
***REMOVED******REMOVED***if let min = minValue as? Double, let max = maxValue as? Double {
***REMOVED******REMOVED******REMOVED***return (String(min), String(max))
***REMOVED*** else if let min = minValue as? Int, let max = maxValue as? Int {
***REMOVED******REMOVED******REMOVED***return (String(min), String(max))
***REMOVED*** else if let min = minValue as? Int32, let max = maxValue as? Int32 {
***REMOVED******REMOVED******REMOVED***return (String(min), String(max))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines if the text's numeric value is within the range domain.
***REMOVED******REMOVED***/ - Parameter value: Text with a numeric value.
***REMOVED******REMOVED***/ - Returns: A Boolean value indicating whether the text's numeric value is within the range domain.
***REMOVED***func contains(_ value: String) -> Bool {
***REMOVED******REMOVED***if let min = minValue as? Double, let max = maxValue as? Double, let v = Double(value) {
***REMOVED******REMOVED******REMOVED***return (min...max).contains(v)
***REMOVED*** else if let min = minValue as? Int, let max = maxValue as? Int, let v = Int(value) {
***REMOVED******REMOVED******REMOVED***return (min...max).contains(v)
***REMOVED*** else if let min = minValue as? Int32, let max = maxValue as? Int32, let v = Int32(value)  {
***REMOVED******REMOVED******REMOVED***return (min...max).contains(v)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED***
