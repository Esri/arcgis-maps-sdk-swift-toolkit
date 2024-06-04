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
***REMOVED***Toolkit
***REMOVED***

struct FeatureFormExampleView: View {
***REMOVED******REMOVED***/ The height of the map view's attribution bar.
***REMOVED***@State private var attributionBarHeight: CGFloat = 0
***REMOVED***
***REMOVED******REMOVED***/ The height to present the form at.
***REMOVED***@State private var detent: FloatingPanelDetent = .full
***REMOVED***
***REMOVED******REMOVED***/ The point on the screen the user tapped on to identify a feature.
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = Map(url: .sampleData)!
***REMOVED***
***REMOVED******REMOVED***/ The validation error visibility configuration of the form.
***REMOVED***@State private var validationErrorVisibility = FeatureFormView.ValidationErrorVisibility.automatic
***REMOVED***
***REMOVED******REMOVED***/ The form view model provides a channel of communication between the form view and its host.
***REMOVED***@StateObject private var model = Model()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAttributionBarHeightChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight = $0
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch model.state {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .idle:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let .editing(featureForm):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.state = .cancellationPending(featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = await identifyFeature(with: mapViewProxy),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.state = .editing(FeatureForm(feature: feature, definition: formDefinition))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $detent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: model.formIsPresented
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let featureForm = model.featureForm {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FeatureFormView(featureForm: featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.validationErrors(validationErrorVisibility)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.top, 16)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: model.formIsPresented.wrappedValue) { formIsPresented in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !formIsPresented { validationErrorVisibility = .automatic ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.alert("Discard edits", isPresented: model.cancelConfirmationIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Discard edits", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.discardEdits()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if case let .cancellationPending(featureForm) = model.state {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Continue editing", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.state = .editing(featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Updates to this feature will be lost.")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** swiftlint:disable vertical_parameter_alignment_on_call
***REMOVED******REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"The form wasn't submitted",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: model.alertIsPresented
***REMOVED******REMOVED******REMOVED******REMOVED***) { ***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if case let .generalError(_, errorMessage) = model.state {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***errorMessage
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** swiftlint:enable vertical_parameter_alignment_on_call
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden(model.formIsPresented.wrappedValue)
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch model.state {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .validating, .finishingEdits, .applyingEdits:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack(spacing: 5) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.circular)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.textForState
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(.thinMaterial)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 10))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if model.formIsPresented.wrappedValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard case let .editing(featureForm) = model.state else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.state = .cancellationPending(featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(model.formControlsAreDisabled)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Submit") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***validationErrorVisibility = .visible
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await model.submitEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(model.formControlsAreDisabled)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension FeatureFormExampleView {
***REMOVED******REMOVED***/ Identifies features, if any, at the current screen point.
***REMOVED******REMOVED***/ - Parameter proxy: The proxy to use for identification.
***REMOVED******REMOVED***/ - Returns: The first identified feature in a layer with
***REMOVED******REMOVED***/ a feature form definition.
***REMOVED***func identifyFeature(with proxy: MapViewProxy) async -> ArcGISFeature? {
***REMOVED******REMOVED***guard let identifyScreenPoint else { return nil ***REMOVED***
***REMOVED******REMOVED***let identifyResult = try? await proxy.identifyLayers(
***REMOVED******REMOVED******REMOVED***screenPoint: identifyScreenPoint,
***REMOVED******REMOVED******REMOVED***tolerance: 10
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.first(where: { result in
***REMOVED******REMOVED******REMOVED******REMOVED***if let feature = result.geoElements.first as? ArcGISFeature,
***REMOVED******REMOVED******REMOVED******REMOVED***   (feature.table?.layer as? FeatureLayer)?.featureFormDefinition != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return identifyResult?.geoElements.first as? ArcGISFeature
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED***static var sampleData: Self {
***REMOVED******REMOVED***.init(string: "https:***REMOVED***www.arcgis.com/apps/mapviewer/index.html?webmap=f72207ac170a40d8992b7a3507b44fad")!
***REMOVED***
***REMOVED***

***REMOVED***/ The model class for the form example view
@MainActor
class Model: ObservableObject {
***REMOVED******REMOVED***/ Feature form workflow states.
***REMOVED***enum State {
***REMOVED******REMOVED******REMOVED***/ Edits are being applied to the remote service.
***REMOVED******REMOVED***case applyingEdits(FeatureForm)
***REMOVED******REMOVED******REMOVED***/ The user has triggered potential cancellation.
***REMOVED******REMOVED***case cancellationPending(FeatureForm)
***REMOVED******REMOVED******REMOVED***/ A feature form is in use.
***REMOVED******REMOVED***case editing(FeatureForm)
***REMOVED******REMOVED******REMOVED***/ Edits are being committed to the local geodatabase.
***REMOVED******REMOVED***case finishingEdits(FeatureForm)
***REMOVED******REMOVED******REMOVED***/ There was an error in a workflow step.
***REMOVED******REMOVED***case generalError(FeatureForm, Text)
***REMOVED******REMOVED******REMOVED***/ No feature is being edited.
***REMOVED******REMOVED***case idle
***REMOVED******REMOVED******REMOVED***/ The form is being checked for validation errors.
***REMOVED******REMOVED***case validating(FeatureForm)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current feature form workflow state.
***REMOVED***@Published var state: State = .idle {
***REMOVED******REMOVED***willSet {
***REMOVED******REMOVED******REMOVED***switch newValue {
***REMOVED******REMOVED******REMOVED***case let .editing(featureForm):
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm.featureLayer?.selectFeature(featureForm.feature)
***REMOVED******REMOVED******REMOVED***case .idle:
***REMOVED******REMOVED******REMOVED******REMOVED***guard let featureForm else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm.featureLayer?.unselectFeature(featureForm.feature)
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Properties
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether general form workflow errors are presented.
***REMOVED***var alertIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***guard case .generalError = self.state else { return false ***REMOVED***
***REMOVED******REMOVED******REMOVED***return true
***REMOVED*** set: { newIsErrorShowing in
***REMOVED******REMOVED******REMOVED***if !newIsErrorShowing {
***REMOVED******REMOVED******REMOVED******REMOVED***guard case let .generalError(featureForm, _) = self.state else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***self.state = .editing(featureForm)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the alert confirming the user's intent to cancel is presented.
***REMOVED***var cancelConfirmationIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***guard case .cancellationPending = self.state else { return false ***REMOVED***
***REMOVED******REMOVED******REMOVED***return true
***REMOVED*** set: { _ in
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current feature form, derived from ``Model/state-swift.property``.
***REMOVED***var featureForm: FeatureForm? {
***REMOVED******REMOVED***switch state {
***REMOVED******REMOVED***case .idle:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***case
***REMOVED******REMOVED******REMOVED***let .editing(form), let .validating(form),
***REMOVED******REMOVED******REMOVED***let .finishingEdits(form), let .applyingEdits(form),
***REMOVED******REMOVED******REMOVED***let .cancellationPending(form), let .generalError(form, _):
***REMOVED******REMOVED******REMOVED***return form
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether external form controls like "Cancel" and "Submit" should be disabled.
***REMOVED***var formControlsAreDisabled: Bool {
***REMOVED******REMOVED***guard case .editing = state else { return true ***REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the form is displayed.
***REMOVED***var formIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***guard case .idle = self.state else { return true ***REMOVED***
***REMOVED******REMOVED******REMOVED***return false
***REMOVED*** set: { _ in
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ User facing text indicating the current form workflow state.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This is most useful during post form processing to indicate ongoing background work.
***REMOVED***var textForState: Text {
***REMOVED******REMOVED***switch state {
***REMOVED******REMOVED***case .validating:
***REMOVED******REMOVED******REMOVED***Text("Validating")
***REMOVED******REMOVED***case .finishingEdits:
***REMOVED******REMOVED******REMOVED***Text("Finishing edits")
***REMOVED******REMOVED***case .applyingEdits:
***REMOVED******REMOVED******REMOVED***Text("Applying edits")
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***Text("")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Methods
***REMOVED***
***REMOVED******REMOVED***/ Reverts any local edits that haven't yet been saved to service geodatabase.
***REMOVED***func discardEdits() {
***REMOVED******REMOVED***guard case let .cancellationPending(featureForm) = state else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***featureForm.discardEdits()
***REMOVED******REMOVED***state = .idle
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Submit the changes made to the form.
***REMOVED***func submitEdits() async {
***REMOVED******REMOVED***guard case let .editing(featureForm) = state else { return ***REMOVED***
***REMOVED******REMOVED***await validateChanges(featureForm)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case let .validating(featureForm) = state else { return ***REMOVED***
***REMOVED******REMOVED***await finishEditing(featureForm)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case let .finishingEdits(featureForm) = state else { return ***REMOVED***
***REMOVED******REMOVED***await applyEdits(featureForm)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Private methods
***REMOVED***
***REMOVED******REMOVED***/ Apply edits to the service.
***REMOVED***private func applyEdits(_ featureForm: FeatureForm) async {
***REMOVED******REMOVED***state = .applyingEdits(featureForm)
***REMOVED******REMOVED***guard let table = featureForm.feature.table as? ServiceFeatureTable else {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("Error resolving feature table."))
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard let database = table.serviceGeodatabase else {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("No geodatabase found."))
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard database.hasLocalEdits else {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("No database edits found."))
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***let resultErrors: [Error]
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***if let serviceInfo = database.serviceInfo, serviceInfo.canUseServiceGeodatabaseApplyEdits {
***REMOVED******REMOVED******REMOVED******REMOVED***let featureTableEditResults = try await database.applyEdits()
***REMOVED******REMOVED******REMOVED******REMOVED***resultErrors = featureTableEditResults.flatMap { $0.editResults.errors ***REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***let featureEditResults = try await table.applyEdits()
***REMOVED******REMOVED******REMOVED******REMOVED***resultErrors = featureEditResults.errors
***REMOVED******REMOVED***
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("The changes could not be applied to the database or table.\n\n\(error.localizedDescription)"))
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***if resultErrors.isEmpty {
***REMOVED******REMOVED******REMOVED***state = .idle
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED*** Additionally, you could display the errors to the user using `resultErrors`.
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("Changes were not applied."))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Commits changes to the features and its attachments to the database.
***REMOVED***private func finishEditing(_ featureForm: FeatureForm) async {
***REMOVED******REMOVED***state = .finishingEdits(featureForm)
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await featureForm.finishEditing()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text(error.localizedDescription))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Checks the feature form for the presence of any validation errors.
***REMOVED***private func validateChanges(_ featureForm: FeatureForm) async {
***REMOVED******REMOVED***state = .validating(featureForm)
***REMOVED******REMOVED***if !featureForm.validationErrors.isEmpty {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true)."))
***REMOVED***
***REMOVED***
***REMOVED***

private extension FeatureForm {
***REMOVED******REMOVED***/ The layer to which the feature belongs.
***REMOVED***var featureLayer: FeatureLayer? {
***REMOVED******REMOVED***feature.table?.layer as? FeatureLayer
***REMOVED***
***REMOVED***

private extension Array where Element == FeatureEditResult {
***REMOVED******REMOVED***/ Examines all feature edit results (and their inner attachment results) for any errors.
***REMOVED***var errors: [Error] {
***REMOVED******REMOVED***var errors = [Error]()
***REMOVED******REMOVED***forEach { featureEditResult in
***REMOVED******REMOVED******REMOVED***if let editResultError = featureEditResult.error { errors.append(editResultError) ***REMOVED***
***REMOVED******REMOVED******REMOVED***featureEditResult.attachmentResults.forEach { attachmentResult in
***REMOVED******REMOVED******REMOVED******REMOVED***if let error = attachmentResult.error {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***errors.append(error)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***return errors
***REMOVED***
***REMOVED***
