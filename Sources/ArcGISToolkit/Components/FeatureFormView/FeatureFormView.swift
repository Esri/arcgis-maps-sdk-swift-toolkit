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
***REMOVED***private let presentedForm: Binding<FeatureForm?>
***REMOVED***
***REMOVED******REMOVED***/ The root feature form.
***REMOVED***private let rootFeatureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The visibility of the close button.
***REMOVED***var closeButtonVisibility: Visibility = .automatic
***REMOVED***
***REMOVED******REMOVED***/ The visibility of the "save" and "discard" buttons.
***REMOVED***var editingButtonsVisibility: Visibility = .automatic
***REMOVED***
***REMOVED******REMOVED***/ The closure to perform when a ``EditingEvent`` occurs.
***REMOVED***var onFormEditingEventAction: ((EditingEvent) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value that indicates whether a FeatureForm is the presented view in the NavigationLayer.
***REMOVED***@State private var aFeatureFormIsPresented = true
***REMOVED***
***REMOVED******REMOVED***/ Continuation information for the alert.
***REMOVED***@State private var alertContinuation: (willNavigate: Bool, action: () -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ An error thrown from finish editing.
***REMOVED***@State private var finishEditingError: String?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the presented feature form has edits.
***REMOVED***@State private var hasEdits: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The validation error visibility configuration of the form.
***REMOVED***@State private var validationErrorVisibility: Visibility = .hidden
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form defining the editing experience.
***REMOVED******REMOVED***/ - Since: 200.8
***REMOVED***public init(featureForm: Binding<FeatureForm?>) {
***REMOVED******REMOVED***self.rootFeatureForm = featureForm.wrappedValue
***REMOVED******REMOVED***self.presentedForm = featureForm
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***if let rootFeatureForm {
***REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLayer {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***InternalFeatureFormView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm: rootFeatureForm
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** headerTrailing: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if closeButtonVisibility != .hidden {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***XButton(.dismiss) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if hasEdits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertContinuation = (false, {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***presentedForm.wrappedValue = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***presentedForm.wrappedValue = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** footer: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let presentedForm = presentedForm.wrappedValue,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   hasEdits,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   editingButtonsVisibility != .hidden {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FormFooter(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm: presentedForm,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formHandlingEventAction: onFormEditingEventAction,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***validationErrorVisibility: $validationErrorVisibility,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***finishEditingError: $finishEditingError
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.backNavigationAction { navigationLayerModel in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if aFeatureFormIsPresented && hasEdits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertContinuation = (true, { navigationLayerModel.pop() ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***navigationLayerModel.pop()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onNavigationPathChanged { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let item {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if type(of: item.view()) == InternalFeatureFormView.self {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***aFeatureFormIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***aFeatureFormIsPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Alert for abandoning unsaved edits
***REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED***(presentedForm.wrappedValue?.validationErrors.isEmpty ?? true) ? "Discard Edits?" : "Validation Errors",
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: alertForUnsavedEditsIsPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***actions: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let presentedForm = presentedForm.wrappedValue, let (willNavigate, continuation) = alertContinuation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Discard Edits", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***presentedForm.discardEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onFormEditingEventAction?(.discardedEdits(willNavigate: willNavigate))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***validationErrorVisibility = .hidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continuation()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !presentedForm.validationErrors.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***validationErrorVisibility = .visible
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if (presentedForm.validationErrors.isEmpty) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Save Edits") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await presentedForm.finishEditing()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onFormEditingEventAction?(.savedEdits(willNavigate: willNavigate))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continuation()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***finishEditingError = String(describing: error)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Continue Editing", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alertForUnsavedEditsIsPresented.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let validationErrors = presentedForm.wrappedValue?.validationErrors,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   !validationErrors.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("You have ^[\(validationErrors.count) error](inflect: true) that must be fixed before saving.")
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Updates to the form will be lost.")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "The form wasn't submitted",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "The message shown when a form could not be submitted."
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: alertForFinishEditingErrorsIsPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***actions: { ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let finishEditingError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(finishEditingError)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.environment(\.formChangedAction, onFormChangedAction)
***REMOVED******REMOVED******REMOVED***.environment(\.setAlertContinuation, setAlertContinuation)
***REMOVED******REMOVED******REMOVED***.environment(\._validationErrorVisibility, validationErrorVisibility)
***REMOVED******REMOVED******REMOVED***.task(id: presentedForm.wrappedValue?.feature.globalID) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let presentedForm = presentedForm.wrappedValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await hasEdits in presentedForm.$hasEdits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { self.hasEdits = hasEdits ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

public extension FeatureFormView {
***REMOVED******REMOVED***/ Represents events that occur during the form editing lifecycle.
***REMOVED******REMOVED***/ These events notify you when the user has either saved or discarded their edits.
***REMOVED******REMOVED***/ - Since: 200.8
***REMOVED***enum EditingEvent {
***REMOVED******REMOVED******REMOVED***/ Indicates that the user has discarded their edits.
***REMOVED******REMOVED******REMOVED***/ - Parameter willNavigate: A Boolean value indicating whether the view will navigate after discarding.
***REMOVED******REMOVED***case discardedEdits(willNavigate: Bool)
***REMOVED******REMOVED******REMOVED***/ Indicates that the user has saved their edits.
***REMOVED******REMOVED******REMOVED***/ - Parameter willNavigate: A Boolean value indicating whether the view will navigate after saving.
***REMOVED******REMOVED***case savedEdits(willNavigate: Bool)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the visibility of the close button on the form.
***REMOVED******REMOVED***/ - Parameter visibility: The visibility of the close button.
***REMOVED******REMOVED***/ - Since: 200.8
***REMOVED***func closeButton(_ visibility: Visibility) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.closeButtonVisibility = visibility
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the visibility of the save and discard buttons on the form.
***REMOVED******REMOVED***/ - Parameter visibility: The visibility of the save and discard buttons.
***REMOVED******REMOVED***/ - Since: 200.8
***REMOVED***func editingButtons(_ visibility: Visibility) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.editingButtonsVisibility = visibility
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a closure to perform when a form editing event occurs.
***REMOVED******REMOVED***/ - Parameter action: The closure to perform when the form editing event occurs.
***REMOVED******REMOVED***/ - Since: 200.8
***REMOVED***func onFormEditingEvent(perform action: @escaping (EditingEvent) -> Void) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onFormEditingEventAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

extension FeatureFormView {
***REMOVED******REMOVED***/ A Boolean value indicating whether the finish editing error alert is presented.
***REMOVED***var alertForFinishEditingErrorsIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***finishEditingError != nil
***REMOVED*** set: { newIsPresented in
***REMOVED******REMOVED******REMOVED***if !newIsPresented {
***REMOVED******REMOVED******REMOVED******REMOVED***finishEditingError = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the unsaved edits alert is presented.
***REMOVED***var alertForUnsavedEditsIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***alertContinuation != nil
***REMOVED*** set: { newIsPresented in
***REMOVED******REMOVED******REMOVED***if !newIsPresented {
***REMOVED******REMOVED******REMOVED******REMOVED***alertContinuation = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED******REMOVED***if let presentedForm = presentedForm.wrappedValue {
***REMOVED******REMOVED******REMOVED******REMOVED***if featureForm.feature.globalID != presentedForm.feature.globalID {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.presentedForm.wrappedValue = featureForm
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***validationErrorVisibility = .hidden
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A closure used to set the alert continuation.
***REMOVED***var setAlertContinuation: (Bool, @escaping () -> Void) -> Void {
***REMOVED******REMOVED***{ willNavigate, continuation in
***REMOVED******REMOVED******REMOVED***alertContinuation = (willNavigate: willNavigate, action: continuation)
***REMOVED***
***REMOVED***
***REMOVED***

extension EnvironmentValues {
***REMOVED******REMOVED***/ The environment value to access the closure to call when the presented feature form changes.
***REMOVED***@Entry var formChangedAction: ((FeatureForm) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The environment value to set the continuation to use when the user responds to the alert.
***REMOVED***@Entry var setAlertContinuation: ((Bool, @escaping () -> Void) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The environment value to access the validation error visibility.
***REMOVED***@Entry var _validationErrorVisibility: Visibility = .hidden
***REMOVED***
