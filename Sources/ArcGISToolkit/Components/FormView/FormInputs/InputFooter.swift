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
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ The form element the footer belongs to.
***REMOVED***let element: FieldFormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack(alignment: .top) {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if isShowingError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***errorMessage
***REMOVED******REMOVED******REMOVED*** else if !element.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED*** else if element.fieldType == .text {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if lengthRange?.lowerBound == lengthRange?.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***exactLengthMessage
***REMOVED******REMOVED******REMOVED******REMOVED*** else if lengthRange?.lowerBound ?? 0 > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lengthRangeMessage
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maximumLengthMessage
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Footer")
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if model.focusedElement == element, element.fieldType == .text, element.description.isEmpty || primaryError != nil {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.formattedValue.count, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Character Indicator")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***.foregroundColor(isShowingError ? .red : .secondary)
***REMOVED***
***REMOVED***

extension InputFooter {
***REMOVED***var errorMessage: Text? {
***REMOVED******REMOVED***guard let error = primaryError else { return nil ***REMOVED***
***REMOVED******REMOVED***return switch error {
***REMOVED******REMOVED***case .featureFormNullNotAllowedError:
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Value must not be empty",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must not be empty."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .featureFormExceedsMaximumDateTimeError:
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Date exceeds maximum",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must not exceed a maximum date."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .featureFormLessThanMinimumDateTimeError:
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Date does not meet minimum",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must meet a minimum date."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .featureFormExceedsMaximumLengthError:
***REMOVED******REMOVED******REMOVED***if lengthRange?.lowerBound == lengthRange?.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED***exactLengthMessage
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***maximumLengthMessage
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .featureFormLessThanMinimumLengthError:
***REMOVED******REMOVED******REMOVED***if lengthRange?.lowerBound == lengthRange?.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED***exactLengthMessage
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***minimumLengthMessage
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .featureFormExceedsNumericMaximumError, .featureFormLessThanNumericMinimumError:
***REMOVED******REMOVED******REMOVED***if let numericRange = element.domain as? RangeDomain, let minMax = numericRange.displayableMinAndMax {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Enter value from \(minMax.min) to \(minMax.max)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's value must be within the allowed range.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The first and second parameter hold the minimum and maximum values respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Value must be within allowed range",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must be within the allowed range."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .featureFormNotInCodedValueDomainError:
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Value must be within domain",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must exist in the domain."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .featureFormFieldIsRequiredError:
***REMOVED******REMOVED******REMOVED***Text.required
***REMOVED******REMOVED***case .featureFormIncorrectValueTypeError:
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
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's exact number of allowed characters.
***REMOVED******REMOVED***/ - Note: This is intended to be used in instances where the character minimum and maximum are
***REMOVED******REMOVED***/ identical, such as an ID field.
***REMOVED***var exactLengthMessage: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(lengthRange!.lowerBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating the user should enter a field's exact number of required characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines whether an error is showing in the footer.
***REMOVED***var isShowingError: Bool {
***REMOVED******REMOVED***element.isEditable && primaryError != nil && model.previouslyFocusedFields.contains(element)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The alloable range of number of characters in the input.
***REMOVED***var lengthRange: ClosedRange<Int>? {
***REMOVED******REMOVED***if let input = element.input as? TextAreaFormInput {
***REMOVED******REMOVED******REMOVED***return input.minLength...input.maxLength
***REMOVED*** else if let input = element.input as? TextBoxFormInput, element.fieldType == .text {
***REMOVED******REMOVED******REMOVED***return input.minLength...input.maxLength
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's value must be within the allowed length range.
***REMOVED***var lengthRangeMessage: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Enter \(lengthRange!.lowerBound) to \(lengthRange!.upperBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text indicating a field's value must be within the 
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** allowed length range. The first and second parameter
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** hold the minimum and maximum length respectively.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's maximum number of allowed characters.
***REMOVED***var maximumLengthMessage: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Maximum \(lengthRange!.upperBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's maximum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Text indicating a field's maximum number of allowed characters.
***REMOVED***var minimumLengthMessage: Text {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Minimum \(lengthRange!.lowerBound) characters",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's minimum number of allowed characters."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The error to display for the input. If the element is not focused and has a required error this will be
***REMOVED******REMOVED***/ the primary error. Otherwise the primary error is the first error in the element's set of errors.
***REMOVED***var primaryError: ArcGIS.FeatureFormError? {
***REMOVED******REMOVED***let elementErrors = model.validationErrors[element.fieldName] as? [ArcGIS.FeatureFormError]
***REMOVED******REMOVED***if let requiredError = elementErrors?.first(where: { $0 == .featureFormFieldIsRequiredError ***REMOVED***), model.focusedElement != element {
***REMOVED******REMOVED******REMOVED***return requiredError
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return elementErrors?.first(where: { $0 != .featureFormFieldIsRequiredError ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

private extension RangeDomain {
***REMOVED******REMOVED***/ String representations of the minimum and maximum value of the range domain.
***REMOVED***var displayableMinAndMax: (min: String, max: String)? {
***REMOVED******REMOVED***if let min = minValue as? Double, let max = maxValue as? Double {
***REMOVED******REMOVED******REMOVED***return (min.formatted(), max.formatted())
***REMOVED*** else if let min = minValue as? Int, let max = maxValue as? Int {
***REMOVED******REMOVED******REMOVED***return (min.formatted(), max.formatted())
***REMOVED*** else if let min = minValue as? Int32, let max = maxValue as? Int32 {
***REMOVED******REMOVED******REMOVED***return (min.formatted(), max.formatted())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
