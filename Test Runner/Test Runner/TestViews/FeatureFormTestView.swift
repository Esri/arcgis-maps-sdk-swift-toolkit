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

struct FeatureFormTestView: View {
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ The height of the map view's attribution bar.
***REMOVED***@State private var attributionBarHeight: CGFloat = 0
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map: Map?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the form is displayed.
***REMOVED***@State private var isPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The form being edited in the form view.
***REMOVED***@State private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The current test case.
***REMOVED***@State private var testCase: TestCase?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if let map, let testCase {
***REMOVED******REMOVED******REMOVED******REMOVED***makeMapView(map, testCase)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***testCaseSelector
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension FeatureFormTestView {
***REMOVED******REMOVED***/ Make the main test UI.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - map: The map under test.
***REMOVED******REMOVED***/   - testCase: The test definition.
***REMOVED***@MainActor func makeMapView(_ map: Map, _ testCase: TestCase) -> some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.onAttributionBarHeightChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***try? await map.load()
***REMOVED******REMOVED******REMOVED******REMOVED***let featureLayer = map.operationalLayers.first as? FeatureLayer
***REMOVED******REMOVED******REMOVED******REMOVED***let parameters = QueryParameters()
***REMOVED******REMOVED******REMOVED******REMOVED***parameters.addObjectID(testCase.objectID)
***REMOVED******REMOVED******REMOVED******REMOVED***let result = try? await featureLayer?.featureTable?.queryFeatures(using: parameters)
***REMOVED******REMOVED******REMOVED******REMOVED***guard let feature = result?.features().makeIterator().next() as? ArcGISFeature else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***try? await feature.load()
***REMOVED******REMOVED******REMOVED******REMOVED***guard let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***featureLayer?.selectFeature(feature)
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm = FeatureForm(feature: feature, definition: formDefinition)
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard)
***REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: .constant(.full),
***REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***FeatureFormView(featureForm: featureForm!)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden(isPresented)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case selection UI.
***REMOVED***var testCaseSelector: some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***ForEach(cases) { testCase in
***REMOVED******REMOVED******REMOVED******REMOVED***Button(testCase.id) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.testCase = testCase
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map = Map(url: testCase.url)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
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
***REMOVED******REMOVED***let url: URL
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates a FeatureFormView test case.
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - name: The name of the test case.
***REMOVED******REMOVED******REMOVED***/   - objectID: The object ID of the feature being tested.
***REMOVED******REMOVED******REMOVED***/   - portalID: The portal ID of the test data.
***REMOVED******REMOVED***init(_ name: String, objectID: Int, portalID: String) {
***REMOVED******REMOVED******REMOVED***self.id = name
***REMOVED******REMOVED******REMOVED***self.objectID = objectID
***REMOVED******REMOVED******REMOVED***self.url = .init(
***REMOVED******REMOVED******REMOVED******REMOVED***string: String("https:***REMOVED***arcgis.com/home/item.html?id=\(portalID)")
***REMOVED******REMOVED******REMOVED***)!
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The set of all Form View UI test cases.
***REMOVED***var cases: [TestCase] {[
***REMOVED******REMOVED***.init("testCase_1_1", objectID: 1, portalID: .inputValidationMapID),
***REMOVED******REMOVED***.init("testCase_1_2", objectID: 1, portalID: .inputValidationMapID),
***REMOVED******REMOVED***.init("testCase_1_3", objectID: 1, portalID: .inputValidationMapID),
***REMOVED******REMOVED***.init("testCase_1_4", objectID: 1, portalID: .rangeDomainMapID),
***REMOVED******REMOVED***.init("testCase_2_1", objectID: 1, portalID: .dateMapID),
***REMOVED******REMOVED***.init("testCase_2_2", objectID: 2, portalID: .dateMapID),
***REMOVED******REMOVED***.init("testCase_2_3", objectID: 1, portalID: .dateMapID),
***REMOVED******REMOVED***.init("testCase_2_4", objectID: 1, portalID: .dateMapID),
***REMOVED******REMOVED***.init("testCase_2_5", objectID: 1, portalID: .dateMapID),
***REMOVED******REMOVED***.init("testCase_2_6", objectID: 1, portalID: .dateMapID),
***REMOVED******REMOVED***.init("testCase_3_1", objectID: 2, portalID: .comboBoxMapID),
***REMOVED******REMOVED***.init("testCase_3_2", objectID: 2, portalID: .comboBoxMapID),
***REMOVED******REMOVED***.init("testCase_3_3", objectID: 2, portalID: .comboBoxMapID),
***REMOVED******REMOVED***.init("testCase_3_4", objectID: 2, portalID: .comboBoxMapID),
***REMOVED******REMOVED***.init("testCase_3_5", objectID: 2, portalID: .comboBoxMapID),
***REMOVED******REMOVED***.init("testCase_3_6", objectID: 2, portalID: .comboBoxMapID),
***REMOVED******REMOVED***.init("testCase_4_1", objectID: 1, portalID: .radioButtonMapID),
***REMOVED******REMOVED***.init("testCase_4_2", objectID: 1, portalID: .radioButtonMapID),
***REMOVED******REMOVED***.init("testCase_5_1", objectID: 1, portalID: .switchMapID),
***REMOVED******REMOVED***.init("testCase_5_2", objectID: 1, portalID: .switchMapID),
***REMOVED******REMOVED***.init("testCase_5_3", objectID: 1, portalID: .switchMapID),
***REMOVED******REMOVED***.init("testCase_6_1", objectID: 1, portalID: .groupElementMapID),
***REMOVED******REMOVED***.init("testCase_6_2", objectID: 2, portalID: .groupElementMapID),
***REMOVED******REMOVED***.init("testCase_7_1", objectID: 2, portalID: .readOnlyMapID),
***REMOVED******REMOVED***.init("testCase_7_2", objectID: 3, portalID: .readOnlyMapID)
***REMOVED***]***REMOVED***
***REMOVED***

private extension String {
***REMOVED***static let comboBoxMapID = "ed930cf0eb724ea49c6bccd8fd3dd9af"
***REMOVED***static let dateMapID = "ec09090060664cbda8d814e017337837"
***REMOVED***static let inputValidationMapID = "5d69e2301ad14ec8a73b568dfc29450a"
***REMOVED***static let radioButtonMapID = "476e9b4180234961809485c8eff83d5d"
***REMOVED***static let rangeDomainMapID = "bb4c5e81740e4e7296943988c78a7ea6"
***REMOVED***static let readOnlyMapID = "1d6cd4607edf4a50ac10b5165926b597"
***REMOVED***static let switchMapID = "ff98f13b32b349adb55da5528d9174dc"
***REMOVED***static let groupElementMapID = "97495f67bd2e442dbbac485232375b07"
***REMOVED***
