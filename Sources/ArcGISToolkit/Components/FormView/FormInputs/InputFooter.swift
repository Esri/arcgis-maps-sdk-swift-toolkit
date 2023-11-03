***REMOVED*** Copyright 2023 Esri
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

***REMOVED***/ A view shown at the bottom of a field element in a form.
struct InputFooter: View {
***REMOVED******REMOVED***/ The form element the footer belongs to.
***REMOVED***let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the form element the footer belongs to is required but a value
***REMOVED******REMOVED***/ is missing.
***REMOVED***let requiredValueMissing: Bool
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if requiredValueMissing {
***REMOVED******REMOVED******REMOVED******REMOVED***Text.required
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***.foregroundColor(requiredValueMissing ? .red : .secondary)
***REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Footer")
***REMOVED***
***REMOVED***
