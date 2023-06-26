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

***REMOVED***/ A view for text entry spanning multiple lines.
struct MultiLineTextEntry: View {
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the field is focused.
***REMOVED***@FocusState private var isFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ The current text value.
***REMOVED***@State private var text: String
***REMOVED***
***REMOVED******REMOVED***/ The form element that corresponds to this text field.
***REMOVED***let element: FieldFeatureFormElement
***REMOVED***
***REMOVED******REMOVED***/ A `TextAreaFeatureFormInput` which acts as a configuration.
***REMOVED***let input: TextAreaFeatureFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for text entry spanning multiple lines.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The form element that corresponds to this text field.
***REMOVED******REMOVED***/   - text: The current text value.
***REMOVED******REMOVED***/   - input: A `TextAreaFeatureFormInput` which acts as a configuration.
***REMOVED***init(element: FieldFeatureFormElement, text: String?, input: TextAreaFeatureFormInput) {
***REMOVED******REMOVED***self.element =  element
***REMOVED******REMOVED***self.text = text ?? ""
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED******REMOVED***TextEditor(text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.scrollContentBackground(.hidden)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***TextEditor(text: $text)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED***.background(.clear)
***REMOVED******REMOVED***.frame(minHeight: 100, maxHeight: 200)
***REMOVED******REMOVED***.formTextEntryBorder()
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***FormElementFooter(element: element)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***TextEntryProgress(current: text.count, max: input.maxLength)
***REMOVED***
***REMOVED***
***REMOVED***
