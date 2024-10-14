***REMOVED*** Copyright 2023 Esri
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

***REMOVED***
***REMOVED***

***REMOVED***/ A view shown at the bottom of a field element in a form.
struct InputFooter: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The validation error visibility configuration of a form.
***REMOVED***@Environment(\.validationErrorVisibility) private var validationErrorVisibility
***REMOVED***
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ An ID regenerated each time the element's value changes.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Allows the footer to be recomputed to reflect changes in validation errors or input length.
***REMOVED***@State private var id = UUID()
***REMOVED***
***REMOVED******REMOVED***/ The element the input belongs to.
***REMOVED***let element: FieldFormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack(alignment: .top) {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if isShowingError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***errorMessage
***REMOVED******REMOVED******REMOVED*** else if !element.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED*** else if model.focusedElement == element {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if element.fieldType == .text, let lengthRange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if lengthRange.lowerBound == lengthRange.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeExactLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else if lengthRange.lowerBound > .zero {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeLengthRangeMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeMaximumLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else if element.fieldType?.isNumeric ?? false, let numericRange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeNumericRangeMessage(numericRange)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Footer")
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if isShowingCharacterIndicator {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.formattedValue.count, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Character Indicator")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***.foregroundColor(isShowingError ? .red : .secondary)
***REMOVED******REMOVED***.id(id)
***REMOVED******REMOVED***.padding(.vertical, elementPadding / 2)
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***for await _ in element.$value {
***REMOVED******REMOVED******REMOVED******REMOVED***id = UUID()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension InputFooter {
***REMOVED******REMOVED***/ Localized error text to be shown to a user depending on the type of error information available.
***REMOVED***var errorMessage: Text? {
***REMOVED******REMOVED***guard let error = primaryError else { return nil ***REMOVED***
***REMOVED******REMOVED***return switch error {
***REMOVED******REMOVED***case .nullNotAllowed:
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Value must not be empty",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must not be empty."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .exceedsMaximumDateTime:
***REMOVED******REMOVED******REMOVED***if let input = element.input as? DateTimePickerFormInput, let max = input.max {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Date must be on or before \(max, format: input.includesTime ? .dateTime : .dateTime.month().day().year())",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be on or before the maximum date specified in the variable."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Date exceeds maximum",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must not exceed a maximum date."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .lessThanMinimumDateTime:
***REMOVED******REMOVED******REMOVED***if let input = element.input as? DateTimePickerFormInput, let min = input.min {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Date must be on or after \(min, format: input.includesTime ? .dateTime : .dateTime.month().day().year())",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be on or after the minimum date specified in the variable."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Date less than minimum",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must meet a minimum date."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .exceedsMaximumLength:
***REMOVED******REMOVED******REMOVED***if let lengthRange {
***REMOVED******REMOVED******REMOVED******REMOVED***if lengthRange.lowerBound == lengthRange.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeExactLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeMaximumLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Maximum character length exceeded",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's maximum number of allowed characters is exceeded."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .lessThanMinimumLength:
***REMOVED******REMOVED******REMOVED***if let lengthRange {
***REMOVED******REMOVED******REMOVED******REMOVED***if lengthRange.lowerBound == lengthRange.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeExactLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeLengthRangeMessage(lengthRange)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Minimum character length not met",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's minimum number of allowed characters is not met."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .exceedsNumericMaximum:
***REMOVED******REMOVED******REMOVED***if let numericRange {
***REMOVED******REMOVED******REMOVED******REMOVED***makeNumericRangeMessage(numericRange)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Exceeds maximum value",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value exceeds the maximum allowed value."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .lessThanNumericMinimum:
***REMOVED******REMOVED******REMOVED***if let numericRange {
***REMOVED******REMOVED******REMOVED******REMOVED***makeNumericRangeMessage(numericRange)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Less than minimum value",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be within the allowed range."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .notInCodedValueDomain:
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Value must be within domain",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must exist in the domain."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .fieldIsRequired:
***REMOVED******REMOVED******REMOVED***Text.required
***REMOVED******REMOVED***case .incorrectValueType:
***REMOVED******REMOVED******REMOVED***if element.fieldType?.isFloatingPoint ?? false {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be a number",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be convertible to a number."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else if element.fieldType?.isNumeric ?? false {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be a whole number",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be convertible to a whole number."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be of correct type",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be of the correct type."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Unknown validation error",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field has an unknown validation error."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value which indicates whether or not the character indicator is showing in the footer.
***REMOVED***var isShowingCharacterIndicator: Bool {
***REMOVED******REMOVED***model.focusedElement == element
***REMOVED******REMOVED***&& !(element.fieldType?.isNumeric ?? false)
***REMOVED******REMOVED***&& (element.input is TextAreaFormInput || element.input is TextBoxFormInput)
***REMOVED******REMOVED***&& (element.description.isEmpty || primaryError != nil)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value which indicates whether or not an error is showing in the footer.
***REMOVED***var isShowingError: Bool {
***REMOVED******REMOVED***(element.isEditable || element.hasValueExpression)
***REMOVED******REMOVED***&& primaryError != nil
***REMOVED******REMOVED***&& (model.previouslyFocusedElements.contains(element) || validationErrorVisibility == .visible || element.hasValueExpression)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The allowable number of characters in the input.
***REMOVED***var lengthRange: ClosedRange<Int>? {
***REMOVED******REMOVED***if let input = element.input as? TextAreaFormInput {
***REMOVED******REMOVED******REMOVED***return input.minLength...input.maxLength
***REMOVED*** else if element.fieldType == .text {
***REMOVED******REMOVED******REMOVED***if let input = element.input as? TextBoxFormInput {
***REMOVED******REMOVED******REMOVED******REMOVED***return input.minLength...input.maxLength
***REMOVED******REMOVED*** else if let input = element.input as? BarcodeScannerFormInput {
***REMOVED******REMOVED******REMOVED******REMOVED***return input.minLength...input.maxLength
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The allowable numeric range the input.
***REMOVED***var numericRange: (min: String, max: String)? {
***REMOVED******REMOVED***if let rangeDomain = element.domain as? RangeDomain, let minMax = rangeDomain.displayableMinAndMax {
***REMOVED******REMOVED******REMOVED***return minMax
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The error to display for the input. If the element is not focused and has a required error this will be
***REMOVED******REMOVED***/ the primary error. Otherwise the primary error is the first error in the element's set of errors.
***REMOVED***var primaryError: ArcGIS.FeatureFormError? {
***REMOVED******REMOVED***let elementErrors = element.validationErrors as? [ArcGIS.FeatureFormError]
***REMOVED******REMOVED***if let requiredError = elementErrors?.first(where: {
***REMOVED******REMOVED******REMOVED***switch $0 {
***REMOVED******REMOVED******REMOVED***case .fieldIsRequired(_):
***REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED***), model.focusedElement != element {
***REMOVED******REMOVED******REMOVED***return requiredError
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return elementErrors?.first(where: {
***REMOVED******REMOVED******REMOVED******REMOVED***switch $0 {
***REMOVED******REMOVED******REMOVED******REMOVED***case .fieldIsRequired(_):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's exact number of allowed characters.
***REMOVED******REMOVED***/ - Note: This is intended to be used in instances where the character minimum and maximum are
***REMOVED******REMOVED***/ identical, such as an ID field.
***REMOVED***func makeExactLengthMessage(_ lengthRange: ClosedRange<Int>) -> Text {
***REMOVED******REMOVED***if element.hasValueExpression {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Value must be ^[\(lengthRange.lowerBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's computed value must be an exact number of characters."
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Enter ^[\(lengthRange.lowerBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating the user should enter a field's exact number of characters."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's value must be within the allowed length range.
***REMOVED***func makeLengthRangeMessage(_ lengthRange: ClosedRange<Int>) -> Text {
***REMOVED******REMOVED***if element.hasValueExpression {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Value must be \(lengthRange.lowerBound) to ^[\(lengthRange.upperBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's computed value must be within the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** allowed length range. The first and second parameter
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** hold the minimum and maximum length respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Enter \(lengthRange.lowerBound) to ^[\(lengthRange.upperBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's value must be within the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** allowed length range. The first and second parameter
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** hold the minimum and maximum length respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's maximum number of allowed characters.
***REMOVED***func makeMaximumLengthMessage(_ lengthRange: ClosedRange<Int>) -> Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Maximum ^[\(lengthRange.upperBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's maximum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's value must be within the allowed numeric range.
***REMOVED***func makeNumericRangeMessage(_ numericRange: (min: String, max: String)) -> Text {
***REMOVED******REMOVED***if element.hasValueExpression {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Value must be from \(numericRange.min) to \(numericRange.max)",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's computed value must be within the allowed range.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The first and second parameter hold the minimum and maximum values respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Enter value from \(numericRange.min) to \(numericRange.max)",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's value must be within the allowed range.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The first and second parameter hold the minimum and maximum values respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

private extension RangeDomain {
***REMOVED******REMOVED***/ String representations of the minimum and maximum value of the range domain.
***REMOVED***var displayableMinAndMax: (min: String, max: String)? {
***REMOVED******REMOVED***if let min = minValue as? Double, let max = maxValue as? Double {
***REMOVED******REMOVED******REMOVED***return (min.formatted(.number.precision(.fractionLength(1...))), max.formatted(.number.precision(.fractionLength(1...))))
***REMOVED*** else if let min = minValue as? Int, let max = maxValue as? Int {
***REMOVED******REMOVED******REMOVED***return (min.formatted(), max.formatted())
***REMOVED*** else if let min = minValue as? Int32, let max = maxValue as? Int32 {
***REMOVED******REMOVED******REMOVED***return (min.formatted(), max.formatted())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
