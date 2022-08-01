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
    
    private let apiKey = APIKey("<#API Key#>")
    private let passwordFor_rtc_100_8: String? = nil
    private let passwordFor_rt_server109: String? = nil
    private let passwordFor_sampleServer7: String? = nil
    
    override func setUpWithError() throws {
        ArcGISRuntimeEnvironment.apiKey = apiKey
        try XCTSkipIf(apiKey == .placeholder)
    }
    
    func tearDownWithError() async throws {
        ArcGISRuntimeEnvironment.apiKey = nil
        ArcGISRuntimeEnvironment.authenticationChallengeHandler = nil
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
        
        XCTAssertNil(viewModel.network)
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertEqual(
            viewModel.userWarning,
            "No utility networks found."
        )
    }
    
    func testCase_1_2() async throws {
        try XCTSkipIf(passwordFor_sampleServer7 == nil)
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.sampleServer7.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenFor_sampleServer7()
        )
        
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
        
        XCTAssertNotNil(viewModel.network)
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertTrue(viewModel.configurations.isEmpty)
        XCTAssertEqual(
            viewModel.userWarning,
            "No trace types found."
        )
    }
    
    func testCase_1_3() async throws {
        try XCTSkipIf(passwordFor_rtc_100_8 == nil)
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rtc_100_8.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenFor_rtc_100_8()
        )
        
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
        
        XCTAssertNotNil(viewModel.network)
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertTrue(viewModel.configurations.isEmpty)
        XCTAssertEqual(
            viewModel.userWarning,
            "No trace types found."
        )
    }
    
    func testCase_1_4() async throws {
        try XCTSkipIf(passwordFor_rt_server109 == nil)
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rt_server109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenFor_rt_server109()
        )
        
        guard let map = Map(url: .rt_server109) else {
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
        
        XCTAssertNotNil(viewModel.network)
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertFalse(viewModel.configurations.isEmpty)
        XCTAssertEqual(
            viewModel.network?.name,
            "L23UtilityNetwork_Utility_Network Utility Network"
        )
    }
    
    func testCase_2_1() async throws {
        try XCTSkipIf(passwordFor_rt_server109 == nil)
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rt_server109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenFor_rt_server109()
        )
        
        guard let map = await makeMapWith(url: .rt_server109) else {
            XCTFail()
            return
        }
        
        let layer = try XCTUnwrap(map.operationalLayers.first {
            $0.name == "ElecDist Device"
        } as? FeatureLayer)
        
        let parameters = QueryParameters()
        parameters.addObjectID(171)
        
        let result = try await layer.featureTable?.queryFeatures(parameters: parameters)
        let features = try XCTUnwrap(result?.features().compactMap { $0 })
        
        XCTAssertEqual(features.count, 1)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: features.first!)
            ],
            autoLoad: false
        )
        
        await viewModel.load()
        
        let startingPoints = viewModel.pendingTrace.startingPoints
        
        XCTAssertNil(viewModel.pendingTrace.configuration)
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertEqual(startingPoints.count, 1)
        XCTAssertEqual(
            startingPoints.first?.utilityElement?.networkSource.name,
            "ElecDist Device"
        )
        XCTAssertEqual(
            startingPoints.first?.utilityElement?.assetGroup.name,
            "ServicePoint"
        )
    }
    
    func testCase_2_2() async throws {
        try XCTSkipIf(passwordFor_rt_server109 == nil)
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rt_server109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenFor_rt_server109()
        )
        
        guard let map = await makeMapWith(url: .rt_server109) else {
            XCTFail()
            return
        }
        
        let layer = try XCTUnwrap(map.operationalLayers.first {
            $0.name == "ElecDist Device"
        } as? FeatureLayer)
        
        let parameters = QueryParameters()
        parameters.addObjectID(463)
        
        let result = try await layer.featureTable?.queryFeatures(parameters: parameters)
        let features = try XCTUnwrap(result?.features().compactMap { $0 })
        
        XCTAssertEqual(features.count, 1)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: features.first!)
            ],
            autoLoad: false
        )
        
        await viewModel.load()
        
        XCTAssertEqual(viewModel.pendingTrace.startingPoints.count, 1)
        XCTAssertFalse(viewModel.canRunTrace)
        
        let terminal = try XCTUnwrap(viewModel.pendingTrace.startingPoints.first?.utilityElement?.assetType.terminalConfiguration?.terminals.first { $0.name == "Low" })
        
        let configuration = try XCTUnwrap( viewModel.configurations.first {
            $0.name == "ConnectedWithResultTypes"
        })
        
        viewModel.setTerminalConfigurationFor(startingPoint: viewModel.pendingTrace.startingPoints.first!, to: terminal)
        
        viewModel.setPendingTrace(configuration: configuration)
        
        XCTAssertTrue(viewModel.canRunTrace)
        
        let succeeded = await viewModel.trace()
        
        XCTAssertTrue(succeeded)
        XCTAssertEqual(viewModel.completedTraces.count, 1)
        XCTAssertFalse(viewModel.canRunTrace)
    }
    
    func testCase_2_3() async throws {
        try XCTSkipIf(passwordFor_rt_server109 == nil)
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rt_server109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenFor_rt_server109()
        )
        
        guard let map = await makeMapWith(url: .rt_server109) else {
            XCTFail()
            return
        }
        
        let layer = try XCTUnwrap(map.operationalLayers.first {
            $0.name == "ElecDist Line"
        } as? FeatureLayer)
        
        let parameters = QueryParameters()
        parameters.addObjectID(177)
        
        let result = try await layer.featureTable?.queryFeatures(parameters: parameters)
        let features = try XCTUnwrap(result?.features().compactMap { $0 })
        
        XCTAssertEqual(features.count, 1)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: features.first!)
            ],
            autoLoad: false
        )
        
        await viewModel.load()
        
        XCTAssertEqual(viewModel.pendingTrace.startingPoints.count, 1)
        
        let extent1 = try XCTUnwrap(viewModel.pendingTrace.startingPoints.first?.graphic?.geometry?.extent)
        viewModel.setFractionAlongEdgeFor(
            startingPoint: viewModel.pendingTrace.startingPoints.first!,
            to: 0.789
        )
        let extent2 = try XCTUnwrap(viewModel.pendingTrace.startingPoints.first?.graphic?.geometry?.extent)
        
        XCTAssertNotEqual(
            extent1.center,
            extent2.center
        )
    }
    
    func testCase_3_1() async throws {
        try XCTSkipIf(passwordFor_rt_server109 == nil)
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rt_server109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenFor_rt_server109()
        )
        
        guard let map = await makeMapWith(url: .rt_server109) else {
            XCTFail()
            return
        }
        
        let layer = try XCTUnwrap(map.operationalLayers.first {
            $0.name == "ElecDist Device"
        } as? FeatureLayer)
        
        let parameters = QueryParameters()
        parameters.addObjectID(171)
        
        let result = try await layer.featureTable?.queryFeatures(parameters: parameters)
        let features = try XCTUnwrap(result?.features().compactMap { $0 })
        
        XCTAssertEqual(features.count, 1)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: features.first!)
            ],
            autoLoad: false
        )
        
        await viewModel.load()
        
        let configuration = try XCTUnwrap( viewModel.configurations.first {
            $0.name == "ConnectedWithFunction"
        })
        
        viewModel.setPendingTrace(configuration: configuration)
        
        XCTAssertEqual(viewModel.pendingTrace.startingPoints.count, 1)
        XCTAssertTrue(viewModel.canRunTrace)
        
        let success = await viewModel.trace()
        let functionOutput = try XCTUnwrap( viewModel.completedTraces.first?.functionOutputs.first)
        
        XCTAssertTrue(success)
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertEqual(viewModel.completedTraces.first?.functionOutputs.count, 1)
        XCTAssertEqual(functionOutput.function.functionType, .add)
        XCTAssertEqual(functionOutput.function.networkAttribute?.name, "Shape length")
    }
    
    func testCase_3_2() async throws {
        try XCTSkipIf(passwordFor_rt_server109 == nil)
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rt_server109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenFor_rt_server109()
        )
        
        guard let map = await makeMapWith(url: .rt_server109) else {
            XCTFail()
            return
        }
        
        let layer = try XCTUnwrap(map.operationalLayers.first {
            $0.name == "ElecDist Device"
        } as? FeatureLayer)
        
        let parameters = QueryParameters()
        parameters.addObjectID(171)
        
        let result = try await layer.featureTable?.queryFeatures(parameters: parameters)
        let features = try XCTUnwrap(result?.features().compactMap { $0 })
        
        XCTAssertEqual(features.count, 1)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: features.first!)
            ],
            autoLoad: false
        )
        
        await viewModel.load()
        
        XCTAssertEqual(
            viewModel.network?.name,
            "L23UtilityNetwork_Utility_Network Utility Network"
        )
        
        let configuration = try XCTUnwrap( viewModel.configurations.first {
            $0.name == "ConnectedWithFunction"
        })
        viewModel.setPendingTrace(configuration: configuration)
        
        let success = await viewModel.trace()
        
        XCTAssertTrue(success)
    }
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
    
    func tokenFor_rtc_100_8() async throws -> ArcGISCredential {
        return try await ArcGISCredential.token(
            url: URL.rtc_100_8,
            username: "publisher1",
            password: passwordFor_rtc_100_8!
        )
    }
    
    func tokenFor_rt_server109() async throws -> ArcGISCredential {
        return try await ArcGISCredential.token(
            url: URL.rt_server109,
            username: "publisher1",
            password: passwordFor_rt_server109!
        )
    }
    
    func tokenFor_sampleServer7() async throws -> ArcGISCredential {
        return try await ArcGISCredential.token(
            url: URL.sampleServer7,
            username: "viewer01",
            password: passwordFor_sampleServer7!
        )
    }
}

private extension URL {
    static var rt_server109 = URL(string: "https://rt-server109.esri.com/portal/home/item.html?id=54fa9aadf6c645d39f006cf279147204")!
    
    static var rtc_100_8 = URL(string: "http://rtc-100-8.esri.com/portal/home/webmap/viewer.html?webmap=78f993b89bad4ba0a8a22ce2e0bcfbd0")!
    
    static var sampleServer7 = URL(string: "https://sampleserver7.arcgisonline.com/server/rest/services/UtilityNetwork/NapervilleElectric/FeatureServer")!
}
