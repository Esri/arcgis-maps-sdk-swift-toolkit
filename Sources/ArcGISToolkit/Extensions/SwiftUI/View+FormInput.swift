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

extension View {
***REMOVED******REMOVED***/ Modifier for watching ``FormElement.isEditableChanged`` events.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The form element to watch for changes on.
***REMOVED******REMOVED***/   - action: The action which watches for changes.
***REMOVED******REMOVED***/ - Returns: The modified view.
***REMOVED***func onIsEditableChange(
***REMOVED******REMOVED***of element: FieldFormElement,
***REMOVED******REMOVED***action: @escaping (_ newIsEditable: Bool) -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED***.task(id: ObjectIdentifier(element)) {
***REMOVED******REMOVED******REMOVED******REMOVED***for await isEditable in element.$isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(isEditable)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Modifier for watching ``FormElement.isRequiredChanged`` events.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The form element to watch for changes on.
***REMOVED******REMOVED***/   - action: The action which watches for changes.
***REMOVED******REMOVED***/ - Returns: The modified view.
***REMOVED***func onIsRequiredChange(
***REMOVED******REMOVED***of element: FieldFormElement,
***REMOVED******REMOVED***action: @escaping (_ newIsRequired: Bool) -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED***.task(id: ObjectIdentifier(element)) {
***REMOVED******REMOVED******REMOVED******REMOVED***for await isRequired in element.$isRequired {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(isRequired)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Modifier for watching ``FormElement.valueChanged`` events.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The form element to watch for changes on.
***REMOVED******REMOVED***/   - action: The action which watches for changes.
***REMOVED******REMOVED***/ - Returns: The modified view.
***REMOVED***func onValueChange(
***REMOVED******REMOVED***of element: FieldFormElement,
***REMOVED******REMOVED***action: @escaping (_ newValue: Any?, _ newFormattedValue: String) -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED***.task(id: ObjectIdentifier(element)) {
***REMOVED******REMOVED******REMOVED******REMOVED***for await value in element.$value {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(value, element.formattedValue)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
