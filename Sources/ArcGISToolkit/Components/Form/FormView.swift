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
***REMOVED******REMOVED***/ The model for the ancestral form view.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ The form's configuration.
***REMOVED***private let featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether an evaluation is running.
***REMOVED***@State var isEvaluating = true
***REMOVED***
***REMOVED******REMOVED***/ A list of the visible elements in the form.
***REMOVED***@State var visibleElements = [FormElement]()
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameter featureForm: The form's configuration.
***REMOVED***public init(featureForm: FeatureForm?) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***if isEvaluating {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FormHeader(title: featureForm?.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(model.visibleElements, id: \.id) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeElement(element)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.scrollDismissesKeyboard()
***REMOVED******REMOVED***.onChange(of: model.visibleElements) { _ in
***REMOVED******REMOVED******REMOVED***visibleElements = model.visibleElements
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***isEvaluating = true
***REMOVED******REMOVED******REMOVED******REMOVED***try await featureForm?.evaluateExpressions()
***REMOVED******REMOVED******REMOVED******REMOVED***isEvaluating = false
***REMOVED******REMOVED******REMOVED******REMOVED***model.initializeIsVisibleTasks()
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print("error evaluating expressions: \(error.localizedDescription)")
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
***REMOVED******REMOVED******REMOVED***DateTimeInput(featureForm: featureForm, element: element, input: `input`)
***REMOVED******REMOVED***case let `input` as RadioButtonsFormInput:
***REMOVED******REMOVED******REMOVED***RadioButtonsInput(featureForm: featureForm, element: element, input: `input`)
***REMOVED******REMOVED***case let `input` as SwitchFormInput:
***REMOVED******REMOVED******REMOVED***SwitchInput(featureForm: featureForm, element: element, input: `input`)
***REMOVED******REMOVED***case let `input` as TextAreaFormInput:
***REMOVED******REMOVED******REMOVED***MultiLineTextInput(featureForm: featureForm, element: element, input: `input`)
***REMOVED******REMOVED***case let `input` as TextBoxFormInput:
***REMOVED******REMOVED******REMOVED***SingleLineTextInput(featureForm: featureForm, element: element, input: `input`)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED******REMOVED***if element.isVisible {
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED***
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

private extension View {
***REMOVED******REMOVED***/ - Returns: A view that immediately dismisses the keyboard upon scroll.
***REMOVED***func scrollDismissesKeyboard() -> some View {
***REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED******REMOVED***.scrollDismissesKeyboard(.immediately)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED***
