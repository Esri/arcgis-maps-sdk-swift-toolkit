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

***REMOVED***/ A view which wraps the creation of a view for the underlying field form element.
***REMOVED***/
***REMOVED***/ This view specifically handles the logic of monitoring whether a field form element is editable and choosing
***REMOVED***/ the correct Toolkit input view based on the element's input type.
struct EditableStateInputWrapper: View {
***REMOVED******REMOVED***/ A Boolean value indicating whether the input is editable.
***REMOVED***@State private var isEditable = false
***REMOVED***
***REMOVED******REMOVED***/ The input's element.
***REMOVED***let element: FieldFormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED***switch element.input {
***REMOVED******REMOVED******REMOVED******REMOVED***case is ComboBoxFormInput:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ComboBoxInput(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***case is DateTimePickerFormInput:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DateTimeInput(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***case is RadioButtonsFormInput:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RadioButtonsInput(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***case is SwitchFormInput:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SwitchInput(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***case is TextAreaFormInput, is TextBoxFormInput:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextInput(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***ReadOnlyInput(element: element)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***isEditable = element.isEditable
***REMOVED***
***REMOVED******REMOVED***.onIsEditableChange(of: element) { newIsEditable in
***REMOVED******REMOVED******REMOVED***isEditable = newIsEditable
***REMOVED***
***REMOVED***
***REMOVED***
