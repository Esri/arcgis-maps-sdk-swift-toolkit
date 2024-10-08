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
@available(visionOS, unavailable)
struct TextInput: View {
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the field is focused.
***REMOVED***@FocusState private var isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the full screen text input is presented.
***REMOVED***@State private var fullScreenTextInputIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the code scanner is presented.
***REMOVED***@State private var scannerIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The current text value.
***REMOVED***@State private var text = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the device camera is accessible for scanning.
***REMOVED***private let cameraIsDisabled: Bool = {
#if targetEnvironment(simulator)
***REMOVED******REMOVED***return true
#else
***REMOVED******REMOVED***return false
#endif
***REMOVED***()
***REMOVED***
***REMOVED******REMOVED***/ The element the input belongs to.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for text input spanning multiple lines.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***precondition(
***REMOVED******REMOVED******REMOVED***element.input is TextAreaFormInput
***REMOVED******REMOVED******REMOVED***|| element.input is TextBoxFormInput
***REMOVED******REMOVED******REMOVED***|| element.input is BarcodeScannerFormInput,
***REMOVED******REMOVED******REMOVED***"\(Self.self).\(#function) element's input must be \(TextAreaFormInput.self), \(TextBoxFormInput.self) or \(BarcodeScannerFormInput.self)."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.element = element
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***textWriter
***REMOVED******REMOVED******REMOVED***.onChange(isFocused) { isFocused in
***REMOVED******REMOVED******REMOVED******REMOVED***if isFocused {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED******REMOVED*** else if model.focusedElement == element {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(model.focusedElement) { focusedElement in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Another form input took focus
***REMOVED******REMOVED******REMOVED******REMOVED***if focusedElement != element {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused  = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(text) { text in
***REMOVED******REMOVED******REMOVED******REMOVED***element.convertAndUpdateValue(text)
***REMOVED******REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED***if element.isMultiline {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fullScreenTextInputIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $scannerIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***CodeScanner(code: $text, isPresented: $scannerIsPresented)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onValueChange(of: element, when: !element.isMultiline || !fullScreenTextInputIsPresented) { _, newFormattedValue in
***REMOVED******REMOVED******REMOVED******REMOVED***text = newFormattedValue
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
private extension TextInput {
***REMOVED******REMOVED***/ The body of the text input when the element is editable.
***REMOVED***var textWriter: some View {
***REMOVED******REMOVED***HStack(alignment: .firstTextBaseline) {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if element.isMultiline {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Text Input Preview")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fixedSize(horizontal: false, vertical: true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(10)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.truncationMode(.tail)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sheet(isPresented: $fullScreenTextInputIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FullScreenTextInput(text: $text, element: element, model: model)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(model)
#endif
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***element.label,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***text: $text,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***prompt: Text(element.input is BarcodeScannerFormInput ? String.noValue : element.hint).foregroundColor(.secondary),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: .horizontal
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Text Input")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.keyboardType(keyboardType)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
#if os(iOS)
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItemGroup(placement: .keyboard) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if UIDevice.current.userInterfaceIdiom == .phone, isFocused, (element.fieldType?.isNumeric ?? false) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***positiveNegativeButton
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
#endif
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
***REMOVED******REMOVED******REMOVED***if element.input is BarcodeScannerFormInput {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scannerIsPresented = true
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "barcode.viewfinder")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(cameraIsDisabled)
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Scan Button")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formInputStyle()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The keyboard type to use depending on where the input is numeric and decimal.
***REMOVED***var keyboardType: UIKeyboardType {
***REMOVED******REMOVED***guard let fieldType = element.fieldType else { return .default ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return if fieldType.isNumeric {
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED*** The 'positiveNegativeButton' doesn't show on visionOS
***REMOVED******REMOVED******REMOVED******REMOVED*** so we need to show this keyboard so the user can type
***REMOVED******REMOVED******REMOVED******REMOVED*** a negative number.
***REMOVED******REMOVED******REMOVED***.numbersAndPunctuation
#else
***REMOVED******REMOVED******REMOVED***if fieldType.isFloatingPoint { .decimalPad ***REMOVED*** else { .numberPad ***REMOVED***
#endif
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***.default
***REMOVED***
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

@available(visionOS, unavailable)
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
***REMOVED******REMOVED******REMOVED***/ The view model for the form.
***REMOVED******REMOVED***let model: FormViewModel
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
***REMOVED******REMOVED******REMOVED***RepresentedUITextView(initialText: text) { text in
***REMOVED******REMOVED******REMOVED******REMOVED***element.convertAndUpdateValue(text)
***REMOVED******REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED******REMOVED*** onTextViewDidEndEditing: { text in
***REMOVED******REMOVED******REMOVED******REMOVED***self.text = text
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.focused($textFieldIsFocused, equals: true)
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***textFieldIsFocused = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***InputFooter(element: element)
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ Wraps `onValueChange(of:action:)` with an additional boolean property that when false will
***REMOVED******REMOVED***/ not monitor value changes.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The form element to watch for changes on.
***REMOVED******REMOVED***/   - when: The boolean value which disables monitoring. When `true` changes will be monitored.
***REMOVED******REMOVED***/   - action: The action which watches for changes.
***REMOVED******REMOVED***/ - Returns: The modified view.
***REMOVED***func onValueChange(of element: FieldFormElement, when: Bool, action: @escaping (_ newValue: Any?, _ newFormattedValue: String) -> Void) -> some View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***ConditionalChangeOfModifier(element: element, condition: when) { newValue, newFormattedValue in
***REMOVED******REMOVED******REMOVED******REMOVED***action(newValue, newFormattedValue)
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private struct ConditionalChangeOfModifier: ViewModifier {
***REMOVED***let element: FieldFormElement
***REMOVED***
***REMOVED***let condition: Bool
***REMOVED***
***REMOVED***let action: (_ newValue: Any?, _ newFormattedValue: String) -> Void
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***if condition {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***.onValueChange(of: element) { newValue, newFormattedValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(newValue, newFormattedValue)
***REMOVED******REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***content
***REMOVED***
***REMOVED***
***REMOVED***
