// Copyright 2021 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Combine
import XCTest

@testable import ArcGISToolkit

/// - See Also: [Test Design](https://devtopia.esri.com/runtime/common-toolkit/blob/main/designs/UtilityNetworkTraceTool/UtilityNetworkTraceTool_Test_Design.md)
@MainActor final class UtilityNetworkTraceViewModelTests: XCTestCase {
    override func setUpWithError() throws {
        ArcGISRuntimeEnvironment.apiKey = APIKey("<#API Key#>")
        try XCTSkipIf(ArcGISRuntimeEnvironment.apiKey == .placeholder)
    }
    
    func tearDownWithError() async throws {
        ArcGISRuntimeEnvironment.apiKey = nil
        await ArcGISRuntimeEnvironment.credentialStore.removeAll()
    }
    
    func testCase_1_1() async {
        let viewModel = UtilityNetworkTraceViewModel(
            map: await makeMapWithNoUtilityNetworks(),
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [],
            autoLoad: false
        )
        
        await viewModel.load()
        
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertEqual(
            viewModel.userWarning,
            "No utility networks found."
        )
    }
    
    func testCase_1_2() async throws {
        let serverPassword: String? = nil
        try XCTSkipIf(serverPassword == nil)
        let token = try await ArcGISCredential.token(
            url: .sampleServer7,
            username: "viewer01",
            password: serverPassword!
        )
        await ArcGISRuntimeEnvironment.credentialStore.add(token)
        let map = await makeMapWithNoUtilityNetworks()
        map.addUtilityNetwork(
            await makeNetworkWith(url: .sampleServer7)
        )
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [],
            autoLoad: false
        )
        
        await viewModel.load()
        
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertTrue(viewModel.configurations.isEmpty)
        XCTAssertEqual(
            viewModel.userWarning,
            "No trace types found."
        )
    }
    
    func testCase_1_3() async throws {
        let serverPassword: String? = "test.publisher01"
        try XCTSkipIf(serverPassword == nil)
        let token = try await ArcGISCredential.token(
            url: .rtc_100_8,
            username: "publisher1",
            password: serverPassword!
        )
        await ArcGISRuntimeEnvironment.credentialStore.add(token)
        
        guard let map = Map(url: .rtc_100_8) else {
            XCTFail("Failed to load map")
            return
        }
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [],
            autoLoad: false
        )
        
        await viewModel.load()
        
        XCTExpectFailure("Further server trust handling required.")
        
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertTrue(viewModel.configurations.isEmpty)
        XCTAssertEqual(
            viewModel.userWarning,
            "No trace types found."
        )
    }
    
    func testCase_1_4() async throws {
        let serverPassword: String? = nil
        try XCTSkipIf(serverPassword == nil)
        let token = try await ArcGISCredential.token(
            url: .rt_server109,
            username: "publisher1",
            password: serverPassword!
        )
        await ArcGISRuntimeEnvironment.credentialStore.add(token)
    }
    
    func testCase_2_1() {}
    
    func testCase_2_2() {}
    
    func testCase_2_3() {}
    
    func testCase_3_1() {}
    
    func testCase_3_2() {}
}

extension UtilityNetworkTraceViewModelTests {
    /// - Returns: A loaded map that contains no utility networks.
    func makeMapWithNoUtilityNetworks() async -> Map {
        let map = Map(basemapStyle: .arcGISTopographic)
        do {
            try await map.load()
        } catch {
            XCTFail(error.localizedDescription)
        }
        return map
    }
    
    /// - Returns: A loaded map that contains no utility networks.
    func makeMapWith(url: URL) async -> Map? {
        let map = Map(url: url)
        do {
            try await map?.load()
        } catch {
            XCTFail(error.localizedDescription)
        }
        return map
    }
    
    /// - Returns: A loaded utility network.
    func makeNetworkWith(url: URL) async -> UtilityNetwork {
        let network = UtilityNetwork(url: url)
        do {
            try await network.load()
        } catch {
            XCTFail(error.localizedDescription)
        }
        return network
    }
}

private extension URL {
    static var rt_server109 = URL(string: "https://rt-server109.esri.com/portal/home/item.html?id=54fa9aadf6c645d39f006cf279147204")!
    
    static var rtc_100_8 = URL(string: "http://rtc-100-8.esri.com/portal/home/webmap/viewer.html?webmap=78f993b89bad4ba0a8a22ce2e0bcfbd0")!
    
    static var sampleServer7 = URL(string: "https://sampleserver7.arcgisonline.com/server/rest/services/UtilityNetwork/NapervilleElectric/FeatureServer")!
}
