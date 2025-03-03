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

***REMOVED***/ The `FeatureFormView` component enables users to edit field values of a feature using
***REMOVED***/ pre-configured forms, either from the Web Map Viewer or the Fields Maps Designer.
***REMOVED***/
***REMOVED***/ ![An image of the FeatureFormView component](FeatureFormView)
***REMOVED***/
***REMOVED***/ Forms are currently only supported in maps. The form definition is stored
***REMOVED***/ in the web map itself and contains a title, description, and a list of "form elements".
***REMOVED***/
***REMOVED***/ `FeatureFormView` supports the display of form elements created by
***REMOVED***/ the Map Viewer or Field Maps Designer, including:
***REMOVED***/
***REMOVED***/ - Attachments Element - used to display and edit attachments.
***REMOVED***/ - Field Element - used to edit a single field of a feature with a specific "input type".
***REMOVED***/ - Group Element - used to group elements together. Group Elements
***REMOVED***/ can be expanded, to show all enclosed elements, or collapsed, hiding
***REMOVED***/ the elements it contains.
***REMOVED***/ - Text Element - used to display read-only plain or Markdown-formatted text.
***REMOVED***/ - Utility Associations Element - used to edit associations in utility networks.
***REMOVED***/
***REMOVED***/ A Field Element has a single input type object. The following are the supported input types:
***REMOVED***/
***REMOVED***/ - Barcode - machine readable data
***REMOVED***/ - Combo Box - long list of values in a coded value domain
***REMOVED***/ - Date/Time - date/time picker
***REMOVED***/ - Radio Buttons - short list of values in a coded value domain
***REMOVED***/ - Switch - two mutually exclusive values
***REMOVED***/ - Text Area - multi-line text area
***REMOVED***/ - Text Box - single-line text box
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ - Display a form editing view for a feature based on the feature form definition defined in a web map and obtained from either an `ArcGISFeature`, `ArcGISFeatureTable`, `FeatureLayer` or `SubtypeSublayer`.
***REMOVED***/ - Uses native SwiftUI controls for editing, such as `TextEditor`, `TextField`, and `DatePicker` for consistent platform styling.
***REMOVED***/ - Supports elements containing Arcade expression and automatically evaluates expressions for element visibility, editability, values, and "required" state.
***REMOVED***/ - Add, delete, or rename feature attachments.
***REMOVED***/ - Fully supports dark mode, as do all Toolkit components.
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ The feature form view can be embedded in any type of container view including, as demonstrated in the
***REMOVED***/ example, the Toolkit's `FloatingPanel`.
***REMOVED***/
***REMOVED***/ To see it in action, try out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [FeatureFormExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/FeatureFormExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `FeatureFormView` see the <doc:FeatureFormViewTutorial>.
***REMOVED***/
***REMOVED***/ - Note: In order to capture video and photos as form attachments, your application will need
***REMOVED***/ `NSCameraUsageDescription` and, `NSMicrophoneUsageDescription` entries in the
***REMOVED***/ `Info.plist` file.
***REMOVED***/
***REMOVED***/ - Since: 200.4
public struct FeatureFormView: View {
***REMOVED******REMOVED***/ The feature form currently visible in the navigation layer.
***REMOVED***@State private var presentedForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the presented feature form has edits.
***REMOVED***@State private var hasEdits: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The root feature form.
***REMOVED***let rootFeatureForm: FeatureForm
***REMOVED***
***REMOVED******REMOVED***/ The visibility of the form header.
***REMOVED***var headerVisibility: Visibility = .automatic
***REMOVED***
***REMOVED******REMOVED***/ The closure to perform when a ``HandlingEvent`` occurs.
***REMOVED***var onFormHandlingEventAction: ((HandlingEvent) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The validation error visibility configuration of the form.
***REMOVED***var validationErrorVisibility: ValidationErrorVisibility = FormViewValidationErrorVisibility.defaultValue
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form defining the editing experience.
***REMOVED***public init(featureForm: FeatureForm) {
***REMOVED******REMOVED***self.rootFeatureForm = featureForm
***REMOVED******REMOVED***_presentedForm = .init(initialValue: featureForm)
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED***NavigationLayer {
***REMOVED******REMOVED******REMOVED******REMOVED***InternalFeatureFormView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm: rootFeatureForm
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if hasEdits {
#warning("TODO: Only apply additional bottom padding to FormFooter in compact environments to get us into the safe area.")
***REMOVED******REMOVED******REMOVED******REMOVED***FormFooter(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***discardAction: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let presentedForm {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***presentedForm.discardEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onFormHandlingEventAction?(.DiscardedEdits(presentedForm, willNavigate: false))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***saveAction: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let presentedForm {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await presentedForm.finishEditing()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onFormHandlingEventAction?(.FinishedEditing(presentedForm, willNavigate: false))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom])
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(Divider(), alignment: .top)
***REMOVED******REMOVED******REMOVED******REMOVED***.transition(.move(edge: .bottom))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.environment(\.formChangedAction, onFormChangedAction)
***REMOVED******REMOVED***.environment(\.validationErrorVisibility, validationErrorVisibility)
***REMOVED******REMOVED***.task(id: presentedForm?.feature.globalID) {
***REMOVED******REMOVED******REMOVED***if let presentedForm {
***REMOVED******REMOVED******REMOVED******REMOVED***onFormHandlingEventAction?(.StartedEditing(presentedForm))
***REMOVED******REMOVED******REMOVED******REMOVED***for await hasEdits in presentedForm.$hasEdits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { self.hasEdits = hasEdits ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension FeatureFormView {
***REMOVED******REMOVED***/ The closure to perform when the presented feature form changes.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Note: This action has the potential to be called under four scenarios. Whenever an
***REMOVED******REMOVED***/ ``InternalFeatureFormView`` appears (which can happen during forward
***REMOVED******REMOVED***/ or reverse navigation) and whenever a ``UtilityAssociationGroupResultView`` appears
***REMOVED******REMOVED***/ (which can also happen during forward or reverse navigation). Because those two views (and the
***REMOVED******REMOVED***/ intermediate ``UtilityAssociationsFilterResultView`` are all considered to be apart of
***REMOVED******REMOVED***/ the same ``FeatureForm`` make sure not to over-emit form handling events.
***REMOVED***var onFormChangedAction: (FeatureForm) -> Void {
***REMOVED******REMOVED***{ featureForm in
***REMOVED******REMOVED******REMOVED***if featureForm.feature.globalID != presentedForm?.feature.globalID {
***REMOVED******REMOVED******REMOVED******REMOVED***self.presentedForm = featureForm
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***


extension EnvironmentValues {
***REMOVED******REMOVED***/ The environment value to access the closure to call when the presented feature form changes.
***REMOVED***@Entry var formChangedAction: ((FeatureForm) -> Void)?
***REMOVED***

struct InternalFeatureFormView: View {
***REMOVED***@Environment(\.formChangedAction) var formChangedAction
***REMOVED***
#warning("elementPadding to be removed when makeUtilityAssociationsFormElement is revised")
***REMOVED***@Environment(\.formElementPadding) var formElementPadding
***REMOVED***
***REMOVED***@EnvironmentObject private var navigationLayerModel: NavigationLayerModel
***REMOVED***
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@StateObject private var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether initial expression evaluation is running.
***REMOVED***@State private var initialExpressionsAreEvaluating = true
***REMOVED***
***REMOVED******REMOVED***/ The title of the feature form view.
***REMOVED***@State private var title = ""
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form defining the editing experience.
***REMOVED***init(featureForm: FeatureForm) {
***REMOVED******REMOVED***_model = StateObject(wrappedValue: FormViewModel(featureForm: featureForm))
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if initialExpressionsAreEvaluating {
***REMOVED******REMOVED******REMOVED******REMOVED***initialBody
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***evaluatedForm
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***formChangedAction?(model.featureForm)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var evaluatedForm: some View {
***REMOVED******REMOVED***ScrollViewReader { scrollViewProxy in
***REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !title.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FormHeader(title: title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(model.visibleElements, id: \.self) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeElement(element)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let attachmentsElement = model.featureForm.defaultAttachmentsElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The Toolkit currently only supports AttachmentsFormElements via the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** default attachments element. Once AttachmentsFormElements can be authored
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** this can call makeElement(_:) instead and makeElement(_:) should have a
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** case added for AttachmentsFormElement.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentsFeatureElementView(featureElement: attachmentsElement)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(model.focusedElement) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***if let focusedElement = model.focusedElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onTitleChange(of: model.featureForm) { newTitle in
***REMOVED******REMOVED******REMOVED******REMOVED***title = newTitle
***REMOVED******REMOVED***
***REMOVED***
#if os(iOS)
***REMOVED******REMOVED***.scrollDismissesKeyboard(.immediately)
#endif
***REMOVED******REMOVED***.environmentObject(model)
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
***REMOVED******REMOVED******REMOVED***GroupView(element: element, viewCreator: { internalMakeElement($0) ***REMOVED***)
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
***REMOVED******REMOVED******REMOVED***InputWrapper(element: element)
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
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Text(element.label.isEmpty ? "Associations" : element.label)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED******REMOVED***.padding(.top, formElementPadding)
***REMOVED******REMOVED***
***REMOVED******REMOVED***UtilityAssociationsFormElementView(element: element)
***REMOVED******REMOVED******REMOVED***.environmentObject(model)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if !element.description.isEmpty {
***REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED***
***REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The progress view to be shown while initial expression evaluation is running.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This avoids flashing elements that may immediately be set hidden or have
***REMOVED******REMOVED***/ values change as a result of initial expression evaluation.
***REMOVED***var initialBody: some View {
***REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***await model.initialEvaluation()
***REMOVED******REMOVED******REMOVED******REMOVED***initialExpressionsAreEvaluating = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
