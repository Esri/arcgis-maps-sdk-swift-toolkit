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
***REMOVED***var title: String
***REMOVED***
***REMOVED******REMOVED***/ The text to to be shown in the entry area if no value is present.
***REMOVED***var prompt: String
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
***REMOVED***init(title: String, text: String?, prompt: String, input: TextBoxFeatureFormInput) {
***REMOVED******REMOVED***self.text = text ?? ""
***REMOVED******REMOVED***self.title = title
***REMOVED******REMOVED***self.prompt = prompt
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***TextField(title, text: $text, prompt: Text(prompt))
***REMOVED******REMOVED******REMOVED***.padding(2)
***REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 5)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.secondary.opacity(0.5), lineWidth: 0.5)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
