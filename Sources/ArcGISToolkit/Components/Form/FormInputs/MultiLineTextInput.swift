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

***REMOVED***/ A view for text input spanning multiple lines.
struct MultiLineTextInput: View {
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
***REMOVED******REMOVED***/ A Boolean value indicating whether placeholder text is shown, thereby indicating the
***REMOVED******REMOVED***/ presence of a value.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Note: As of Swift 5.9, SwiftUI text editors do not have built-in placeholder functionality
***REMOVED******REMOVED***/ so it must be implemented manually.
***REMOVED***@State private var isPlaceholder = false
***REMOVED***
***REMOVED******REMOVED***/ The input's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the view.
***REMOVED***private let input: TextAreaFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for text input spanning multiple lines.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***precondition(
***REMOVED******REMOVED******REMOVED***element.input is TextAreaFormInput,
***REMOVED******REMOVED******REMOVED***"\(Self.self).\(#function) element's input must be \(TextAreaFormInput.self)."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.element =  element
***REMOVED******REMOVED***self.input = element.input as! TextAreaFormInput
***REMOVED******REMOVED***
***REMOVED******REMOVED***_inputModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: FormInputModel(fieldFormElement: element)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***InputHeader(label: element.label, isRequired: inputModel.isRequired)
***REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED***if inputModel.isEditable {
***REMOVED******REMOVED******REMOVED***textEditor
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Text(text.isEmpty ? "--" : text)
***REMOVED***
***REMOVED******REMOVED***TextInputFooter(
***REMOVED******REMOVED******REMOVED***text: isPlaceholder ? "" : text,
***REMOVED******REMOVED******REMOVED***isFocused: isFocused,
***REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED***input: input,
***REMOVED******REMOVED******REMOVED***fieldType: fieldType
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***let text = inputModel.formattedValue
***REMOVED******REMOVED******REMOVED***isPlaceholder = text.isEmpty
***REMOVED******REMOVED******REMOVED***self.text = isPlaceholder ? element.hint : text
***REMOVED***
***REMOVED******REMOVED***.onChange(of: text) { text in
***REMOVED******REMOVED******REMOVED***guard !isPlaceholder else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try element.updateValue(text)
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED***
***REMOVED******REMOVED***.onChange(of: inputModel.formattedValue) { formattedValue in
***REMOVED******REMOVED******REMOVED***let text = formattedValue
***REMOVED******REMOVED******REMOVED***isPlaceholder = text.isEmpty
***REMOVED******REMOVED******REMOVED***self.text = isPlaceholder ? element.hint : text
***REMOVED***
***REMOVED***
***REMOVED***

private extension MultiLineTextInput {
***REMOVED******REMOVED***/ The field type of the text input.
***REMOVED***var fieldType: FieldType {
***REMOVED******REMOVED***model.featureForm!.feature.table!.field(named: element.fieldName)!.type!
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The body of the text input when the element is editable.
***REMOVED***var textEditor: some View {
***REMOVED******REMOVED***HStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED***TextEditor(text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED***.scrollContentBackgroundHidden()
***REMOVED******REMOVED******REMOVED***if isFocused && !text.isEmpty && inputModel.isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { text.removeAll() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.background(.clear)
***REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED***.foregroundColor(isPlaceholder ? .secondary : .primary)
***REMOVED******REMOVED***.onChange(of: isFocused) { focused in
***REMOVED******REMOVED******REMOVED***if focused && isPlaceholder {
***REMOVED******REMOVED******REMOVED******REMOVED***isPlaceholder = false
***REMOVED******REMOVED******REMOVED******REMOVED***text = ""
***REMOVED******REMOVED*** else if !focused && text.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***isPlaceholder = true
***REMOVED******REMOVED******REMOVED******REMOVED***text = element.hint
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if focused {
***REMOVED******REMOVED******REMOVED******REMOVED***model.focusedFieldName = element.fieldName
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formInputStyle()
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
