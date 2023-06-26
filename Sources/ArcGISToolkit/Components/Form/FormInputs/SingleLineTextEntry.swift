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

import FormsPlugin
***REMOVED***

***REMOVED***/ A view for single line text entry.
struct SingleLineTextEntry: View {
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the field is focused.
***REMOVED***@FocusState private var isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ The current text value.
***REMOVED***@State private var text: String
***REMOVED***
***REMOVED******REMOVED***/ The form element that corresponds to this text field.
***REMOVED***private let element: FieldFeatureFormElement
***REMOVED***
***REMOVED******REMOVED***/ A `TextBoxFeatureFormInput` which acts as a configuration.
***REMOVED***private let input: TextBoxFeatureFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for single line text entry.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The form element that corresponds to this text field.
***REMOVED******REMOVED***/   - text: The current text value.
***REMOVED******REMOVED***/   - input: A `TextBoxFeatureFormInput` which acts as a configuration.
***REMOVED***init(element: FieldFeatureFormElement, text: String?, input: TextBoxFeatureFormInput) {
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.text = text ?? ""
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED*** `MultiLineTextEntry` uses secondary foreground color so it's applied here for consistency.
***REMOVED******REMOVED***TextField(element.label, text: $text, prompt: Text(element.hint).foregroundColor(.secondary))
***REMOVED******REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED******REMOVED***.formTextEntryBorder()
***REMOVED******REMOVED***TextEntryFooter(
***REMOVED******REMOVED******REMOVED***description: element.description,
***REMOVED******REMOVED******REMOVED***currentLength: text.count,
***REMOVED******REMOVED******REMOVED***isFocused: isFocused,
***REMOVED******REMOVED******REMOVED***isRequired: true,
***REMOVED******REMOVED******REMOVED***maxLength: input.maxLength,
***REMOVED******REMOVED******REMOVED***minLength: input.minLength
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
