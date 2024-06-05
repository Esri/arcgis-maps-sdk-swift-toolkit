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
***REMOVED***@State private var detent: FloatingPanelDetent = .full
***REMOVED***
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED***@State private var validationErrorVisibility = FeatureFormView.ValidationErrorVisibility.automatic
***REMOVED***
***REMOVED***@StateObject private var model = Model()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch model.state {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .idle:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let .editing(featureForm):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.state = .cancellationPending(featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = await identifyFeature(with: mapViewProxy),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.state = .editing(FeatureForm(feature: feature, definition: formDefinition))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $detent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: model.formIsPresented
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let featureForm = model.featureForm {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FeatureFormView(featureForm: featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.validationErrors(validationErrorVisibility)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.top, 16)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: model.formIsPresented.wrappedValue) { formIsPresented in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !formIsPresented { validationErrorVisibility = .automatic ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.alert("Discard edits", isPresented: model.cancelConfirmationIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Discard edits", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.discardEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if case let .cancellationPending(featureForm) = model.state {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Continue editing", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.state = .editing(featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Updates to this feature will be lost.")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"The form wasn't submitted",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: model.alertIsPresented
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) { ***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if case let .generalError(_, errorMessage) = model.state {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***errorMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden(model.formIsPresented.wrappedValue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if model.formIsPresented.wrappedValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard case let .editing(featureForm) = model.state else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.state = .cancellationPending(featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(model.formControlsAreDisabled)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Submit") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***validationErrorVisibility = .visible
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await model.submitEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(model.formControlsAreDisabled)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension FeatureFormExampleView {
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

@MainActor
class Model: ObservableObject {
***REMOVED***enum State {
***REMOVED******REMOVED***case applyingEdits(FeatureForm)
***REMOVED******REMOVED***case cancellationPending(FeatureForm)
***REMOVED******REMOVED***case editing(FeatureForm)
***REMOVED******REMOVED***case finishingEdits(FeatureForm)
***REMOVED******REMOVED***case generalError(FeatureForm, Text)
***REMOVED******REMOVED***case idle
***REMOVED******REMOVED***case validating(FeatureForm)
***REMOVED***
***REMOVED***
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
***REMOVED***var cancelConfirmationIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***guard case .cancellationPending = self.state else { return false ***REMOVED***
***REMOVED******REMOVED******REMOVED***return true
***REMOVED*** set: { _ in
***REMOVED***
***REMOVED***
***REMOVED***
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
***REMOVED***var formControlsAreDisabled: Bool {
***REMOVED******REMOVED***guard case .editing = state else { return true ***REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED***var formIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***guard case .idle = self.state else { return true ***REMOVED***
***REMOVED******REMOVED******REMOVED***return false
***REMOVED*** set: { _ in
***REMOVED***
***REMOVED***
***REMOVED***
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
***REMOVED***func discardEdits() {
***REMOVED******REMOVED***guard case let .cancellationPending(featureForm) = state else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***featureForm.discardEdits()
***REMOVED******REMOVED***state = .idle
***REMOVED***
***REMOVED***
***REMOVED***func submitEdits() async {
***REMOVED******REMOVED***guard case let .editing(featureForm) = state else { return ***REMOVED***
***REMOVED******REMOVED***await validateChanges(featureForm)
***REMOVED***
***REMOVED***
***REMOVED***private func applyEdits(_ featureForm: FeatureForm, _ table: ServiceFeatureTable) async {
***REMOVED******REMOVED***state = .applyingEdits(featureForm)
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
***REMOVED******REMOVED******REMOVED******REMOVED***resultErrors = featureTableEditResults.flatMap { featureTableEditResult in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***checkFeatureEditResults(featureForm, featureTableEditResult.editResults)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***let featureEditResults = try await table.applyEdits()
***REMOVED******REMOVED******REMOVED******REMOVED***resultErrors = checkFeatureEditResults(featureForm, featureEditResults)
***REMOVED******REMOVED***
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("The changes could not be applied to the database or table.\n\n\(error.localizedDescription)"))
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***if resultErrors.isEmpty {
***REMOVED******REMOVED******REMOVED***state = .idle
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("Changes were not applied."))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func checkFeatureEditResults(_ featureForm: FeatureForm, _ featureEditResults: [FeatureEditResult]) -> [Error] {
***REMOVED******REMOVED***var errors = [Error]()
***REMOVED******REMOVED***featureEditResults.forEach { featureEditResult in
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
***REMOVED***private func finishEdits(_ featureForm: FeatureForm) async {
***REMOVED******REMOVED***state = .finishingEdits(featureForm)
***REMOVED******REMOVED***guard let table = featureForm.feature.table as? ServiceFeatureTable else {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("Error resolving feature table."))
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard table.isEditable else {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("The feature table isn't editable."))
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***state = .finishingEdits(featureForm)
***REMOVED******REMOVED******REMOVED***try await table.update(featureForm.feature)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("The feature update failed."))
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***await applyEdits(featureForm, table)
***REMOVED***
***REMOVED***
***REMOVED***private func validateChanges(_ featureForm: FeatureForm) async {
***REMOVED******REMOVED***state = .validating(featureForm)
***REMOVED******REMOVED***guard featureForm.validationErrors.isEmpty else {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true)."))
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***await finishEdits(featureForm)
***REMOVED***
***REMOVED***

private extension FeatureForm {
***REMOVED***var featureLayer: FeatureLayer? {
***REMOVED******REMOVED***feature.table?.layer as? FeatureLayer
***REMOVED***
***REMOVED***
