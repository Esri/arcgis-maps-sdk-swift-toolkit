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

struct FormViewTestView: View {
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map: Map?
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
***REMOVED******REMOVED***/ The current test case.
***REMOVED***@State private var testCase: TestCase?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if let map, let testCase {
***REMOVED******REMOVED******REMOVED***makeMapView(map, testCase)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***testCaseSelector
***REMOVED***
***REMOVED***
***REMOVED***

private extension FormViewTestView {
***REMOVED******REMOVED***/ Make the main test UI.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - map: The map under test.
***REMOVED******REMOVED***/   - testCase: The test definition.
***REMOVED***func makeMapView(_ map: Map, _ testCase: TestCase) -> some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***try? await map.load()
***REMOVED******REMOVED******REMOVED******REMOVED***let featureLayer = map.operationalLayers.first as? FeatureLayer
***REMOVED******REMOVED******REMOVED******REMOVED***let parameters = QueryParameters()
***REMOVED******REMOVED******REMOVED******REMOVED***parameters.addObjectID(testCase.objectID)
***REMOVED******REMOVED******REMOVED******REMOVED***let result = try? await featureLayer?.featureTable?.queryFeatures(using: parameters)
***REMOVED******REMOVED******REMOVED******REMOVED***guard let feature = result?.features().makeIterator().next() as? ArcGISFeature else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***try? await feature.load()
***REMOVED******REMOVED******REMOVED******REMOVED***guard let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm = FeatureForm(feature: feature, definition: formDefinition)
***REMOVED******REMOVED******REMOVED******REMOVED***formViewModel.startEditing(feature, featureForm: featureForm!)
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: .constant(.full),
***REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***FormView(featureForm: featureForm)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.environmentObject(formViewModel)
***REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden(isPresented)
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Once iOS 16.0 is the minimum supported, the two conditionals to show the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** buttons can be merged and hoisted up as the root content of the toolbar.
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isPresented && !useControlsInForm {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formViewModel.undoEdits()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isPresented && !useControlsInForm {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Submit") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await formViewModel.submitChanges()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case selection UI.
***REMOVED***var testCaseSelector: some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***ForEach(cases) { testCase in
***REMOVED******REMOVED******REMOVED******REMOVED***Button(testCase.id) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.testCase = testCase
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map = Map(url: .init(string: testCase.url)!)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the form controls should be shown directly in the form's
***REMOVED******REMOVED***/  presenting container.
***REMOVED***var useControlsInForm: Bool {
***REMOVED******REMOVED***verticalSizeClass == .compact ||
***REMOVED******REMOVED***UIDevice.current.userInterfaceIdiom == .mac ||
***REMOVED******REMOVED***UIDevice.current.userInterfaceIdiom == .pad
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test conditions for a Form View.
***REMOVED***struct TestCase: Identifiable {
***REMOVED******REMOVED******REMOVED***/ The name of the test case.
***REMOVED******REMOVED***let id: String
***REMOVED******REMOVED******REMOVED***/ The object ID of the feature being tested.
***REMOVED******REMOVED***let objectID: Int
***REMOVED******REMOVED******REMOVED***/ The test data location.
***REMOVED******REMOVED***let url: String
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes a URL a for test data.
***REMOVED******REMOVED***/ - Parameter id: A portal item ID.
***REMOVED******REMOVED***/ - Returns: A URL for Form View test data with the given portal item ID.
***REMOVED***func makeURL(for id: String) -> String {
***REMOVED******REMOVED***String("https:***REMOVED***\(String.formViewTestDataDomain!)/home/item.html?id=\(id)")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The set of all Form View UI test cases.
***REMOVED***var cases: [TestCase] {[
***REMOVED******REMOVED***.init(id: "testCase_1_1", objectID: 1, url: makeURL(for: String.formViewTestDataCase_1_x!)),
***REMOVED******REMOVED***.init(id: "testCase_1_2", objectID: 1, url: makeURL(for: String.formViewTestDataCase_1_x!)),
***REMOVED******REMOVED***.init(id: "testCase_1_3", objectID: 1, url: makeURL(for: String.formViewTestDataCase_1_x!)),
***REMOVED******REMOVED***.init(id: "testCase_1_4", objectID: 1, url: makeURL(for: String.formViewTestDataCase_1_4!)),
***REMOVED******REMOVED***.init(id: "testCase_2_1", objectID: 1, url: makeURL(for: String.formViewTestDataCase_2_x!)),
***REMOVED******REMOVED***.init(id: "testCase_2_1", objectID: 1, url: makeURL(for: String.formViewTestDataCase_2_x!)),
***REMOVED******REMOVED***.init(id: "testCase_2_2", objectID: 1, url: makeURL(for: String.formViewTestDataCase_2_x!)),
***REMOVED******REMOVED***.init(id: "testCase_2_3", objectID: 1, url: makeURL(for: String.formViewTestDataCase_2_x!)),
***REMOVED******REMOVED***.init(id: "testCase_2_4", objectID: 1, url: makeURL(for: String.formViewTestDataCase_2_x!)),
***REMOVED******REMOVED***.init(id: "testCase_2_5", objectID: 1, url: makeURL(for: String.formViewTestDataCase_2_x!)),
***REMOVED******REMOVED***.init(id: "testCase_2_6", objectID: 1, url: makeURL(for: String.formViewTestDataCase_2_x!)),
***REMOVED******REMOVED***.init(id: "testCase_3_1", objectID: 2, url: makeURL(for: String.formViewTestDataCase_3_x!)),
***REMOVED******REMOVED***.init(id: "testCase_3_2", objectID: 2, url: makeURL(for: String.formViewTestDataCase_3_x!)),
***REMOVED******REMOVED***.init(id: "testCase_3_3", objectID: 2, url: makeURL(for: String.formViewTestDataCase_3_x!)),
***REMOVED******REMOVED***.init(id: "testCase_3_4", objectID: 2, url: makeURL(for: String.formViewTestDataCase_3_x!)),
***REMOVED******REMOVED***.init(id: "testCase_3_5", objectID: 2, url: makeURL(for: String.formViewTestDataCase_3_x!)),
***REMOVED******REMOVED***.init(id: "testCase_3_6", objectID: 2, url: makeURL(for: String.formViewTestDataCase_3_x!)),
***REMOVED******REMOVED***.init(id: "testCase_4_1", objectID: 1, url: makeURL(for: String.formViewTestDataCase_4_x!)),
***REMOVED******REMOVED***.init(id: "testCase_5_1", objectID: 1, url: makeURL(for: String.formViewTestDataCase_5_x!)),
***REMOVED******REMOVED***.init(id: "testCase_5_2", objectID: 1, url: makeURL(for: String.formViewTestDataCase_5_x!)),
***REMOVED******REMOVED***.init(id: "testCase_5_3", objectID: 1, url: makeURL(for: String.formViewTestDataCase_5_x!)),
***REMOVED***]***REMOVED***
***REMOVED***
