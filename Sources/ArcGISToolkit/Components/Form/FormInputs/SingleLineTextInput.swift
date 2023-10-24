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
***REMOVED******REMOVED***/ The model for the ancestral form view.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ The model for the input.
***REMOVED***@StateObject var inputModel: FormInputModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the field is focused.
***REMOVED***@FocusState private var isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ The current text value.
***REMOVED***@State private var text = ""
***REMOVED***
***REMOVED******REMOVED***/ The input's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the view.
***REMOVED***private let input: TextBoxFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for single line text input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***precondition(
***REMOVED******REMOVED******REMOVED***element.input is TextBoxFormInput,
***REMOVED******REMOVED******REMOVED***"\(Self.self).\(#function) element's input must be \(TextBoxFormInput.self)."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = element.input as! TextBoxFormInput
***REMOVED******REMOVED***
***REMOVED******REMOVED***_inputModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: FormInputModel(fieldFormElement: element)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***InputHeader(element: element)
***REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED*** Secondary foreground color is used across input views for consistency.
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***TextField(element.label, text: $text, prompt: Text(element.hint).foregroundColor(.secondary))
***REMOVED******REMOVED******REMOVED******REMOVED***.keyboardType(keyboardType)
***REMOVED******REMOVED******REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!inputModel.isEditable)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItemGroup(placement: .keyboard) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if UIDevice.current.userInterfaceIdiom == .phone, isFocused, fieldType.isNumeric {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***positiveNegativeButton
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Text Field")
***REMOVED******REMOVED******REMOVED***if !text.isEmpty && inputModel.isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { text.removeAll() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formInputStyle()
***REMOVED******REMOVED***TextInputFooter(
***REMOVED******REMOVED******REMOVED***text: text,
***REMOVED******REMOVED******REMOVED***isFocused: isFocused,
***REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED***input: input,
***REMOVED******REMOVED******REMOVED***rangeDomain: rangeDomain,
***REMOVED******REMOVED******REMOVED***fieldType: fieldType
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onChange(of: isFocused) { isFocused in
***REMOVED******REMOVED******REMOVED***if isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element.id
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***text = inputModel.formattedValue
***REMOVED***
***REMOVED******REMOVED***.onChange(of: text) { text in
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try element.updateValue(text)
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED***
***REMOVED******REMOVED***.onChange(of: inputModel.formattedValue) { formattedValue in
***REMOVED******REMOVED******REMOVED***self.text = formattedValue
***REMOVED***
***REMOVED***
***REMOVED***

private extension SingleLineTextInput {
***REMOVED******REMOVED***/ The field type of the text input.
***REMOVED***var fieldType: FieldType {
***REMOVED******REMOVED***model.featureForm!.feature.table!.field(named: element.fieldName)!.type!
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The keyboard type to use depending on where the input is numeric and decimal.
***REMOVED***var keyboardType: UIKeyboardType {
***REMOVED******REMOVED***fieldType.isNumeric ? (fieldType.isFloatingPoint ? .decimalPad : .numberPad) : .default
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The button that allows a user to switch the numeric value between positive and negative.
***REMOVED***var positiveNegativeButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***if let value = Int(text) {
***REMOVED******REMOVED******REMOVED******REMOVED***text = String(value * -1)
***REMOVED******REMOVED*** else if let value = Float(text) {
***REMOVED******REMOVED******REMOVED******REMOVED***text = String(value * -1)
***REMOVED******REMOVED*** else if let value = Double(text) {
***REMOVED******REMOVED******REMOVED******REMOVED***text = String(value * -1)
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "plus.forwardslash.minus")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The range of valid values for a numeric input field.
***REMOVED***var rangeDomain: RangeDomain? {
***REMOVED******REMOVED***if let field = model.featureForm?.feature.table?.field(named: element.fieldName) {
***REMOVED******REMOVED******REMOVED***return field.domain as? RangeDomain
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
