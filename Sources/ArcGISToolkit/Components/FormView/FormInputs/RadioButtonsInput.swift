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

***REMOVED***/ A view for numerical value input.
***REMOVED***/
***REMOVED***/ This is the preferable input type for short lists of coded value domains.
struct RadioButtonsInput: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The model for the ancestral form view.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ The model for the input.
***REMOVED***@StateObject var inputModel: FormInputModel
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
***REMOVED******REMOVED***/ A Boolean value indicating whether a `ComboBoxInput`` should be used instead. This will be `true` if
***REMOVED******REMOVED***/ the current value doesn't exist as an option in the domain
***REMOVED***@State private var fallbackToComboBox = false
***REMOVED***
***REMOVED******REMOVED***/ The field's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: RadioButtonsFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a date (and time if applicable) input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The field's parent element.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***precondition(
***REMOVED******REMOVED******REMOVED***element.input is RadioButtonsFormInput,
***REMOVED******REMOVED******REMOVED***"\(Self.self).\(#function) element's input must be \(RadioButtonsFormInput.self)."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = element.input as! RadioButtonsFormInput
***REMOVED******REMOVED***
***REMOVED******REMOVED***_inputModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: FormInputModel(fieldFormElement: element)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if fallbackToComboBox {
***REMOVED******REMOVED******REMOVED***ComboBoxInput(
***REMOVED******REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED******REMOVED***noValueLabel: input.noValueLabel,
***REMOVED******REMOVED******REMOVED******REMOVED***noValueOption: input.noValueOption
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***InputHeader(label: element.label, isRequired: inputModel.isRequired)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: .zero) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if input.noValueOption == .show {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeRadioButtonRow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***placeholderValue,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedValue == nil,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***!codedValues.isEmpty,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***useNoValueStyle: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedValue = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(codedValues, id: \.self) { codedValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeRadioButtonRow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***codedValue.name,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***codedValue == selectedValue,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***codedValue != codedValues.last
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedValue = codedValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!inputModel.isEditable)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 10)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(Color(uiColor: .tertiarySystemFill))
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***InputFooter(element: element, requiredValueMissing: requiredValueMissing)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***codedValues = model.featureForm!.codedValues(fieldName: element.fieldName)
***REMOVED******REMOVED******REMOVED******REMOVED***if let selectedValue = codedValues.first(where: { $0.name == element.formattedValue ***REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.selectedValue = selectedValue
***REMOVED******REMOVED******REMOVED*** else if !element.formattedValue.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fallbackToComboBox = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: selectedValue) { selectedValue in
***REMOVED******REMOVED******REMOVED******REMOVED***requiredValueMissing = inputModel.isRequired && selectedValue == nil
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try element.updateValue(selectedValue?.code)
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: inputModel.formattedValue) { formattedValue in
***REMOVED******REMOVED******REMOVED******REMOVED***selectedValue = codedValues.first { $0.name == formattedValue ***REMOVED***
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
***REMOVED******REMOVED***/ Makes a radio button row.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - label: The label for the radio button.
***REMOVED******REMOVED***/   - selected: A Boolean value indicating whether the button is selected.
***REMOVED******REMOVED***/   - addDivider: A Boolean value indicating whether a divider should be included under the row.
***REMOVED******REMOVED***/   - useNoValueStyle: A Boolean value indicating whether the button represents a no value option.
***REMOVED******REMOVED***/   - action: The action to perform when the user triggers the button.
***REMOVED***@ViewBuilder func makeRadioButtonRow(
***REMOVED******REMOVED***_ label: String,
***REMOVED******REMOVED***_ selected: Bool,
***REMOVED******REMOVED***_ addDivider: Bool,
***REMOVED******REMOVED***useNoValueStyle: Bool = false,
***REMOVED******REMOVED***_ action: @escaping () -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***action()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if useNoValueStyle {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(label)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.italic()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(label)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***if selected {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) \(label) Checkmark")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(10)
***REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) \(label)")
***REMOVED******REMOVED***if addDivider {
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.leading, 10)
***REMOVED***
***REMOVED***
***REMOVED***
