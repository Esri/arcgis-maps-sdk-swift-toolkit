***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct FormViewExampleView: View {
***REMOVED******REMOVED***/ The height to present the form at.
***REMOVED***@State private var detent: FloatingPanelDetent = .full
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = Map(url: .sampleData)!
***REMOVED***
***REMOVED******REMOVED***/ The point on the screen the user tapped on to identify a feature.
***REMOVED***@State private var identifyScreenPoint: CGPoint?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the alert confirming the user's intent to cancel is displayed.
***REMOVED***@State private var isCancelConfirmationPresented = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the form is displayed.
***REMOVED***@State private var isPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The form view model provides a channel of communication between the form view and its host.
***REMOVED***@StateObject private var formViewModel = FormViewModel()
***REMOVED***
***REMOVED******REMOVED***/ The form being edited in the form view.
***REMOVED***@State private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The height of the map view's attribution bar.
***REMOVED***@State private var attributionBarHeight: CGFloat = 0
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAttributionBarHeightChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight = $0
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isCancelConfirmationPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = await identifyFeature(with: mapViewProxy),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let featureForm = FeatureForm(feature: feature, definition: formDefinition) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formViewModel.startEditing(feature, featureForm: featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = featureForm != nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $detent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FormView(featureForm: featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal])
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.alert("Cancel editing?", isPresented: $isCancelConfirmationPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel editing", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formViewModel.undoEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Continue editing", role: .cancel) { ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(formViewModel)
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden(isPresented)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Once iOS 16.0 is the minimum supported, the two conditionals to show the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** buttons can be merged and hoisted up as the root content of the toolbar.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formViewModel.undoEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Submit") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await formViewModel.submitChanges()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension FormViewExampleView {
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
***REMOVED******REMOVED***.init(string: "<#URL#>")!
***REMOVED***
***REMOVED***
