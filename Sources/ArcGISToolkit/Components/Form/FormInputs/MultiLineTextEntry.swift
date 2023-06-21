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
***REMOVED******REMOVED***/ The current text value.
***REMOVED***@State private var text: String
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the text editor is active.
***REMOVED***@FocusState var isActive: Bool
***REMOVED***
***REMOVED******REMOVED***/ A `TextAreaFeatureFormInput` which acts as a configuration.
***REMOVED***let input: TextAreaFeatureFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for text entry spanning multiple lines.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - text: The current text value.
***REMOVED******REMOVED***/   - input: A `TextAreaFeatureFormInput` which acts as a configuration.
***REMOVED***init(text: String, input: TextAreaFeatureFormInput) {
***REMOVED******REMOVED***self.text = text
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading, spacing: 2) {
***REMOVED******REMOVED******REMOVED***TextEditor(text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(minHeight: 100, maxHeight: 200)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(2)
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 5)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.secondary.opacity(0.5), lineWidth: 0.5)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.focused($isActive)
***REMOVED******REMOVED******REMOVED***if isActive {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("\(text.count) / \(input.maxLength)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.black)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
