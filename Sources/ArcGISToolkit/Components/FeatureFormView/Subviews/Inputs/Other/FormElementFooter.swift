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

***REMOVED***/ A footer for elements in a feature form.
struct FormElementFooter: View {
***REMOVED***@Environment(\.formElementPadding) var formElementPadding
***REMOVED***
***REMOVED******REMOVED***/ The form element the footer belongs to.
***REMOVED***let element: FormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***footerTextForElement
***REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED***.padding(.vertical, formElementPadding / 2)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***var footerTextForElement: some View {
***REMOVED******REMOVED***switch element {
***REMOVED******REMOVED***case let element as FieldFormElement:
***REMOVED******REMOVED******REMOVED***FieldFormElementFooter(element: element)
***REMOVED******REMOVED***case let element as UtilityAssociationsFormElement:
***REMOVED******REMOVED******REMOVED***UtilityAssociationsFormElementFooter(element: element)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***

extension FormElementFooter {
***REMOVED***struct FieldFormElementFooter: View {
***REMOVED******REMOVED******REMOVED***/ The view model for the form.
***REMOVED******REMOVED***@Environment(InternalFeatureFormViewModel.self) private var internalFeatureFormViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The validation error visibility configuration of a form.
***REMOVED******REMOVED***@Environment(\._validationErrorVisibility) private var validationErrorVisibility
***REMOVED******REMOVED***
***REMOVED******REMOVED***let element: FieldFormElement
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ An ID regenerated each time the element's value changes.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ Allows the footer to be recomputed to reflect changes in validation errors or input length.
***REMOVED******REMOVED***@State private var id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack(alignment: .top) {
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isShowingError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***errorMessage
***REMOVED******REMOVED******REMOVED******REMOVED*** else if !element.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED******REMOVED*** else if internalFeatureFormViewModel.focusedElement == element {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if element.fieldType == .text, let lengthRange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if lengthRange.lowerBound == lengthRange.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeExactLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else if lengthRange.lowerBound > .zero {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeLengthRangeMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeMaximumLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else if element.fieldType?.isNumeric ?? false, let numericRange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeNumericRangeMessage(numericRange)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Footer")
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***if isShowingCharacterIndicator {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.formattedValue.count, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Character Indicator")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.foregroundStyle(isShowingError ? .red : .secondary)
***REMOVED******REMOVED******REMOVED***.id(id)
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***for await _ in element.$value {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id = UUID()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Localized error text to be shown to a user depending on the type of error information available.
***REMOVED******REMOVED***var errorMessage: Text? {
***REMOVED******REMOVED******REMOVED***guard let error = primaryError else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***return switch error {
***REMOVED******REMOVED******REMOVED***case .nullNotAllowed:
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must not be empty",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must not be empty."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***case .exceedsMaximumDateTime:
***REMOVED******REMOVED******REMOVED******REMOVED***if let input = element.input as? DateTimePickerFormInput, let max = input.max {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Date must be on or before \(max, format: input.includesTime ? .dateTime : .dateTime.month().day().year())",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be on or before the maximum date specified in the variable."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Date exceeds maximum",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must not exceed a maximum date."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .lessThanMinimumDateTime:
***REMOVED******REMOVED******REMOVED******REMOVED***if let input = element.input as? DateTimePickerFormInput, let min = input.min {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Date must be on or after \(min, format: input.includesTime ? .dateTime : .dateTime.month().day().year())",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be on or after the minimum date specified in the variable."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Date less than minimum",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must meet a minimum date."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .exceedsMaximumLength:
***REMOVED******REMOVED******REMOVED******REMOVED***if let lengthRange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if lengthRange.lowerBound == lengthRange.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeExactLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeMaximumLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Maximum character length exceeded",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's maximum number of allowed characters is exceeded."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .lessThanMinimumLength:
***REMOVED******REMOVED******REMOVED******REMOVED***if let lengthRange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if lengthRange.lowerBound == lengthRange.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeExactLengthMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeLengthRangeMessage(lengthRange)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Minimum character length not met",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's minimum number of allowed characters is not met."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .exceedsNumericMaximum:
***REMOVED******REMOVED******REMOVED******REMOVED***if let numericRange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeNumericRangeMessage(numericRange)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Exceeds maximum value",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value exceeds the maximum allowed value."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .lessThanNumericMinimum:
***REMOVED******REMOVED******REMOVED******REMOVED***if let numericRange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeNumericRangeMessage(numericRange)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Less than minimum value",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be within the allowed range."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .notInCodedValueDomain:
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be within domain",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must exist in the domain."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***case .fieldIsRequired:
***REMOVED******REMOVED******REMOVED******REMOVED***Text.required
***REMOVED******REMOVED******REMOVED***case .incorrectValueType:
***REMOVED******REMOVED******REMOVED******REMOVED***if element.fieldType?.isFloatingPoint ?? false {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be a number",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be convertible to a number."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else if element.fieldType?.isNumeric ?? false {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be a whole number",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be convertible to a whole number."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be of correct type",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be of the correct type."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Unknown validation error",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field has an unknown validation error."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value which indicates whether or not the character indicator is showing in the footer.
***REMOVED******REMOVED***var isShowingCharacterIndicator: Bool {
***REMOVED******REMOVED******REMOVED***internalFeatureFormViewModel.focusedElement == element
***REMOVED******REMOVED******REMOVED***&& !(element.fieldType?.isNumeric ?? false)
***REMOVED******REMOVED******REMOVED***&& (element.input is TextAreaFormInput || element.input is TextBoxFormInput)
***REMOVED******REMOVED******REMOVED***&& (element.description.isEmpty || primaryError != nil)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value which indicates whether or not an error is showing in the footer.
***REMOVED******REMOVED***var isShowingError: Bool {
***REMOVED******REMOVED******REMOVED***element.isEditable
***REMOVED******REMOVED******REMOVED***&& primaryError != nil
***REMOVED******REMOVED******REMOVED***&& (internalFeatureFormViewModel.previouslyFocusedElements.contains(element) || validationErrorVisibility == .visible)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The allowable number of characters in the input.
***REMOVED******REMOVED***var lengthRange: ClosedRange<Int>? {
***REMOVED******REMOVED******REMOVED***if let input = element.input as? TextAreaFormInput {
***REMOVED******REMOVED******REMOVED******REMOVED***return input.minLength...input.maxLength
***REMOVED******REMOVED*** else if element.fieldType == .text {
***REMOVED******REMOVED******REMOVED******REMOVED***if let input = element.input as? TextBoxFormInput {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return input.minLength...input.maxLength
***REMOVED******REMOVED******REMOVED*** else if let input = element.input as? BarcodeScannerFormInput {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return input.minLength...input.maxLength
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The allowable numeric range the input.
***REMOVED******REMOVED***var numericRange: (min: String, max: String)? {
***REMOVED******REMOVED******REMOVED***if let rangeDomain = element.domain as? RangeDomain, let minMax = rangeDomain.displayableNumericMinAndMax {
***REMOVED******REMOVED******REMOVED******REMOVED***return minMax
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The error to display for the input. If the element is not focused and has a required error this will be
***REMOVED******REMOVED******REMOVED***/ the primary error. Otherwise the primary error is the first error in the element's set of errors.
***REMOVED******REMOVED***var primaryError: ArcGIS.FeatureFormError? {
***REMOVED******REMOVED******REMOVED***let elementErrors = element.validationErrors as? [ArcGIS.FeatureFormError]
***REMOVED******REMOVED******REMOVED***if let requiredError = elementErrors?.first(where: {
***REMOVED******REMOVED******REMOVED******REMOVED***switch $0 {
***REMOVED******REMOVED******REMOVED******REMOVED***case .fieldIsRequired(_):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***), internalFeatureFormViewModel.focusedElement != element {
***REMOVED******REMOVED******REMOVED******REMOVED***return requiredError
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return elementErrors?.first(where: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch $0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .fieldIsRequired(_):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Text indicating a field's exact number of allowed characters.
***REMOVED******REMOVED******REMOVED***/ - Note: This is intended to be used in instances where the character minimum and maximum are
***REMOVED******REMOVED******REMOVED***/ identical, such as an ID field.
***REMOVED******REMOVED***func makeExactLengthMessage(_ lengthRange: ClosedRange<Int>) -> Text {
***REMOVED******REMOVED******REMOVED***if element.hasValueExpression {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be ^[\(lengthRange.lowerBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's computed value must be an exact number of characters."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Enter ^[\(lengthRange.lowerBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating the user should enter a field's exact number of characters."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Text indicating a field's value must be within the allowed length range.
***REMOVED******REMOVED***func makeLengthRangeMessage(_ lengthRange: ClosedRange<Int>) -> Text {
***REMOVED******REMOVED******REMOVED***if element.hasValueExpression {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be \(lengthRange.lowerBound) to ^[\(lengthRange.upperBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's computed value must be within the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** allowed length range. The first and second parameter
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** hold the minimum and maximum length respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Enter \(lengthRange.lowerBound) to ^[\(lengthRange.upperBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's value must be within the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** allowed length range. The first and second parameter
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** hold the minimum and maximum length respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Text indicating a field's maximum number of allowed characters.
***REMOVED******REMOVED***func makeMaximumLengthMessage(_ lengthRange: ClosedRange<Int>) -> Text {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Maximum ^[\(lengthRange.upperBound) characters](inflect: true)",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's maximum number of allowed characters."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Text indicating a field's value must be within the allowed numeric range.
***REMOVED******REMOVED***func makeNumericRangeMessage(_ numericRange: (min: String, max: String)) -> Text {
***REMOVED******REMOVED******REMOVED***if element.hasValueExpression {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be from \(numericRange.min) to \(numericRange.max)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's computed value must be within the allowed range.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The first and second parameter hold the minimum and maximum values respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Enter value from \(numericRange.min) to \(numericRange.max)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's value must be within the allowed range.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The first and second parameter hold the minimum and maximum values respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct UtilityAssociationsFormElementFooter: View {
***REMOVED******REMOVED***let element: UtilityAssociationsFormElement
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***if !element.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension RangeDomain {
***REMOVED******REMOVED***/ String representations of the numeric minimum and maximum value of the range domain.
***REMOVED***var displayableNumericMinAndMax: (min: String, max: String)? {
***REMOVED******REMOVED***if let min = minValue as? Float32, let max = maxValue as? Float32 {
***REMOVED******REMOVED******REMOVED***return (min.formatted(.number.precision(.fractionLength(1...))), max.formatted(.number.precision(.fractionLength(1...))))
***REMOVED*** else if let min = minValue as? Float64, let max = maxValue as? Float64 {
***REMOVED******REMOVED******REMOVED***return (min.formatted(.number.precision(.fractionLength(1...))), max.formatted(.number.precision(.fractionLength(1...))))
***REMOVED*** else if let min = minValue as? Int16, let max = maxValue as? Int16 {
***REMOVED******REMOVED******REMOVED***return (min.formatted(), max.formatted())
***REMOVED*** else if let min = minValue as? Int32, let max = maxValue as? Int32 {
***REMOVED******REMOVED******REMOVED***return (min.formatted(), max.formatted())
***REMOVED*** else if let min = minValue as? Int64, let max = maxValue as? Int64 {
***REMOVED******REMOVED******REMOVED***return (min.formatted(), max.formatted())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
