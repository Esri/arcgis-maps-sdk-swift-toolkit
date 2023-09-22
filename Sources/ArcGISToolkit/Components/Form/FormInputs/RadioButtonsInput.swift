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

struct RadioButtonsInput: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The set of options in the input.
***REMOVED***@State private var codedValues = [CodedValue]()
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the date selection was cleared when a value is required.
***REMOVED***@State private var requiredValueMissing = false
***REMOVED***
***REMOVED******REMOVED***/ The selected option.
***REMOVED***@State private var selectedValue: CodedValue?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the current value doesn't exist as an option in the domain.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ In this scenario a ``ComboBoxInput`` should be used instead.
***REMOVED***@State private var fallbackToComboBox = false
***REMOVED***
***REMOVED******REMOVED***/ The field's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The feature form containing the input.
***REMOVED***private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: RadioButtonsFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a date (and time if applicable) input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form containing the input.
***REMOVED******REMOVED***/   - element: The field's parent element.
***REMOVED******REMOVED***/   - input: The input configuration of the field.
***REMOVED***init(featureForm: FeatureForm?, element: FieldFormElement, input: RadioButtonsFormInput) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if fallbackToComboBox {
***REMOVED******REMOVED******REMOVED***ComboBoxInput(
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm: featureForm,
***REMOVED******REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED******REMOVED***noValueLabel: input.noValueLabel,
***REMOVED******REMOVED******REMOVED******REMOVED***noValueOption: input.noValueOption
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***InputHeader(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: .zero) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(codedValues, id: \.self) { codedValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedValue = codedValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(codedValue.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if codedValue == selectedValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(10)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if codedValue != codedValues.last {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.background(RoundedRectangle(cornerRadius: 10).fill(Color(uiColor: .tertiarySystemFill)))
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***InputFooter(element: element, requiredValueMissing: requiredValueMissing)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***codedValues = featureForm!.codedValues(fieldName: element.fieldName)
***REMOVED******REMOVED******REMOVED******REMOVED***if let selectedValue = codedValues.first(where: { $0.name == element.value ***REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.selectedValue = selectedValue
***REMOVED******REMOVED******REMOVED*** else if !element.value.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fallbackToComboBox = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: selectedValue) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***guard codedValues.first(where: { $0.name == element.value ***REMOVED***) != newValue else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***requiredValueMissing = element.isRequired && newValue == nil
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(newValue?.code ?? "", forKey: element.fieldName)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension RadioButtonsInput {
***REMOVED******REMOVED***/ The placeholder value to display.
***REMOVED***var placeholderValue: String {
***REMOVED******REMOVED***if input.noValueOption == .show && !input.noValueLabel.isEmpty {
***REMOVED******REMOVED******REMOVED***return input.noValueLabel
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .noValue
***REMOVED***
***REMOVED***
***REMOVED***
