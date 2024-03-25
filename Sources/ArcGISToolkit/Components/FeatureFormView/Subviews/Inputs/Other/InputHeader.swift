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

***REMOVED***/ A view shown at the top of a field element in a form.
struct InputHeader: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the input is editable.
***REMOVED***@State private var isEditable = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a value for the input is required.
***REMOVED***@State private var isRequired = false
***REMOVED***
***REMOVED******REMOVED***/ The element the input belongs to.
***REMOVED***let element: FieldFormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Text(verbatim: "\(element.label + (isEditable && isRequired ? " *" : ""))")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED******REMOVED***.padding(.top, elementPadding)
***REMOVED******REMOVED***.onIsEditableChange(of: element) { newIsEditable in
***REMOVED******REMOVED******REMOVED***isEditable = newIsEditable
***REMOVED***
***REMOVED******REMOVED***.onIsRequiredChange(of: element) { newIsRequired in
***REMOVED******REMOVED******REMOVED***isRequired = newIsRequired
***REMOVED***
***REMOVED***
***REMOVED***
