***REMOVED*** Copyright 2025 Esri
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

struct InternalFeatureFormView: View {
***REMOVED***@Environment(\.formChangedAction) var formChangedAction
***REMOVED***
***REMOVED******REMOVED***/ The model for the navigation layer.
***REMOVED***@Environment(NavigationLayerModel.self) private var navigationLayerModel
***REMOVED***
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@State private var internalFeatureFormViewModel: InternalFeatureFormViewModel
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form defining the editing experience.
***REMOVED***init(featureForm: FeatureForm) {
***REMOVED******REMOVED***internalFeatureFormViewModel = InternalFeatureFormViewModel(featureForm: featureForm)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ScrollViewReader { scrollViewProxy in
***REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(internalFeatureFormViewModel.visibleElements, id: \.self) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeElement(element)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let attachmentsElement = internalFeatureFormViewModel.featureForm.defaultAttachmentsElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The Toolkit currently only supports AttachmentsFormElements via the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** default attachments element. Once AttachmentsFormElements can be authored
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** this can call makeElement(_:) instead and makeElement(_:) should have a
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** case added for AttachmentsFormElement.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentsFeatureElementView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formElement: attachmentsElement,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formViewModel: internalFeatureFormViewModel
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: internalFeatureFormViewModel.focusedElement) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let focusedElement = internalFeatureFormViewModel.focusedElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onTitleChange(of: internalFeatureFormViewModel.featureForm) { newTitle in
***REMOVED******REMOVED******REMOVED******REMOVED***internalFeatureFormViewModel.title = newTitle
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationLayerTitle(internalFeatureFormViewModel.title)
***REMOVED***
#if os(iOS)
***REMOVED******REMOVED***.scrollDismissesKeyboard(.immediately)
#endif
***REMOVED******REMOVED***.environment(internalFeatureFormViewModel)
***REMOVED******REMOVED***.padding([.horizontal])
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***await internalFeatureFormViewModel.initialEvaluation()
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***formChangedAction?(internalFeatureFormViewModel.featureForm)
***REMOVED***
***REMOVED***
***REMOVED***

extension InternalFeatureFormView {
***REMOVED******REMOVED***/ Makes UI for a form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeElement(_ element: FormElement) -> some View {
***REMOVED******REMOVED***switch element {
***REMOVED******REMOVED***case let element as FieldFormElement:
***REMOVED******REMOVED******REMOVED***makeFieldElement(element)
***REMOVED******REMOVED***case let element as GroupFormElement:
***REMOVED******REMOVED******REMOVED***GroupView(element: element) { internalMakeElement($0) ***REMOVED***
***REMOVED******REMOVED***case let element as TextFormElement:
***REMOVED******REMOVED******REMOVED***makeTextElement(element)
***REMOVED******REMOVED***case let element as UtilityAssociationsFormElement:
***REMOVED******REMOVED******REMOVED***makeUtilityAssociationsFormElement(element)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a field form element or a text form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func internalMakeElement(_ element: FormElement) -> some View {
***REMOVED******REMOVED***switch element {
***REMOVED******REMOVED***case let element as FieldFormElement:
***REMOVED******REMOVED******REMOVED***makeFieldElement(element)
***REMOVED******REMOVED***case let element as TextFormElement:
***REMOVED******REMOVED******REMOVED***makeTextElement(element)
***REMOVED******REMOVED***case let element as UtilityAssociationsFormElement:
***REMOVED******REMOVED******REMOVED***makeUtilityAssociationsFormElement(element)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a field form element including a divider beneath it.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeFieldElement(_ element: FieldFormElement) -> some View {
***REMOVED******REMOVED***if !(element.input is UnsupportedFormInput) {
***REMOVED******REMOVED******REMOVED***FormElementWrapper(element: element)
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a text form element including a divider beneath it.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeTextElement(_ element: TextFormElement) -> some View {
***REMOVED******REMOVED***TextFormElementView(element: element)
***REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a utility associations element including a divider beneath it.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeUtilityAssociationsFormElement(_ element: UtilityAssociationsFormElement) -> some View {
***REMOVED******REMOVED***FormElementWrapper(element: element)
***REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
