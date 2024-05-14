***REMOVED*** Copyright 2024 Esri
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

***REMOVED***/ A view for a read only field form element.
struct ReadOnlyInput: View {
***REMOVED******REMOVED***/ The formatted version of the element's current value.
***REMOVED***@State private var formattedValue = ""
***REMOVED***
***REMOVED******REMOVED***/ The element the input belongs to.
***REMOVED***let element: FieldFormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if element.isMultiline {
***REMOVED******REMOVED******REMOVED******REMOVED***textReader
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***ScrollView(.horizontal) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***textReader
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***formattedValue = element.formattedValue
***REMOVED***
***REMOVED******REMOVED***.onValueChange(of: element) { _, newFormattedValue in
***REMOVED******REMOVED******REMOVED***formattedValue = newFormattedValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The body of the text input when the element is non-editable.
***REMOVED***var textReader: some View {
***REMOVED******REMOVED***Text(formattedValue.isEmpty ? "--" : formattedValue)
***REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Read Only Input")
***REMOVED******REMOVED******REMOVED***.fixedSize(horizontal: false, vertical: true)
***REMOVED******REMOVED******REMOVED***.lineLimit(element.isMultiline ? nil : 1)
***REMOVED******REMOVED******REMOVED***.padding(.horizontal, 10)
***REMOVED******REMOVED******REMOVED***.padding(.vertical, 5)
***REMOVED******REMOVED******REMOVED***.textSelection(.enabled)
***REMOVED***
***REMOVED***
