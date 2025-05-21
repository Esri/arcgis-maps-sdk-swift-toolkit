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
***REMOVED******REMOVED***/ The error to be presented in the alert.
***REMOVED***@State private var alertError: String?
***REMOVED***
***REMOVED******REMOVED***/ The height of the map view's attribution bar.
***REMOVED***@State private var attributionBarHeight: CGFloat = 0
***REMOVED***
***REMOVED******REMOVED***/ The height to present the form at.
***REMOVED***@State private var detent: FloatingPanelDetent = .full
***REMOVED***
***REMOVED******REMOVED***/ Tables with local edits that need to be applied.
***REMOVED***@State private var editedTables = [ServiceFeatureTable]()
***REMOVED***
***REMOVED******REMOVED***/ The presented feature form.
***REMOVED***@State private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The point on the screen the user tapped on to identify a feature.
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether edits are being applied.
***REMOVED***@State private var isApplyingEdits = false
***REMOVED***
***REMOVED******REMOVED***/ The visibility of the submit button.
***REMOVED***@State private var submitButtonVisibility = Visibility.hidden
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = Map(url: .sampleData)!
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAttributionBarHeightChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight = $0
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = await identifyFeature(with: mapViewProxy) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm = FeatureForm(feature: feature)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $detent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: featureFormViewIsPresented
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FeatureFormView(featureForm: $featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.closeButton(.visible) ***REMOVED*** Defaults to .automatic
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onFormEditingEvent { editingEvent in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if case .savedEdits = editingEvent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let table = featureForm?.feature.table as? ServiceFeatureTable,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   !editedTables.contains(where: { $0 === table ***REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***editedTables.append(table)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateSubmitButtonVisibility()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.alert("Error", isPresented: alertIsPresented) {
***REMOVED******REMOVED******REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let error = alertError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(error)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isApplyingEdits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack(spacing: 5) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.circular)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Applying edits")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(.thinMaterial)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 10))
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if submitButtonVisibility != .hidden {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Submit") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await applyEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension FeatureFormExampleView {
***REMOVED******REMOVED*** MARK: Methods
***REMOVED***
***REMOVED******REMOVED***/ Applies edits to the remote service.
***REMOVED***private func applyEdits() async {
***REMOVED******REMOVED***isApplyingEdits = true
***REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED***isApplyingEdits = false
***REMOVED******REMOVED******REMOVED***updateSubmitButtonVisibility()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***for table in editedTables {
***REMOVED******REMOVED******REMOVED***guard let database = table.serviceGeodatabase else {
***REMOVED******REMOVED******REMOVED******REMOVED***alertError = "No geodatabase found."
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard database.hasLocalEdits else {
***REMOVED******REMOVED******REMOVED******REMOVED***alertError = "No database edits found."
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let resultErrors: [Error]
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***if let serviceInfo = database.serviceInfo, serviceInfo.canUseServiceGeodatabaseApplyEdits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let featureTableEditResults = try await database.applyEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resultErrors = featureTableEditResults.flatMap(\.editResults.errors)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let featureEditResults = try await table.applyEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resultErrors = featureEditResults.errors
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***alertError = "The changes could not be applied to the database or table.\n\n\(error.localizedDescription)"
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if !resultErrors.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***alertError = "Apply edits failed with ^[\(resultErrors.count) error](inflect: true)."
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***editedTables.removeAll { $0.tableName == table.tableName ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Identifies features, if any, at the current screen point.
***REMOVED******REMOVED***/ - Parameter proxy: The proxy to use for identification.
***REMOVED******REMOVED***/ - Returns: The first identified feature in a layer.
***REMOVED***private func identifyFeature(with proxy: MapViewProxy) async -> ArcGISFeature? {
***REMOVED******REMOVED***guard let identifyScreenPoint else { return nil ***REMOVED***
***REMOVED******REMOVED***let identifyLayerResults = try? await proxy.identifyLayers(
***REMOVED******REMOVED******REMOVED***screenPoint: identifyScreenPoint,
***REMOVED******REMOVED******REMOVED***tolerance: 10
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return identifyLayerResults?.compactMap { result in
***REMOVED******REMOVED******REMOVED***result.geoElements.compactMap { element in
***REMOVED******REMOVED******REMOVED******REMOVED***element as? ArcGISFeature
***REMOVED******REMOVED***.first
***REMOVED***.first
***REMOVED***
***REMOVED***
***REMOVED***private func updateSubmitButtonVisibility() {
***REMOVED******REMOVED***guard featureForm == nil || !(featureForm?.hasEdits ?? false) else {
***REMOVED******REMOVED******REMOVED***submitButtonVisibility = .hidden
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***let databases = editedTables.compactMap(\.serviceGeodatabase)
***REMOVED******REMOVED***if databases.contains(where: \.hasLocalEdits) {
***REMOVED******REMOVED******REMOVED***submitButtonVisibility = .visible
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***submitButtonVisibility = .hidden
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Properties
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether general form workflow errors are presented.
***REMOVED***private var alertIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***self.alertError != nil
***REMOVED*** set: { newAlertIsPresented in
***REMOVED******REMOVED******REMOVED***if !newAlertIsPresented {
***REMOVED******REMOVED******REMOVED******REMOVED***self.alertError = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the form is presented.
***REMOVED***private var featureFormViewIsPresented: Binding<Bool> {
***REMOVED******REMOVED***.init {
***REMOVED******REMOVED******REMOVED***featureForm != nil
***REMOVED*** set: { newValue in
***REMOVED******REMOVED******REMOVED***if !newValue {
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension Array where Element == FeatureEditResult {
***REMOVED******REMOVED***/  Any errors from the edit results and their inner attachment results.
***REMOVED***var errors: [Error] {
***REMOVED******REMOVED***compactMap(\.error) + flatMap { $0.attachmentResults.compactMap(\.error) ***REMOVED***
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED***static var sampleData: Self {
***REMOVED******REMOVED***.init(string: "https:***REMOVED***www.arcgis.com/apps/mapviewer/index.html?webmap=f72207ac170a40d8992b7a3507b44fad")!
***REMOVED***
***REMOVED***
