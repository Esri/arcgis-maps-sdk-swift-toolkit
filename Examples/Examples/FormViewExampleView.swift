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
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = Map(url: .sampleData)!
***REMOVED***
***REMOVED******REMOVED***/ The point on the screen the user tapped on to identify a feature.
***REMOVED***@State private var identifyScreenPoint: CGPoint?
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
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identifyScreenPoint = screenPoint
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.task(id: identifyScreenPoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = await identifyFeature(with: mapViewProxy),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm = FeatureForm(feature: feature, definition: formDefinition)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formViewModel.startEditing(feature)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = featureForm != nil
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: .constant(.half),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FormView(featureForm: featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(formViewModel)
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden(isPresented)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Once iOS 16.0 is the minimum supported, the two conditionals to show the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** buttons can be merged and hoisted up as the root content of the toolbar.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formViewModel.undoEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED***/ - Returns: The first identified feature.
***REMOVED***func identifyFeature(with proxy: MapViewProxy) async -> ArcGISFeature? {
***REMOVED******REMOVED***if let screenPoint = identifyScreenPoint,
***REMOVED******REMOVED***   let feature = try? await Result(awaiting: {
***REMOVED******REMOVED******REMOVED***   try await proxy.identify(
***REMOVED******REMOVED******REMOVED******REMOVED***on: map.operationalLayers.first!,
***REMOVED******REMOVED******REMOVED******REMOVED***screenPoint: screenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***tolerance: 10
***REMOVED******REMOVED******REMOVED***   )
   ***REMOVED***)
***REMOVED******REMOVED******REMOVED***.cancellationToNil()?
***REMOVED******REMOVED******REMOVED***.get()
***REMOVED******REMOVED******REMOVED***.geoElements
***REMOVED******REMOVED******REMOVED***.first as? ArcGISFeature {
***REMOVED******REMOVED******REMOVED***return feature
***REMOVED***
***REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED***static var sampleData: Self {
***REMOVED******REMOVED******REMOVED*** David
***REMOVED******REMOVED******REMOVED***.init(string: <#URL#>)!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Wind turbines
***REMOVED******REMOVED******REMOVED***/ on: map.operationalLayers.first(where: { $0.name == "windturbine" ***REMOVED***)!,
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=f4cdb74cb4164d68b6b48ca2d4d02dba")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Dates
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/home/item.html?id=ec09090060664cbda8d814e017337837")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** 0
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/home/item.html?id=df0f27f83eee41b0afe4b6216f80b541")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Form validation
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/home/item.html?id=5d69e2301ad14ec8a73b568dfc29450a")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Water lines
***REMOVED******REMOVED******REMOVED***/ on: map.operationalLayers.first(where: { $0.name == "CityworksDynamic - Water Hydrants" ***REMOVED***)!,
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/home/item.html?id=0f6864ddc35241649e5ad2ee61a3abe4")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** 1
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/home/item.html?id=454422bdf7e24fb0ba4ffe0a22f6bf37")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** 2
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=c606b1f345044d71881f99d00583f8f7")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** 3
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=622c4674d6f64114a1de2e0b8382fcf3")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** 4
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=a81d90609e4549479d1f214f28335af2")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** 5
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/home/item.html?id=bb4c5e81740e4e7296943988c78a7ea6")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Text and Date Time form element sanity
***REMOVED******REMOVED******REMOVED***/ Uses publisher1 credentials
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***rt-server11.esri.com/portal/apps/mapviewer/index.html?webmap=b6fd63002fcb4ec2b04029440f24d43c")!
***REMOVED******REMOVED***
***REMOVED******REMOVED*** Combo Box
***REMOVED******REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=ed930cf0eb724ea49c6bccd8fd3dd9af")!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Radio Button
***REMOVED******REMOVED***.init(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/apps/mapviewer/index.html?webmap=476e9b4180234961809485c8eff83d5d")!
***REMOVED***
***REMOVED***
