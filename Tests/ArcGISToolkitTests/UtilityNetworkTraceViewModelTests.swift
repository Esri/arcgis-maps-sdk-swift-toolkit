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
    
    func testCase_1_1() async throws {
        let viewModel = UtilityNetworkTraceViewModel(
            map: try await makeMap(),
            graphicsOverlay: GraphicsOverlay(),
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
            try await tokenForSampleServer7
        )
        
        let map = try await makeMap()
        map.addUtilityNetwork(
            try await makeNetwork(url: .sampleServer7)
        )
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
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
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rtc1008.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenForRTC1008
        )
        
        let map = try XCTUnwrap(Map(url: .rtc1008))
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
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
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rtServer109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenForRTServer109
        )
        
        guard let map = Map(url: .rtServer109) else {
            XCTFail("Failed to load map")
            return
        }
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
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
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rtServer109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenForRTServer109
        )
        
        guard let map = try await makeMap(url: .rtServer109) else {
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
        
        let feature = try XCTUnwrap(features.first)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: feature)
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
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rtServer109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenForRTServer109
        )
        
        guard let map = try await makeMap(url: .rtServer109) else {
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
        
        let feature = try XCTUnwrap(features.first)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: feature)
            ],
            autoLoad: false
        )
        
        await viewModel.load()
        
        XCTAssertEqual(viewModel.pendingTrace.startingPoints.count, 1)
        XCTAssertFalse(viewModel.canRunTrace)
        
        let startingPoint = try XCTUnwrap(viewModel.pendingTrace.startingPoints.first)
        let assetType = try XCTUnwrap(startingPoint.utilityElement?.assetType)
        let terminals = try XCTUnwrap(assetType.terminalConfiguration?.terminals)
        let terminal = try XCTUnwrap(terminals.first { $0.name == "Low" })
        
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
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rtServer109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenForRTServer109
        )
        
        guard let map = try await makeMap(url: .rtServer109) else {
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
        
        let feature = try XCTUnwrap(features.first)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: feature)
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
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rtServer109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenForRTServer109
        )
        
        guard let map = try await makeMap(url: .rtServer109) else {
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
        
        let feature = try XCTUnwrap(features.first)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: feature)
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
        let functionOutput = try XCTUnwrap(viewModel.completedTraces.first?.functionOutputs.first)
        
        XCTAssertTrue(success)
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertEqual(viewModel.completedTraces.first?.functionOutputs.count, 1)
        XCTAssertEqual(functionOutput.function.functionType, .add)
        XCTAssertEqual(functionOutput.function.networkAttribute?.name, "Shape length")
    }
    
    func testCase_3_2() async throws {
        try XCTSkipIf(passwordFor_rt_server109 == nil)
        setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rtServer109.host!]))
        await ArcGISRuntimeEnvironment.credentialStore.add(
            try await tokenForRTServer109
        )
        
        guard let map = try await makeMap(url: .rtServer109) else {
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
        
        let feature = try XCTUnwrap(features.first)
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            startingPoints: [
                UtilityNetworkTraceStartingPoint(geoElement: feature)
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
    /// Creates and loads a topographic map.
    ///
    /// The returned map contains no utility networks.
    /// - Returns: A loaded map.
    func makeMap() async throws -> Map {
        let map = Map(basemapStyle: .arcGISTopographic)
        try await map.load()
        return map
    }
    
    /// Creates and loads a map at the provided URL.
    /// - Parameter url: The address of the map.
    /// - Returns: A loaded map.
    func makeMap(url: URL) async throws -> Map? {
        let map = try XCTUnwrap(Map(url: url))
        try await map.load()
        return map
    }
    
    /// Creates and loads a utility network at the provided URL.
    /// - Parameter url: The address of the utility network.
    /// - Returns: A loaded utility network.
    func makeNetwork(url: URL) async throws -> UtilityNetwork {
        let network = UtilityNetwork(url: url)
        try await network.load()
        return network
    }
    
    var tokenForRTC1008: ArcGISCredential {
        get async throws {
            try await ArcGISCredential.token(
                url: URL.rtc1008,
                username: "publisher1",
                password: passwordFor_rtc_100_8!
            )
        }
    }
    
    var tokenForRTServer109: ArcGISCredential {
        get async throws {
            try await ArcGISCredential.token(
                url: URL.rtServer109,
                username: "publisher1",
                password: passwordFor_rt_server109!
            )
        }
    }
    
    var tokenForSampleServer7: ArcGISCredential {
        get async throws {
            try await ArcGISCredential.token(
                url: URL.sampleServer7,
                username: "viewer01",
                password: passwordFor_sampleServer7!
            )
        }
    }
}

private extension URL {
    static let rtServer109 = URL(string: "https://rt-server109.esri.com/portal/home/item.html?id=54fa9aadf6c645d39f006cf279147204")!
    
    static let rtc1008 = URL(string: "http://rtc-100-8.esri.com/portal/home/webmap/viewer.html?webmap=78f993b89bad4ba0a8a22ce2e0bcfbd0")!
    
    static let sampleServer7 = URL(string: "https://sampleserver7.arcgisonline.com/server/rest/services/UtilityNetwork/NapervilleElectric/FeatureServer")!
}
