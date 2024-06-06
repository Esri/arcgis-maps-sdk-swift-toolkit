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
***REMOVED******REMOVED***validateChanges(featureForm)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case let .validating(featureForm) = state else { return ***REMOVED***
***REMOVED******REMOVED***await finishEditing(featureForm)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard case let .finishingEdits(featureForm) = state else { return ***REMOVED***
***REMOVED******REMOVED***await applyEdits(featureForm)
***REMOVED***
***REMOVED***

private extension FeatureForm {
***REMOVED***var featureLayer: FeatureLayer? {
***REMOVED******REMOVED***feature.table?.layer as? FeatureLayer
***REMOVED***
***REMOVED***
