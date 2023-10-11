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

***REMOVED***/ A view shown at the top of a field element in a form.
struct InputHeader: View {
***REMOVED******REMOVED***/ The name of the form element.
***REMOVED***let label: String
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the a value for the input is required.
***REMOVED***let isRequired: Bool
***REMOVED***
***REMOVED******REMOVED***/ - Parameter element: The form element the header is for.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***self.label = element.label
***REMOVED******REMOVED***self.isRequired = element.isRequired
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - label: The name of the form element.
***REMOVED******REMOVED***/   - isRequired: A Boolean value indicating whether the a value for the input is required.
***REMOVED***init(label: String, isRequired: Bool) {
***REMOVED******REMOVED***self.label = label
***REMOVED******REMOVED***self.isRequired = isRequired
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Text(verbatim: "\(label + (isRequired ? " *" : ""))")
***REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED***
***REMOVED***
