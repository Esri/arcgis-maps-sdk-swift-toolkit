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
    
    /// A message describing an error during test view setup.
    @State private var alertError: String?
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// The form being edited in the form view.
    @State private var featureForm: FeatureForm?
    
    /// The list of identify layer results.
    @State private var identifyLayerResults = [IdentifyLayerResult]()
    
    /// A Boolean value indicating whether the initial draw of the map view completed.
    @State private var initialDrawCompleted = false
    
    /// The `Map` displayed in the `MapView`.
    @State private var map: Map?
    
    /// The string for the test search bar.
    @State private var searchTerm: String = ""
    
    /// The current test case.
    @State private var testCase: TestCase?
    
    /// The test setup task to run once was the map has finished its initial draw.
    @State private var testSetupTask: Task<Void, Never>?
    
    var body: some View {
        Group {
            if let map, let testCase {
                makeMapView(map, testCase)
                    .task {
                        if let credentialInfo = testCase.credentialInfo {
                            await addCredential(credentialInfo)
                        }
                    }
            } else {
                testCaseList
            }
        }
        .navigationBarBackButtonHidden(featureForm != nil)
    }
}

private extension FeatureFormTestView {
    /// Adds a credential for the given credential info.
    func addCredential(_ info: TestCase.CredentialInfo) async {
        do {
            let credential = try await TokenCredential.credential(
                for: info.portal,
                username: info.username,
                password: info.password
            )
            ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(credential)
        } catch {
            alertError = error.localizedDescription
        }
    }
    
    /// Make the main test UI.
    /// - Parameters:
    ///   - map: The map under test.
    ///   - testCase: The test definition.
    func makeMapView(_ map: Map, _ testCase: TestCase) -> some View {
        MapViewReader { mapView in
            MapView(map: map)
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
                .onDrawStatusChanged { drawStatus in
                    if !initialDrawCompleted, drawStatus == .completed {
                        initialDrawCompleted = true
                        testSetupTask = Task {
                            if let point = testCase.point {
                                await mapView.setViewpoint(Viewpoint(center: point, scale: 1000))
                                guard let screenPoint = mapView.screenPoint(fromLocation: point) else { return }
                                do {
                                    identifyLayerResults = try await mapView.identifyLayers(screenPoint: screenPoint, tolerance: 10)
                                } catch {
                                    alertError = error.localizedDescription
                                }
                            } else if let objectID = testCase.objectID {
                                await selectObjectID(objectID, on: map)
                            }
                        }
                    }
                }
                .alert(
                    "Error",
                    isPresented: Binding {
                        alertError != nil
                    } set: { _ in },
                    actions: { },
                    message: { Text(alertError ?? "Unknown error") }
                )
                .ignoresSafeArea(.keyboard)
                .sheet(isPresented: Binding(get: { !identifyLayerResults.isEmpty }, set: { _ in })) {
                    identifyLayerResultsList
                }
                .task {
                    do {
                        try await map.load()
                    } catch {
                        alertError = error.localizedDescription
                    }
                }
                .floatingPanel(
                    attributionBarHeight: attributionBarHeight,
                    selectedDetent: .constant(.full),
                    horizontalAlignment: .leading,
                    isPresented: Binding(get: { featureForm != nil }, set: { _ in })
                ) {
                    FeatureFormView(featureForm: $featureForm)
                }
        }
    }
    
    func selectObjectID(_ objectID: Int, on map: Map) async {
        guard let featureLayer = map.operationalLayers.first as? FeatureLayer else {
            alertError = "Can't resolve layer"
            return
        }
        let parameters = QueryParameters()
        parameters.addObjectID(objectID)
        do {
            let result = try await featureLayer.featureTable?.queryFeatures(using: parameters)
            guard let feature = result?.features().makeIterator().next() as? ArcGISFeature else {
                alertError = "No match for feature \(objectID.formatted()) found."
                return
            }
            try await feature.load()
            featureLayer.selectFeature(feature)
            featureForm = FeatureForm(feature: feature)
        } catch {
            alertError = error.localizedDescription
        }
    }
    
    /// The list of identify layer results.
    var identifyLayerResultsList: some View {
        List {
            Section("ArcGIS Features") {
                let features = identifyLayerResults.flatMap { $0.geoElements.compactMap { $0 as? ArcGISFeature } }
                ForEach(features.enumerated().map{ $0 }, id: \.0) { _, feature in
                    Button(feature.displayName) {
                        featureForm = FeatureForm(feature: feature)
                        self.identifyLayerResults.removeAll()
                    }
                }
            }
        }
    }
    
    /// The list of test cases.
    var testCaseList: some View {
        List {
            Section {
                TextField("Search", text: $searchTerm, prompt: Text("Search"))
            }
            let cases = searchTerm.isEmpty ? cases : cases.filter { $0.id.localizedStandardContains(searchTerm) }
            ForEach(cases) { testCase in
                Button(testCase.id) {
                    self.testCase = testCase
                    map = Map(url: testCase.url)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    /// Test conditions for a Form View.
    struct TestCase: Identifiable {
        /// Storing credential info allows for lazily initialization of token credentials, as opposed to each
        /// time the test cases are created.
        struct CredentialInfo {
            let portal: URL
            let username: String
            let password: String
        }
        
        /// Optional ArcGIS credential info for the test data.
        let credentialInfo: CredentialInfo?
        /// The name of the test case.
        let id: String
        /// The object ID of the feature being tested.
        let objectID: Int?
        /// The map location of the feature under test.
        let point: Point?
        /// The test data location.
        let url: URL
        
        /// Creates a FeatureFormView test case.
        /// - Parameters:
        ///   - name: The name of the test case.
        ///   - objectID: The object ID of the feature being tested.
        ///   - portalID: The portal ID of the test data.
        init(_ name: String, objectID: Int, portalID: String) {
            self.init(credentialInfo: nil, id: name, objectID: objectID, point: nil, portalID: portalID)
        }
        
        /// Creates a FeatureFormView test case.
        /// - Parameters:
        ///   - name: The name of the test case.
        ///   - point: The map location of the feature under test.
        ///   - portalID: The portal ID of the test data.
        ///   - credentialInfo: Optional ArcGIS credential info for the test data.
        init(_ name: String, point: Point, portalID: String, credentialInfo: CredentialInfo) {
            self.init(credentialInfo: credentialInfo, id: name, objectID: nil, point: point, portalID: portalID)
        }
        
        private init(credentialInfo: CredentialInfo?, id: String, objectID: Int?, point: Point?, portalID: String) {
            self.credentialInfo = credentialInfo
            self.id = id
            self.objectID = objectID
            self.point = point
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
        .init("testCase_3_7", objectID: 2, portalID: .comboBoxMapID),
        .init("testCase_4_1", objectID: 1, portalID: .radioButtonMapID),
        .init("testCase_4_2", objectID: 1, portalID: .radioButtonMapID),
        .init("testCase_5_1", objectID: 1, portalID: .switchMapID),
        .init("testCase_5_2", objectID: 1, portalID: .switchMapID),
        .init("testCase_5_3", objectID: 1, portalID: .switchMapID),
        .init("testCase_6_1", objectID: 1, portalID: .groupElementMapID),
        .init("testCase_6_2", objectID: 2, portalID: .groupElementMapID),
        .init("testCase_7_1", objectID: 2, portalID: .readOnlyMapID),
        .init("testCase_8_1", objectID: 1, portalID: .attachmentMapID),
        .init("testCase_9_1", objectID: 1, portalID: .testCase9),
        .init("testCase_10_1", objectID: 1, portalID: .testCase10),
        .init("testCase_10_2", objectID: 1, portalID: .testCase10),
        .init("testCase_11_1", objectID: 2, portalID: .testCase11),
        .init("testCase_12_1", point: Point(x: -9815314.206573399, y: 5130328.983696212, spatialReference: .webMercator), portalID: .napervilleElectricUtilityNetwork, credentialInfo: .sampleServer7Viewer01),
    ]}
}

private extension ArcGISFeature {
    var displayName: String {
        if let objectID {
            return "Object ID:  \(objectID.formatted(.number.grouping(.never)))"
        } else {
            return "Object ID: N/A"
        }
    }
    
    var objectID: Int64? {
        if let id = attributes["objectid"] as? Int64 {
            return id
        } else {
            print(type(of: attributes["objectid"]!))
            return nil
        }
    }
}

private extension String {
    static let attachmentMapID = "3e551c383fc949c7982ec73ba67d409b"
    static let comboBoxMapID = "ed930cf0eb724ea49c6bccd8fd3dd9af"
    static let dateMapID = "ec09090060664cbda8d814e017337837"
    static let groupElementMapID = "97495f67bd2e442dbbac485232375b07"
    static let inputValidationMapID = "5d69e2301ad14ec8a73b568dfc29450a"
    static let napervilleElectricUtilityNetwork = "471eb0bf37074b1fbb972b1da70fb310"
    static let radioButtonMapID = "476e9b4180234961809485c8eff83d5d"
    static let rangeDomainMapID = "bb4c5e81740e4e7296943988c78a7ea6"
    static let readOnlyMapID = "1d6cd4607edf4a50ac10b5165926b597"
    static let switchMapID = "ff98f13b32b349adb55da5528d9174dc"
    static let testCase9 = "5f71b243b37e43a5ace3190241db0ac9"
    static let testCase10 = "e10c0061182c4102a109dc6b030aa9ef"
    static let testCase11 = "a14a825c22884dfe9998ac964bd1cf89"
}

private extension FeatureFormTestView.TestCase.CredentialInfo {
    static var sampleServer7Viewer01: Self {
        .init(
            portal: .sampleServer7Portal,
            username: "viewer01",
            password: "I68VGU^nMurF"
        )
    }
}

private extension URL {
    static var sampleServer7Portal: Self {
        .init(string: "https://sampleserver7.arcgisonline.com/portal/sharing/rest")!
    }
}
