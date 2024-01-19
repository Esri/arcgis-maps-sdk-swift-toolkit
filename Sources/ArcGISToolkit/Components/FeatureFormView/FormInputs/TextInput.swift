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

***REMOVED***/ A view for text input.
struct TextInput: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED*** State properties for element events.
***REMOVED***
***REMOVED***@State private var isRequired: Bool = false
***REMOVED***@State private var isEditable: Bool = false
***REMOVED***@State private var formattedValue: String = ""
***REMOVED***
***REMOVED******REMOVED***/ An error encountered while casting and updating input values.
***REMOVED***@State private var inputError: FeatureFormError?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the field is focused.
***REMOVED***@FocusState private var isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ The current text value.
***REMOVED***@State private var text = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether placeholder text is shown, thereby indicating the
***REMOVED******REMOVED***/ presence of a value.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ If iOS 16.0 minimum APIs are not supported we use a TextField for single line entry and a
***REMOVED******REMOVED***/ TextEditor for multiline entry. TextEditors don't have placeholder support so instead we
***REMOVED******REMOVED***/ replace empty text with the configured placeholder message and adjust the font
***REMOVED******REMOVED***/ color.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Once iOS 16.0 is the minimum supported platform this property can be removed.
***REMOVED***@State private var isPlaceholder = false
***REMOVED***
***REMOVED******REMOVED***/ The input's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for text input spanning multiple lines.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***precondition(
***REMOVED******REMOVED******REMOVED***element.input is TextAreaFormInput || element.input is TextBoxFormInput,
***REMOVED******REMOVED******REMOVED***"\(Self.self).\(#function) element's input must be \(TextAreaFormInput.self) or \(TextBoxFormInput.self)."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.element = element
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***InputHeader(label: element.label, isRequired: isRequired)
***REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED***if isEditable {
***REMOVED******REMOVED******REMOVED***textField
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Text(text.isEmpty ? "--" : text)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal], 10)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.vertical], 5)
***REMOVED******REMOVED******REMOVED******REMOVED***.textSelection(.enabled)
***REMOVED***
***REMOVED******REMOVED***InputFooter(element: element, error: inputError)
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onChange(of: isFocused) { isFocused in
***REMOVED******REMOVED******REMOVED***if isFocused && isPlaceholder {
***REMOVED******REMOVED******REMOVED******REMOVED***isPlaceholder = false
***REMOVED******REMOVED******REMOVED******REMOVED***text = ""
***REMOVED******REMOVED*** else if !isFocused && text.isEmpty && !iOS16MinimumIsSupported {
***REMOVED******REMOVED******REMOVED******REMOVED***isPlaceholder = true
***REMOVED******REMOVED******REMOVED******REMOVED***text = element.hint
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED*** else if model.focusedElement == element {
***REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: model.focusedElement) { focusedElement in
***REMOVED******REMOVED******REMOVED******REMOVED*** Another form input took focus
***REMOVED******REMOVED******REMOVED***if focusedElement != element {
***REMOVED******REMOVED******REMOVED******REMOVED***isFocused  = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: text) { text in
***REMOVED******REMOVED******REMOVED***guard !isPlaceholder else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***inputError = nil
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try element.convertAndUpdateValue(text)
***REMOVED******REMOVED*** catch let error as FeatureFormError {
***REMOVED******REMOVED******REMOVED******REMOVED***inputError = error
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription, String(describing: error))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if element.isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChangeOfValue(of: element) { newValue, newFormattedValue in
***REMOVED******REMOVED******REMOVED***formattedValue = newFormattedValue
***REMOVED******REMOVED******REMOVED***updateText()
***REMOVED***
***REMOVED******REMOVED***.onChangeOfIsRequired(of: element) { newIsRequired in
***REMOVED******REMOVED******REMOVED***isRequired = newIsRequired
***REMOVED***
***REMOVED******REMOVED***.onChangeOfIsEditable(of: element) { newIsEditable in
***REMOVED******REMOVED******REMOVED***isEditable = newIsEditable
***REMOVED***
***REMOVED***
***REMOVED***

private extension TextInput {
***REMOVED******REMOVED***/ A Boolean value indicating whether iOS 16.0 minimum APIs are supported.
***REMOVED***var iOS16MinimumIsSupported: Bool {
***REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED***return true
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The body of the text input when the element is editable.
***REMOVED***var textField: some View {
***REMOVED******REMOVED***HStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***element.label,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***text: $text,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***prompt: Text(element.hint).foregroundColor(.secondary),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: isMultiline ? .vertical : .horizontal
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else if isMultiline {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextEditor(text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(isPlaceholder ? .secondary : .primary)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***element.label,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***text: $text,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***prompt: Text(element.hint).foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Text Input")
***REMOVED******REMOVED******REMOVED***.background(.clear)
***REMOVED******REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED******REMOVED***.keyboardType(keyboardType)
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItemGroup(placement: .keyboard) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if UIDevice.current.userInterfaceIdiom == .phone, isFocused, (element.fieldType?.isNumeric ?? false) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***positiveNegativeButton
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.scrollContentBackgroundHidden()
***REMOVED******REMOVED******REMOVED***if !text.isEmpty && isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED***ClearButton {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If the user wasn't already editing the field provide
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** instantaneous focus to enable validation.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = nil
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***text.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formInputStyle()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the input is multiline or not.
***REMOVED***var isMultiline: Bool {
***REMOVED******REMOVED***element.input is TextAreaFormInput
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The keyboard type to use depending on where the input is numeric and decimal.
***REMOVED***var keyboardType: UIKeyboardType {
***REMOVED******REMOVED***guard let fieldType = element.fieldType else { return .default ***REMOVED***
***REMOVED******REMOVED***return fieldType.isNumeric ? (fieldType.isFloatingPoint ? .decimalPad : .numberPad) : .default
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
***REMOVED******REMOVED***/ Updates ``text`` and ``placeholder`` values in response to
***REMOVED******REMOVED***/ a change in ``formattedValue``.
***REMOVED***private func updateText() {
***REMOVED******REMOVED***let text = formattedValue
***REMOVED******REMOVED***isPlaceholder = text.isEmpty && !iOS16MinimumIsSupported
***REMOVED******REMOVED***self.text = isPlaceholder ? element.hint : text
***REMOVED***
***REMOVED***

private extension FieldFormElement {
***REMOVED******REMOVED***/ Attempts to convert the value to a type suitable for the element's field type and then update
***REMOVED******REMOVED***/ the element with the converted value.
***REMOVED***func convertAndUpdateValue(_ value: String) throws {
***REMOVED******REMOVED***if fieldType == .text {
***REMOVED******REMOVED******REMOVED***try updateValue(value)
***REMOVED*** else if let fieldType {
***REMOVED******REMOVED******REMOVED***if fieldType.isNumeric && value.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***try updateValue(nil)
***REMOVED******REMOVED*** else if fieldType == .int16, let value = Int16(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***try updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .int32, let value = Int32(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***try updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .int64, let value = Int64(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***try updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .float32, let value = Float32(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***try updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .float64, let value = Float64(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***try updateValue(value)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***throw FeatureFormError.incorrectValueType(details: "")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ - Returns: A view with the scroll content background hidden.
***REMOVED***func scrollContentBackgroundHidden() -> some View {
***REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED******REMOVED***.scrollContentBackground(.hidden)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED***
