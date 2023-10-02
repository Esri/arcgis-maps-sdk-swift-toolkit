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
***REMOVED******REMOVED***/ The form's configuration.
***REMOVED***private let featureForm: FeatureForm?
***REMOVED***
***REMOVED***private let model: FormViewModel

***REMOVED***@State var isEvaluating = true
***REMOVED***@State var refresh: Bool = false
***REMOVED***@State var visibleElements = [FormElement]()

***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameter featureForm: The form's configuration.
***REMOVED***public init(featureForm: FeatureForm?, model: FormViewModel) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.model = model
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(visibleElements, id: \.label) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeElement(element)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("isVisible changed .task for \(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await isVisible in element.$isVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("isVisible changed: \(isVisible) for \(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***refresh.toggle()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TODO: refresh.toggle() doesn't work (current code)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***=> Move visibility stuff to model and find some
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***way to trigger display updates from the model.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***=> Because an EmptyView does not appear to run `.task`
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***stuff, it doesn't handle `isVisible` changes
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***=> So we need to handle visibility at the `FormView` level
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***==>> Maybe created a @Published model.elements property and
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***update that based on the visibility of each element.
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("ENDED isVisible changed .task for \(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***isEvaluating = true
***REMOVED******REMOVED******REMOVED******REMOVED***try await featureForm?.evaluateExpressions()
***REMOVED******REMOVED******REMOVED******REMOVED***isEvaluating = false
***REMOVED******REMOVED******REMOVED******REMOVED***model.formElements = featureForm?.elements ?? []
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print("error evaluating expressions: \(error.localizedDescription)")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: model.visibleElements) { newValue in
***REMOVED******REMOVED******REMOVED***print("onChange of model.visibleElements")
***REMOVED******REMOVED******REMOVED***visibleElements = model.visibleElements
***REMOVED***
***REMOVED***
***REMOVED***

extension FormElement: Equatable {
***REMOVED***public static func == (lhs: ArcGIS.FormElement, rhs: ArcGIS.FormElement) -> Bool {
***REMOVED******REMOVED***lhs.label == rhs.label
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
