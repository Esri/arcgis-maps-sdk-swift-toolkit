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
***REMOVED******REMOVED***/ The action to perform when the close button is pressed.
***REMOVED***var onCloseAction: (() -> Void)?
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
***REMOVED******REMOVED******REMOVED***if let onCloseAction {
***REMOVED******REMOVED******REMOVED******REMOVED***XButton(.dismiss) {
#warning("TODO: Check if the presented form has edits.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCloseAction()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***NavigationLayer {
***REMOVED******REMOVED******REMOVED******REMOVED***InternalFeatureFormView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm: rootFeatureForm
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** footer: {
***REMOVED******REMOVED******REMOVED******REMOVED***if let presentedForm, let onFormHandlingEventAction, hasEdits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FormFooter(featureForm: presentedForm, formHandlingEventAction: onFormHandlingEventAction)
***REMOVED******REMOVED******REMOVED***
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

public extension FeatureFormView {
***REMOVED******REMOVED***/ Sets a closure to perform when the form's close button is pressed.
***REMOVED******REMOVED***/ - Parameter action: The closure to perform when the form's close button is pressed.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Use this modifier to show a close button on the form. If the feature form has edits the user will be
***REMOVED******REMOVED***/ prompted to first save or discard the edits.
***REMOVED***func onClose(perform action: @escaping () -> Void) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onCloseAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a closure to perform when a form handling event occurs.
***REMOVED******REMOVED***/ - Parameter action: The closure to perform when the form handling event occurs.
***REMOVED***func onFormHandlingEvent(perform action: @escaping (HandlingEvent) -> Void) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onFormHandlingEventAction = action
***REMOVED******REMOVED***return copy
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
