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

***REMOVED***/ A view shown at the top of a form element.
struct FormElementHeader: View {
***REMOVED***@Environment(\.formElementPadding) var formElementPadding
***REMOVED***
***REMOVED******REMOVED***/ The form element the header belongs to.
***REMOVED***let element: FormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***titleTextForElement
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED******REMOVED***.padding(.top, formElementPadding)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***var titleTextForElement: some View {
***REMOVED******REMOVED***switch element {
***REMOVED******REMOVED***case let element as FieldFormElement:
***REMOVED******REMOVED******REMOVED***FieldFormElementTitle(element: element)
***REMOVED******REMOVED***case let element as UtilityAssociationsFormElement:
***REMOVED******REMOVED******REMOVED***Text(element.label)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***

extension FormElementHeader {
***REMOVED***struct FieldFormElementTitle: View {
***REMOVED******REMOVED***let element: FieldFormElement
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the input is editable.
***REMOVED******REMOVED***@State private var isEditable = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether a value for the input is required.
***REMOVED******REMOVED***@State private var isRequired = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***Text(verbatim: "\(element.label + (isEditable && isRequired ? " *" : ""))")
***REMOVED******REMOVED******REMOVED******REMOVED***.onIsEditableChange(of: element) { newIsEditable in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isEditable = newIsEditable
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onIsRequiredChange(of: element) { newIsRequired in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isRequired = newIsRequired
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
