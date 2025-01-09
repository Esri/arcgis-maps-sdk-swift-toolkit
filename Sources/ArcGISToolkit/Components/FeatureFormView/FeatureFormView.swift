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
@available(visionOS, unavailable)
public struct FeatureFormView: View {
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@StateObject private var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var groups: [UtilityNetworkAssociationFormElementView.Group]?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether initial expression evaluation is running.
***REMOVED***@State private var initialExpressionsAreEvaluating = true
***REMOVED***
***REMOVED******REMOVED***/ The title of the feature form view.
***REMOVED***@State private var title = ""
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let utilityNetwork: UtilityNetwork?
***REMOVED***
***REMOVED******REMOVED***/ The visibility of the form header.
***REMOVED***var headerVisibility: Visibility = .automatic
***REMOVED***
***REMOVED******REMOVED***/ The validation error visibility configuration of the form.
***REMOVED***var validationErrorVisibility: ValidationErrorVisibility = FormViewValidationErrorVisibility.defaultValue
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form defining the editing experience.
***REMOVED***public init(featureForm: FeatureForm, utilityNetwork: UtilityNetwork? = nil) {
***REMOVED******REMOVED***_model = StateObject(wrappedValue: FormViewModel(featureForm: featureForm))
***REMOVED******REMOVED***self.utilityNetwork = utilityNetwork
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***if initialExpressionsAreEvaluating {
***REMOVED******REMOVED******REMOVED***initialBody
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***evaluatedForm
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var evaluatedForm: some View {
***REMOVED******REMOVED***ScrollViewReader { scrollViewProxy in
***REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !title.isEmpty && headerVisibility != .hidden {
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let groups = groups, groups.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkAssociationFormElementView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: "[Utility Associations Element Description]",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***groups: groups,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: "[Utility Associations Element Title]"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom)
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
***REMOVED******REMOVED***.environment(\.validationErrorVisibility, validationErrorVisibility)
***REMOVED******REMOVED***.environmentObject(model)
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***try? await utilityNetwork?.load()
***REMOVED******REMOVED******REMOVED***if let utilityElement = utilityNetwork?.makeElement(arcGISFeature: model.featureForm.feature) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let associations = try? await utilityNetwork?.associations(for: utilityElement) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***var groups = [UtilityNetworkAssociationFormElementView.Group]()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let uniqueGroups = Array(Set(associations.map { $0.kind ***REMOVED***))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***uniqueGroups.forEach { kind in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let groupMembers = associations.filter { $0.kind == kind ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***var associations: [UtilityNetworkAssociationFormElementView.Association] = []
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***groupMembers.forEach { association in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let associatedElement = association.toElement
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let newAssociation = UtilityNetworkAssociationFormElementView.Association(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: "[Association Description]",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***icon: nil,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: associatedElement.assetType.name
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = try? await utilityNetwork?.features(for: [associatedElement]).first,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let featureLayer = feature.table?.layer as? FeatureLayer,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let renderer = featureLayer.renderer,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let symbol = renderer.symbol(for: feature) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let scale: CGFloat
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale = 1
#else
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale = UIScreen.main.scale
#endif
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return try? await symbol.makeSwatch(scale: scale)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***associations.append(newAssociation)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***groups.append(.init(associations: associations, description: "[Group Description]", name: "\(kind)".capitalized))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.groups = groups
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***print("Not a Utility Element")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
extension FeatureFormView {
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
