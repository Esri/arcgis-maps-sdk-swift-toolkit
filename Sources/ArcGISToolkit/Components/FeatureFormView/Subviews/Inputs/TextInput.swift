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
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the field is focused.
***REMOVED***@FocusState private var isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ The formatted version of the element's current value.
***REMOVED***@State private var formattedValue = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the full screen text input is presented.
***REMOVED***@State private var fullScreenTextInputIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The current text value.
***REMOVED***@State private var text = ""
***REMOVED***
***REMOVED******REMOVED***/ The element the input belongs to.
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
***REMOVED******REMOVED***textWriter
***REMOVED******REMOVED******REMOVED***.onChange(of: isFocused) { isFocused in
***REMOVED******REMOVED******REMOVED******REMOVED***if isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED******REMOVED*** else if model.focusedElement == element {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: model.focusedElement) { focusedElement in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Another form input took focus
***REMOVED******REMOVED******REMOVED******REMOVED***if focusedElement != element {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused  = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: text) { text in
***REMOVED******REMOVED******REMOVED******REMOVED***element.convertAndUpdateValue(text)
***REMOVED******REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED***if element.isMultiline {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fullScreenTextInputIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onValueChange(of: element) { newValue, newFormattedValue in
***REMOVED******REMOVED******REMOVED******REMOVED***formattedValue = newFormattedValue
***REMOVED******REMOVED******REMOVED******REMOVED***text = formattedValue
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension TextInput {
***REMOVED******REMOVED***/ The body of the text input when the element is editable.
***REMOVED***var textWriter: some View {
***REMOVED******REMOVED***HStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED***element.label,
***REMOVED******REMOVED******REMOVED******REMOVED***text: $text,
***REMOVED******REMOVED******REMOVED******REMOVED***prompt: Text(element.hint).foregroundColor(.secondary),
***REMOVED******REMOVED******REMOVED******REMOVED***axis: element.isMultiline ? .vertical : .horizontal
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.disabled(element.isMultiline)
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $fullScreenTextInputIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***FullScreenTextInput(text: $text, element: element)
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(model)
#endif
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
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
***REMOVED******REMOVED******REMOVED***.scrollContentBackground(.hidden)
***REMOVED******REMOVED******REMOVED***if !text.isEmpty {
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

private extension TextInput {
***REMOVED******REMOVED***/ A view for displaying a multiline text input outside the body of the feature form view.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ By moving outside of the feature form view's scroll view we let the text field naturally manage
***REMOVED******REMOVED***/ keeping the input caret visible.
***REMOVED***struct FullScreenTextInput: View {
***REMOVED******REMOVED******REMOVED***/ The current text value.
***REMOVED******REMOVED***@Binding var text: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ An action that dismisses the current presentation.
***REMOVED******REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the text field is focused.
***REMOVED******REMOVED***@FocusState private var textFieldIsFocused: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The element the input belongs to.
***REMOVED******REMOVED***let element: FieldFormElement
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***InputHeader(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Done") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***LegacyTextView(text: $text)
***REMOVED******REMOVED******REMOVED***.focused($textFieldIsFocused, equals: true)
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***textFieldIsFocused = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***InputFooter(element: element)
***REMOVED***
***REMOVED***
***REMOVED***

struct LegacyTextView: UIViewRepresentable {
***REMOVED***@Binding var text: String
***REMOVED***
***REMOVED***func makeUIView(context: Context) -> UITextView {
***REMOVED******REMOVED***let uiTextView = UITextView()
***REMOVED******REMOVED***uiTextView.delegate = context.coordinator
***REMOVED******REMOVED***return uiTextView
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiView: UITextView, context: Context) {
***REMOVED******REMOVED***uiView.text = text
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(text: $text)
***REMOVED***
***REMOVED***
***REMOVED***class Coordinator: NSObject, UITextViewDelegate {
***REMOVED******REMOVED***
***REMOVED******REMOVED***var text: Binding<String>
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(text: Binding<String>) {
***REMOVED******REMOVED******REMOVED***self.text = text
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textViewDidEndEditing(_ textView: UITextView) {
***REMOVED******REMOVED******REMOVED***self.text.wrappedValue = textView.text
***REMOVED***
***REMOVED***
***REMOVED***

private extension FieldFormElement {
***REMOVED******REMOVED***/ Attempts to convert the value to a type suitable for the element's field type and then update
***REMOVED******REMOVED***/ the element with the converted value.
***REMOVED***func convertAndUpdateValue(_ value: String) {
***REMOVED******REMOVED***if fieldType == .text {
***REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED*** else if let fieldType {
***REMOVED******REMOVED******REMOVED***if fieldType.isNumeric && value.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(nil)
***REMOVED******REMOVED*** else if fieldType == .int16, let value = Int16(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .int32, let value = Int32(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .int64, let value = Int64(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .float32, let value = Float32(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else if fieldType == .float64, let value = Float64(value) {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***updateValue(value)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
