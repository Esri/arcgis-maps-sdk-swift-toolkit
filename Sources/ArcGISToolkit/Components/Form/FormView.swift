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

***REMOVED***/ Forms allow users to edit information about GIS features.
***REMOVED***/ - Since: 200.3
public struct FormView: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameter featureForm: <#featureForm description#>
***REMOVED***public init(featureForm: FeatureForm?) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***FormHeader(title: featureForm?.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(featureForm?.elements ?? [], id: \.label) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeElement(element)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension FormView {
***REMOVED******REMOVED***/ Makes UI for a form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeElement(_ element: FormElement) -> some View {
***REMOVED******REMOVED***switch element {
***REMOVED******REMOVED***case let element as FieldFormElement:
***REMOVED******REMOVED******REMOVED***makeFieldElement(element)
***REMOVED******REMOVED***case let element as GroupFormElement:
***REMOVED******REMOVED******REMOVED***makeGroupElement(element)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a field form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeFieldElement(_ element: FieldFormElement) -> some View {
***REMOVED******REMOVED***switch element.input {
***REMOVED******REMOVED***case let `input` as ComboBoxFormInput:
***REMOVED******REMOVED******REMOVED***ComboBoxInput(featureForm: featureForm, element: element, input: `input`)
***REMOVED******REMOVED***case let `input` as DateTimePickerFormInput:
***REMOVED******REMOVED******REMOVED***DateTimeEntry(featureForm: featureForm, element: element, input: `input`)
***REMOVED******REMOVED***case let `input` as TextAreaFormInput:
***REMOVED******REMOVED******REMOVED***MultiLineTextEntry(featureForm: featureForm, element: element, input: `input`)
***REMOVED******REMOVED***case let `input` as TextBoxFormInput:
***REMOVED******REMOVED******REMOVED***SingleLineTextEntry(featureForm: featureForm, element: element, input: `input`)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a group form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeGroupElement(_ element: GroupFormElement) -> some View {
***REMOVED******REMOVED***DisclosureGroup(element.label) {
***REMOVED******REMOVED******REMOVED***ForEach(element.formElements, id: \.label) { formElement in
***REMOVED******REMOVED******REMOVED******REMOVED***if let element = formElement as? FieldFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeFieldElement(element)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
