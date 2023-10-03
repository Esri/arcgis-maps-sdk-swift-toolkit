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
import Combine

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
***REMOVED******REMOVED***/ The input's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the view.
***REMOVED***private let input: TextBoxFormInput
***REMOVED***
***REMOVED***@StateObject var inputModel: FormInputModel
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for single line text input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form containing the input.
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED******REMOVED***/   - input: The input configuration of the view.
***REMOVED***init(featureForm: FeatureForm?, element: FieldFormElement, input: TextBoxFormInput) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = input
***REMOVED******REMOVED***
***REMOVED******REMOVED***_inputModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: FormInputModel(fieldFormElement: element)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***InputHeader(label: element.label, isRequired: inputModel.isRequired)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED******REMOVED*** Secondary foreground color is used across input views for consistency.
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***TextField(element.label, text: $text, prompt: Text(element.hint).foregroundColor(.secondary))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Text Field")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!inputModel.isEditable)
***REMOVED******REMOVED******REMOVED******REMOVED***if !text.isEmpty && inputModel.isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { text.removeAll() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.formTextInputStyle()
***REMOVED******REMOVED******REMOVED***TextInputFooter(
***REMOVED******REMOVED******REMOVED******REMOVED***currentLength: text.count,
***REMOVED******REMOVED******REMOVED******REMOVED***isFocused: isFocused,
***REMOVED******REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED******REMOVED***input: input,
***REMOVED******REMOVED******REMOVED******REMOVED***isRequired: inputModel.isRequired
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***text = element.value
***REMOVED***
***REMOVED******REMOVED***.onChange(of: isFocused) { newFocus in
***REMOVED******REMOVED******REMOVED***if newFocus {
***REMOVED******REMOVED******REMOVED******REMOVED***model.focusedFieldName = element.fieldName
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: text) { newValue in
***REMOVED******REMOVED******REMOVED***guard newValue != inputModel.value else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***

***REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(newValue, forKey: element.fieldName)
***REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED***
***REMOVED******REMOVED***.onChange(of: inputModel.value) { newValue in
***REMOVED******REMOVED******REMOVED***text = newValue
***REMOVED***
***REMOVED***
***REMOVED***
