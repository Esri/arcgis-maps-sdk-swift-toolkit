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
***REMOVED******REMOVED***/ A Boolean value indicating whether placeholder text is shown, thereby indicating the
***REMOVED******REMOVED***/ presence of a value.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Note: As of Swift 5.9, SwiftUI text editors do not have built-in placeholder functionality
***REMOVED******REMOVED***/ so it must be implemented manually.
***REMOVED***@State private var isPlaceholder: Bool
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
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let text, !text.isEmpty {
***REMOVED******REMOVED******REMOVED***self.text = text
***REMOVED******REMOVED******REMOVED***isPlaceholder = false
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self.text = element.hint
***REMOVED******REMOVED******REMOVED***isPlaceholder = true
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED******REMOVED***TextEditor(text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.scrollContentBackground(.hidden)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***TextEditor(text: $text)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.background(.clear)
***REMOVED******REMOVED***.focused($isFocused)
***REMOVED******REMOVED***.foregroundColor(isPlaceholder ? .secondary : .primary)
***REMOVED******REMOVED***.frame(minHeight: 100, maxHeight: 200)
***REMOVED******REMOVED***.onChange(of: isFocused) { focused in
***REMOVED******REMOVED******REMOVED***if focused && isPlaceholder {
***REMOVED******REMOVED******REMOVED******REMOVED***isPlaceholder = false
***REMOVED******REMOVED******REMOVED******REMOVED***text = ""
***REMOVED******REMOVED*** else if !focused && text.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***isPlaceholder = true
***REMOVED******REMOVED******REMOVED******REMOVED***text = element.hint
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formTextEntryBorder()
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***FormElementFooter(element: element)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***TextEntryProgress(current: text.count, max: input.maxLength)
***REMOVED***
***REMOVED***
***REMOVED***
