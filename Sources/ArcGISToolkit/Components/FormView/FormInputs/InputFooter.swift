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
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Footer")
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if isFocused, element.fieldType == .text, element.description.isEmpty || firstError != nil {
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
***REMOVED******REMOVED***guard let error = firstError else { return nil ***REMOVED***
***REMOVED******REMOVED***return switch error {
***REMOVED******REMOVED***case .featureFormNullNotAllowedError:
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Value must not be empty",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "Text indicating a field's value must not be empty."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .featureFormExceedsMaximumDateTimeError:
***REMOVED******REMOVED******REMOVED***Text("Unhandled Error")
***REMOVED******REMOVED***case .featureFormLessThanMinimumDateTimeError:
***REMOVED******REMOVED******REMOVED***Text("Unhandled Error")
***REMOVED******REMOVED***case .featureFormExceedsMaximumLengthError:
***REMOVED******REMOVED******REMOVED***Text("Unhandled Error")
***REMOVED******REMOVED***case .featureFormLessThanMinimumLengthError:
***REMOVED******REMOVED******REMOVED***Text("Unhandled Error")
***REMOVED******REMOVED***case .featureFormExceedsNumericMaximumError:
***REMOVED******REMOVED******REMOVED***Text("Unhandled Error")
***REMOVED******REMOVED***case .featureFormLessThanNumericMinimumError:
***REMOVED******REMOVED******REMOVED***Text("Unhandled Error")
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
***REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED***var firstError: ArcGIS.FeatureFormError? {
***REMOVED******REMOVED***model.validationErrors[element.fieldName]?.first as? ArcGIS.FeatureFormError
***REMOVED***
***REMOVED***
***REMOVED***var isFocused: Bool {
***REMOVED******REMOVED***model.focusedElement == element
***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED***/ The length validation scheme performed on the text input, determined by the minimum and
***REMOVED******REMOVED***/ maximum lengths.
***REMOVED***var lengthValidationScheme: LengthValidationScheme {
***REMOVED******REMOVED***if lengthRange?.lowerBound == 0 {
***REMOVED******REMOVED******REMOVED***return .max
***REMOVED*** else if lengthRange?.lowerBound == lengthRange?.upperBound {
***REMOVED******REMOVED******REMOVED***return .exact
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .minAndMax
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var numericRange: RangeDomain? {
***REMOVED******REMOVED***element.domain as? RangeDomain
***REMOVED***
***REMOVED***
***REMOVED***var isShowingError: Bool {
***REMOVED******REMOVED***element.isEditable && firstError != nil
***REMOVED***
***REMOVED***
