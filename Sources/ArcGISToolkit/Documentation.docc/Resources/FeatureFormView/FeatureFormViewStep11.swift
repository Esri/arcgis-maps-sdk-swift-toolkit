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
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED***@StateObject private var model = Model()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***MapView(map: map)
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
***REMOVED******REMOVED******REMOVED******REMOVED***   feature.featureFormDefinition != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return identifyResult?.geoElements.first as? ArcGISFeature
***REMOVED***
***REMOVED***

@MainActor
private class Model: ObservableObject {
***REMOVED***enum State {
***REMOVED******REMOVED***case applyingEdits(FeatureForm)
***REMOVED******REMOVED***case cancellationPending(FeatureForm)
***REMOVED******REMOVED***case editing(FeatureForm)
***REMOVED******REMOVED***case finishingEdits(FeatureForm)
***REMOVED******REMOVED***case generalError(FeatureForm, Text)
***REMOVED******REMOVED***case idle
***REMOVED******REMOVED***case validating(FeatureForm)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var label: String {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .applyingEdits:
***REMOVED******REMOVED******REMOVED******REMOVED***"Applying Edits"
***REMOVED******REMOVED******REMOVED***case .cancellationPending:
***REMOVED******REMOVED******REMOVED******REMOVED***"Cancellation Pending"
***REMOVED******REMOVED******REMOVED***case .editing:
***REMOVED******REMOVED******REMOVED******REMOVED***"Editing"
***REMOVED******REMOVED******REMOVED***case .finishingEdits:
***REMOVED******REMOVED******REMOVED******REMOVED***"Finishing Edits"
***REMOVED******REMOVED******REMOVED***case .generalError:
***REMOVED******REMOVED******REMOVED******REMOVED***"Error"
***REMOVED******REMOVED******REMOVED***case .idle:
***REMOVED******REMOVED******REMOVED******REMOVED***""
***REMOVED******REMOVED******REMOVED***case .validating:
***REMOVED******REMOVED******REMOVED******REMOVED***"Validating"
***REMOVED******REMOVED***
***REMOVED***
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
***REMOVED******REMOVED***validateChanges(featureForm)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case let .validating(featureForm) = state else { return ***REMOVED***
***REMOVED******REMOVED***await finishEditing(featureForm)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case let .finishingEdits(featureForm) = state else { return ***REMOVED***
***REMOVED******REMOVED***await applyEdits(featureForm)
***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED***resultErrors = featureTableEditResults.flatMap(\.editResults.errors)
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
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("Apply edits failed with ^[\(resultErrors.count) error](inflect: true)."))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func finishEditing(_ featureForm: FeatureForm) async {
***REMOVED******REMOVED***state = .finishingEdits(featureForm)
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await featureForm.finishEditing()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("Finish editing failed.\n\n\(error.localizedDescription)"))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func validateChanges(_ featureForm: FeatureForm) {
***REMOVED******REMOVED***state = .validating(featureForm)
***REMOVED******REMOVED***if !featureForm.validationErrors.isEmpty {
***REMOVED******REMOVED******REMOVED***state = .generalError(featureForm, Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true)."))
***REMOVED***
***REMOVED***
***REMOVED***

private extension FeatureForm {
***REMOVED***var featureLayer: FeatureLayer? {
***REMOVED******REMOVED***feature.table?.layer as? FeatureLayer
***REMOVED***
***REMOVED***

private extension Array where Element == FeatureEditResult {
***REMOVED******REMOVED***/  Any errors from the edit results and their inner attachment results.
***REMOVED***var errors: [Error] {
***REMOVED******REMOVED***compactMap(\.error) + flatMap { $0.attachmentResults.compactMap(\.error) ***REMOVED***
***REMOVED***
***REMOVED***
