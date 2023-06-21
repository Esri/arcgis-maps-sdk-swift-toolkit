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

***REMOVED***/ A view shown at the top of each field element in a form.
struct FormElementHeader: View {
***REMOVED******REMOVED***/ The form element the header is for.
***REMOVED***let element: FieldFeatureFormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Text(element.label)
***REMOVED******REMOVED******REMOVED***.font(.headline)
***REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED***
***REMOVED***
