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

***REMOVED***/ Forms allow users to edit information about GIS features.
***REMOVED***/
***REMOVED***/ - Since: 200.4
public struct FormView: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The model for the ancestral form view.
***REMOVED***@StateObject private var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the initial expression evaluation is running.
***REMOVED***@State var isEvaluatingInitialExpressions = true
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form defining the editing experience.
***REMOVED***public init(featureForm: FeatureForm) {
***REMOVED******REMOVED***_model = StateObject(wrappedValue: FormViewModel(featureForm: featureForm))
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ScrollViewReader { scrollViewProxy in
***REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED***if isEvaluatingInitialExpressions {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FormHeader(title: model.featureForm.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(model.visibleElements, id: \.self) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeElement(element)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task(id: model.focusedElement) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let focusedElement = model.focusedElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.scrollDismissesKeyboard(
***REMOVED******REMOVED******REMOVED******REMOVED*** Allow tall multiline text fields to be scrolled
***REMOVED******REMOVED******REMOVED***immediately: (model.focusedElement as? FieldFormElement)?.input is TextAreaFormInput ? false : true
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.environmentObject(model)
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED*** Perform the initial expression evaluation.
***REMOVED******REMOVED******REMOVED***try? await model.initialEvaluation()
***REMOVED******REMOVED******REMOVED***isEvaluatingInitialExpressions = false
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
***REMOVED******REMOVED******REMOVED***GroupView(element: element, viewCreator: { makeFieldElement($0) ***REMOVED***)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a field form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeFieldElement(_ element: FieldFormElement) -> some View {
***REMOVED******REMOVED***switch element.input {
***REMOVED******REMOVED***case is ComboBoxFormInput:
***REMOVED******REMOVED******REMOVED***ComboBoxInput(element: element)
***REMOVED******REMOVED***case is DateTimePickerFormInput:
***REMOVED******REMOVED******REMOVED***DateTimeInput(element: element)
***REMOVED******REMOVED***case is RadioButtonsFormInput:
***REMOVED******REMOVED******REMOVED***RadioButtonsInput(element: element)
***REMOVED******REMOVED***case is SwitchFormInput:
***REMOVED******REMOVED******REMOVED***SwitchInput(element: element)
***REMOVED******REMOVED***case is TextAreaFormInput, is TextBoxFormInput:
***REMOVED******REMOVED******REMOVED***TextInput(element: element)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED******REMOVED******REMOVED*** BarcodeScannerFormInput is not currently supported
***REMOVED******REMOVED***if element.isVisible && !(element.input is BarcodeScannerFormInput) {
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ Configures the behavior in which scrollable content interacts with the software keyboard.
***REMOVED******REMOVED***/ - Returns: A view that dismisses the keyboard when the  scroll.
***REMOVED******REMOVED***/ - Parameter immediately: A Boolean value that will cause the keyboard to the keyboard to
***REMOVED******REMOVED***/ dismiss as soon as scrolling starts when `true` and interactively when `false`.
***REMOVED***func scrollDismissesKeyboard(immediately: Bool) -> some View {
***REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED******REMOVED***.scrollDismissesKeyboard(immediately ? .immediately : .interactively)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED***
