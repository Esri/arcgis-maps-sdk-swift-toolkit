***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct FeatureFormExampleView: View {
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID("f72207ac170a40d8992b7a3507b44fad")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***
***REMOVED***@State private var cancelConfirmationIsPresented = false
***REMOVED***
***REMOVED***@State private var featureForm: FeatureForm? {
***REMOVED******REMOVED***didSet { featureFormIsPresented = featureForm != nil ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@State private var featureFormIsPresented = false
***REMOVED***
***REMOVED***@State private var floatingPanelDetent: FloatingPanelDetent = .full
***REMOVED***
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED***@State private var submissionError: Text?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let identifyScreenPoint else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let identifyResult = try? await proxy.identifyLayers(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***screenPoint: identifyScreenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tolerance: 10
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.first(where: { result in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = result.geoElements.first as? ArcGISFeature,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   (feature.table?.layer as? FeatureLayer)?.featureFormDefinition != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = identifyResult?.geoElements.first as? ArcGISFeature,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm = FeatureForm(feature: feature, definition: formDefinition)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $floatingPanelDetent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $featureFormIsPresented
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let featureForm {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FeatureFormView(featureForm: featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal])
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.alert("Discard edits", isPresented: $cancelConfirmationIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Discard edits", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm?.discardEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm = nil
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Continue editing", role: .cancel) { ***REMOVED***
***REMOVED******REMOVED******REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Updates to this feature will be lost.")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"The form wasn't submitted",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { submissionError != nil ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { _ in submissionError = nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) { ***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let submissionError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***submissionError
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if featureFormIsPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cancelConfirmationIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if featureFormIsPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Submit") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await submitChanges()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
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
***REMOVED******REMOVED******REMOVED*** Don't submit if there are validation errors.
***REMOVED******REMOVED***guard featureForm.validationErrors.isEmpty else {
***REMOVED******REMOVED******REMOVED***submissionError = Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true).")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Update the service feature table
***REMOVED******REMOVED***try? await table.update(featureForm.feature)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard database.hasLocalEdits else {
***REMOVED******REMOVED******REMOVED***print("No submittable changes found.")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Apply the changes.
***REMOVED******REMOVED***let results = try? await database.applyEdits()
***REMOVED******REMOVED***
***REMOVED******REMOVED***if results?.first?.editResults.first?.didCompleteWithErrors ?? false {
***REMOVED******REMOVED******REMOVED***print("An error occurred while submitting the changes.")
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Clear the feature form
***REMOVED******REMOVED***self.featureForm = nil
***REMOVED***
***REMOVED***
