// Copyright 2023 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import SwiftUI

struct FeatureFormTestView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// The `Map` displayed in the `MapView`.
    @State private var map: Map?
    
    /// A Boolean value indicating whether or not the form is displayed.
    @State private var isPresented = false
    
    /// The form being edited in the form view.
    @State private var featureForm: FeatureForm?
    
    /// The current test case.
    @State private var testCase: TestCase?
    
    var body: some View {
        Group {
            if let map, let testCase {
                makeMapView(map, testCase)
            } else {
                testCaseSelector
            }
        }
    }
}

private extension FeatureFormTestView {
    /// Make the main test UI.
    /// - Parameters:
    ///   - map: The map under test.
    ///   - testCase: The test definition.
    @MainActor func makeMapView(_ map: Map, _ testCase: TestCase) -> some View {
        MapView(map: map)
            .onAttributionBarHeightChanged {
                attributionBarHeight = $0
            }
            .task {
                try? await map.load()
                let featureLayer = map.operationalLayers.first as? FeatureLayer
                let parameters = QueryParameters()
                parameters.addObjectID(testCase.objectID)
                let result = try? await featureLayer?.featureTable?.queryFeatures(using: parameters)
                guard let feature = result?.features().makeIterator().next() as? ArcGISFeature else { return }
                try? await feature.load()
                guard let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition else { return }
                featureLayer?.selectFeature(feature)
                featureForm = FeatureForm(feature: feature, definition: formDefinition)
                isPresented = true
            }
            .ignoresSafeArea(.keyboard)
            .floatingPanel(
                attributionBarHeight: attributionBarHeight,
                selectedDetent: .constant(.full),
                horizontalAlignment: .leading,
                isPresented: $isPresented
            ) {
                FeatureFormView(featureForm: featureForm!)
                    .padding()
            }
            .navigationBarBackButtonHidden(isPresented)
    }
    
    /// Test case selection UI.
    var testCaseSelector: some View {
        ScrollView {
            ForEach(cases) { testCase in
                Button(testCase.id) {
                    self.testCase = testCase
                    map = Map(url: testCase.url)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    /// A Boolean value indicating whether the form controls should be shown directly in the form's
    ///  presenting container.
    var useControlsInForm: Bool {
        verticalSizeClass == .compact ||
        UIDevice.current.userInterfaceIdiom == .mac ||
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Test conditions for a Form View.
    struct TestCase: Identifiable {
        /// The name of the test case.
        let id: String
        /// The object ID of the feature being tested.
        let objectID: Int
        /// The test data location.
        let url: URL
        
        /// Creates a FeatureFormView test case.
        /// - Parameters:
        ///   - name: The name of the test case.
        ///   - objectID: The object ID of the feature being tested.
        ///   - portalID: The portal ID of the test data.
        init(_ name: String, objectID: Int, portalID: String) {
            self.id = name
            self.objectID = objectID
            self.url = .init(
                string: String("https://arcgis.com/home/item.html?id=\(portalID)")
            )!
        }
    }
    
    /// The set of all Form View UI test cases.
    var cases: [TestCase] {[
        .init("testCase_1_1", objectID: 1, portalID: .inputValidationMapID),
        .init("testCase_1_2", objectID: 1, portalID: .inputValidationMapID),
        .init("testCase_1_3", objectID: 1, portalID: .inputValidationMapID),
        .init("testCase_1_4", objectID: 1, portalID: .rangeDomainMapID),
        .init("testCase_2_1", objectID: 1, portalID: .dateMapID),
        .init("testCase_2_2", objectID: 2, portalID: .dateMapID),
        .init("testCase_2_3", objectID: 1, portalID: .dateMapID),
        .init("testCase_2_4", objectID: 1, portalID: .dateMapID),
        .init("testCase_2_5", objectID: 1, portalID: .dateMapID),
        .init("testCase_2_6", objectID: 1, portalID: .dateMapID),
        .init("testCase_3_1", objectID: 2, portalID: .comboBoxMapID),
        .init("testCase_3_2", objectID: 2, portalID: .comboBoxMapID),
        .init("testCase_3_3", objectID: 2, portalID: .comboBoxMapID),
        .init("testCase_3_4", objectID: 2, portalID: .comboBoxMapID),
        .init("testCase_3_5", objectID: 2, portalID: .comboBoxMapID),
        .init("testCase_3_6", objectID: 2, portalID: .comboBoxMapID),
        .init("testCase_4_1", objectID: 1, portalID: .radioButtonMapID),
        .init("testCase_4_2", objectID: 1, portalID: .radioButtonMapID),
        .init("testCase_5_1", objectID: 1, portalID: .switchMapID),
        .init("testCase_5_2", objectID: 1, portalID: .switchMapID),
        .init("testCase_5_3", objectID: 1, portalID: .switchMapID),
        .init("testCase_6_1", objectID: 1, portalID: .groupElementMapID),
        .init("testCase_6_2", objectID: 2, portalID: .groupElementMapID),
        .init("testCase_7_1", objectID: 2, portalID: .readOnlyMapID),
        .init("testCase_8_1", objectID: 1, portalID: .attachmentMapID)
    ]}
}

private extension String {
    static let attachmentMapID = "3e551c383fc949c7982ec73ba67d409b"
    static let comboBoxMapID = "ed930cf0eb724ea49c6bccd8fd3dd9af"
    static let dateMapID = "ec09090060664cbda8d814e017337837"
    static let inputValidationMapID = "5d69e2301ad14ec8a73b568dfc29450a"
    static let radioButtonMapID = "476e9b4180234961809485c8eff83d5d"
    static let rangeDomainMapID = "bb4c5e81740e4e7296943988c78a7ea6"
    static let readOnlyMapID = "1d6cd4607edf4a50ac10b5165926b597"
    static let switchMapID = "ff98f13b32b349adb55da5528d9174dc"
    static let groupElementMapID = "97495f67bd2e442dbbac485232375b07"
}
