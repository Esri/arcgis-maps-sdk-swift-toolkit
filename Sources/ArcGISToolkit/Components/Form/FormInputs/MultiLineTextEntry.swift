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
***REMOVED***/
***REMOVED***/ Includes UI for easy keyboard dismissal upon completion.
struct MultiLineTextEntry: View {
***REMOVED***@State private var text: String
***REMOVED***
***REMOVED***@FocusState var isActive: Bool
***REMOVED***
***REMOVED***let config: TextAreaFeatureFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for text entry spanning multiple lines.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - value: The current value.
***REMOVED***init(value: String, input: TextAreaFeatureFormInput) {
***REMOVED******REMOVED***self.text = value
***REMOVED******REMOVED***self.config = input
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading, spacing: 2) {
***REMOVED******REMOVED******REMOVED***TextEditor(text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(minHeight: 100, maxHeight: 200)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(1.5)
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 5)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.secondary.opacity(0.5), lineWidth: 0.5)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.focused($isActive)
***REMOVED******REMOVED******REMOVED***if isActive {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("\(text.count) / \(config.maxLength)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.black)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
