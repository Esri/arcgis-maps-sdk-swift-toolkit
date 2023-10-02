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

***REMOVED***/ A view for single line text input.
struct SingleLineTextInput: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The feature form containing the input.
***REMOVED***private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The model for the ancestral form view.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the field is focused.
***REMOVED***@FocusState private var isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ The current text value.
***REMOVED***@State private var text = ""
***REMOVED***
***REMOVED******REMOVED***/ The field's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: TextBoxFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for single line text input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form containing the input.
***REMOVED******REMOVED***/   - element: The field's parent element.
***REMOVED******REMOVED***/   - input: The input configuration of the field.
***REMOVED***init(featureForm: FeatureForm?, element: FieldFormElement, input: TextBoxFormInput) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED*** Secondary foreground color is used across input views for consistency.
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***TextField(element.label, text: $text, prompt: Text(element.hint).foregroundColor(.secondary))
***REMOVED******REMOVED******REMOVED******REMOVED***.keyboardType(keyboardType)
***REMOVED******REMOVED******REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItemGroup(placement: .keyboard) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if UIDevice.current.userInterfaceIdiom == .phone, isFocused, isNumeric {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***positiveNegativeButton
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Text Field")
***REMOVED******REMOVED******REMOVED***if !text.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { text.removeAll() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formTextInputStyle()
***REMOVED******REMOVED***TextInputFooter(
***REMOVED******REMOVED******REMOVED***text: text,
***REMOVED******REMOVED******REMOVED***isFocused: isFocused,
***REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED***input: input,
***REMOVED******REMOVED******REMOVED***rangeDomain: rangeDomain,
***REMOVED******REMOVED******REMOVED***isNumeric: isNumeric,
***REMOVED******REMOVED******REMOVED***isDecimal: isDecimal
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***text = featureForm?.feature.attributes[element.fieldName] as? String ?? ""
***REMOVED***
***REMOVED******REMOVED***.onChange(of: isFocused) { newFocus in
***REMOVED******REMOVED******REMOVED***if newFocus {
***REMOVED******REMOVED******REMOVED******REMOVED***model.focusedFieldName = element.fieldName
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: text) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED*** Note: this will be replaced by `element.updateValue()`, which will
***REMOVED******REMOVED******REMOVED******REMOVED*** handle all the following logic internally.
***REMOVED******REMOVED******REMOVED***if isDecimal {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Note: this should handle other decimal types as well, if they exist (float?)
***REMOVED******REMOVED******REMOVED******REMOVED***let value = Double(newValue)
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(value, forKey: element.fieldName)
***REMOVED******REMOVED*** else if isNumeric {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Note: this should handle more than just Int32
***REMOVED******REMOVED******REMOVED******REMOVED***let value = Int32(newValue)
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(value, forKey: element.fieldName)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text field
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(newValue, forKey: element.fieldName)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension SingleLineTextInput {
***REMOVED******REMOVED***/ A Boolean value indicating whether the input is for a numeric data type.
***REMOVED***var isNumeric: Bool {
***REMOVED******REMOVED***if let field = featureForm?.feature.table?.field(named: element.fieldName)?.type {
***REMOVED******REMOVED******REMOVED***return field.isNumeric
***REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the field has a numeric data type with decimal precision.
***REMOVED***var isDecimal: Bool {
***REMOVED******REMOVED***if let field = featureForm?.feature.table?.field(named: element.fieldName)?.type {
***REMOVED******REMOVED******REMOVED***return field.isFloatingPoint
***REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The keyboard type to use depending on where the input is numeric and decimal.
***REMOVED***var keyboardType: UIKeyboardType {
***REMOVED******REMOVED***isNumeric ? (isDecimal ? .decimalPad : .numberPad) : .default
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The button that allows a user to switch the numeric value between positive and negative.
***REMOVED***var positiveNegativeButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***if text.first == "-" {
***REMOVED******REMOVED******REMOVED******REMOVED***text.removeFirst()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***text.insert("-", at: text.startIndex)
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "plus.forwardslash.minus")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The range of valid values for a numeric input field.
***REMOVED***var rangeDomain: RangeDomain? {
***REMOVED******REMOVED***if let field = featureForm?.feature.table?.field(named: element.fieldName) {
***REMOVED******REMOVED******REMOVED***return field.domain as? RangeDomain
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***

private extension FieldType {
***REMOVED******REMOVED***/ A Boolean value indicating whether the field has a numeric data type.
***REMOVED***var isNumeric: Bool {
***REMOVED******REMOVED***self == .float32 || self == .float64 || self == .int16 || self == .int32 || self == .int64
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the field has a floating point data type.
***REMOVED***var isFloatingPoint: Bool {
***REMOVED******REMOVED***self == .float32 || self == .float64
***REMOVED***
***REMOVED***
