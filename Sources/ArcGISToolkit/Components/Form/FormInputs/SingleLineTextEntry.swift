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

***REMOVED***/ A view for single line text entry.
struct SingleLineTextEntry: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***private var featureForm: FeatureForm?

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
***REMOVED******REMOVED***/ Creates a view for single line text entry.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The field's parent element.
***REMOVED******REMOVED***/   - input: The input configuration of the field.
***REMOVED***init(featureForm: FeatureForm?, element: FieldFormElement, input: TextBoxFormInput) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ - Bug: Focus detection works as of Xcode 14.3.1 but is broken as of Xcode 15 Beta 2.
***REMOVED******REMOVED***/ [More info](https:***REMOVED***openradar.appspot.com/FB12432084)
***REMOVED***var body: some View {
***REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED*** Secondary foreground color is used across entry views for consistency.
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***TextField(element.label, text: $text, prompt: Text(element.hint ?? "").foregroundColor(.secondary))
***REMOVED******REMOVED******REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED******REMOVED***if isFocused && !text.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { text.removeAll() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formTextEntryStyle()
***REMOVED******REMOVED***TextEntryFooter(
***REMOVED******REMOVED******REMOVED***currentLength: text.count,
***REMOVED******REMOVED******REMOVED***isFocused: isFocused,
***REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED***input: input
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
***REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(newValue, forKey: element.fieldName)
***REMOVED***
***REMOVED***
***REMOVED***
