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
***REMOVED******REMOVED***/ The current text value.
***REMOVED***@State private var text: String
***REMOVED***
***REMOVED******REMOVED***/ The title of the item.
***REMOVED***let title: String
***REMOVED***
***REMOVED******REMOVED***/ The text to to be shown in the entry area if no value is present.
***REMOVED***let prompt: String
***REMOVED***
***REMOVED******REMOVED***/ A `TextBoxFeatureFormInput` which acts as a configuration.
***REMOVED***let input: TextBoxFeatureFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for single line text entry.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - title: The title of the item.
***REMOVED******REMOVED***/   - text: The current text value.
***REMOVED******REMOVED***/   - prompt: The text to to be shown in the entry area if no value is present.
***REMOVED******REMOVED***/   - input: A `TextBoxFeatureFormInput` which acts as a configuration.
***REMOVED***init(element: FieldFeatureFormElement, text: String?, input: TextBoxFeatureFormInput) {
***REMOVED******REMOVED***self.text = text ?? ""
***REMOVED******REMOVED***self.title = element.label
***REMOVED******REMOVED***self.prompt = element.hint
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***TextField(title, text: $text, prompt: Text(prompt))
***REMOVED******REMOVED******REMOVED***.formTextEntryBorder()
***REMOVED******REMOVED***TextEntryProgress(current: text.count, max: input.maxLength)
***REMOVED***
***REMOVED***
