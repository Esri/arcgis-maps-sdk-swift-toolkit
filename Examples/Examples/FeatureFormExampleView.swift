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
***REMOVED******REMOVED***/ A Boolean value indicating whether the alert confirming the user's intent to cancel is presented.
***REMOVED***@State private var cancelConfirmationIsPresented = false
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if model.isFormPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cancelConfirmationIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = await identifyFeature(with: mapViewProxy),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.featureForm = FeatureForm(feature: feature, definition: formDefinition)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $detent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $model.isFormPresented
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let featureForm = model.featureForm {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FeatureFormView(featureForm: featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.validationErrors(validationErrorVisibility)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.top, 16)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: model.isFormPresented) { isFormPresented in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !isFormPresented { validationErrorVisibility = .automatic ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.alert("Discard edits", isPresented: $cancelConfirmationIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Discard edits", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.discardEdits()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Continue editing", role: .cancel) { ***REMOVED***
***REMOVED******REMOVED******REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Updates to this feature will be lost.")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"The form wasn't submitted",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { model.submissionError != nil ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { _ in model.submissionError = nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) { ***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let submissionError = model.submissionError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***submissionError
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden(model.isFormPresented)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if model.isFormPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cancelConfirmationIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Submit") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***validationErrorVisibility = .visible
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await model.submitChanges()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED***/ The feature form.
***REMOVED***@Published var featureForm: FeatureForm? {
***REMOVED******REMOVED***willSet {
***REMOVED******REMOVED******REMOVED***if let featureForm = newValue {
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm.featureLayer?.selectFeature(featureForm.feature)
***REMOVED******REMOVED*** else if let featureForm = self.featureForm {
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm.featureLayer?.unselectFeature(featureForm.feature)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***isFormPresented = featureForm != nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the form is displayed.
***REMOVED***@Published var isFormPresented = false
***REMOVED***
***REMOVED******REMOVED***/ A description of the error that prevented the form from being submitted.
***REMOVED***@Published var submissionError: Text?
***REMOVED***
***REMOVED******REMOVED***/ Reverts any local edits that haven't yet been saved to service geodatabase.
***REMOVED***func discardEdits() {
***REMOVED******REMOVED***featureForm?.discardEdits()
***REMOVED******REMOVED***featureForm = nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Submit the changes made to the form.
***REMOVED***func submitChanges() async {
***REMOVED******REMOVED***guard let featureForm,
***REMOVED******REMOVED******REMOVED***  let table = featureForm.feature.table as? ServiceFeatureTable,
***REMOVED******REMOVED******REMOVED***  let database = table.serviceGeodatabase else {
***REMOVED******REMOVED******REMOVED***print("A precondition to submit the changes wasn't met.")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard table.isEditable else {
***REMOVED******REMOVED******REMOVED***submissionError = Text("The feature table isn't editable.")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard featureForm.validationErrors.isEmpty else {
***REMOVED******REMOVED******REMOVED***submissionError = Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true).")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***try? await table.update(featureForm.feature)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard database.hasLocalEdits else {
***REMOVED******REMOVED******REMOVED***print("No submittable changes found.")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try? await database.applyEdits()
***REMOVED******REMOVED***
***REMOVED******REMOVED***if results?.first?.editResults.first?.didCompleteWithErrors ?? false {
***REMOVED******REMOVED******REMOVED***print("An error occurred while submitting the changes.")
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.featureForm = nil
***REMOVED***
***REMOVED***

private extension FeatureForm {
***REMOVED******REMOVED***/ The layer to which the feature belongs.
***REMOVED***var featureLayer: FeatureLayer? {
***REMOVED******REMOVED***feature.table?.layer as? FeatureLayer
***REMOVED***
***REMOVED***
