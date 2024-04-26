// Copyright 2021 Esri
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
import XCTest

@testable import ArcGISToolkit

final class UtilityNetworkTraceViewModelTests: XCTestCase {
    override func setUp() async throws {
        ArcGISEnvironment.apiKey = .default
        
        setNetworkChallengeHandler(NetworkChallengeHandler(allowUntrustedHosts: true))
        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(
            try await tokenForSampleServer7
        )
    }
    
    func tearDownWithError() async throws {
        ArcGISEnvironment.apiKey = nil
        ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = nil
        ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = nil
        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.removeAll()
    }
    
    /// Test `UtilityNetworkTraceViewModel` on a map that does not contain a utility network.
    @MainActor
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
            viewModel.userAlert?.description,
            "No utility networks found."
        )
    }
    
    /// Test `UtilityNetworkTraceViewModel` on a map that contains a utility network.
    @MainActor
    func testCase_1_4() async throws {
        let map = try await makeMapWithPortalItem()
        
        let viewModel = UtilityNetworkTraceViewModel(
            map: map,
            graphicsOverlay: GraphicsOverlay(),
            autoLoad: false
        )
        
        await viewModel.load()
        
        XCTAssertNotNil(viewModel.network)
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertEqual(viewModel.configurations.count, 5)
        XCTAssertEqual(
            viewModel.network?.name,
            "NapervilleElectric Utility Network"
        )
    }
    
    /// Test initializing a `UtilityNetworkTraceViewModel` with starting points.
    @MainActor
    func testCase_2_1() async throws {
        let map = try await makeMapWithPortalItem()
        
        let layer = try XCTUnwrap(map.operationalLayers[0].subLayerContents[4] as? FeatureLayer)
        
        let parameters = QueryParameters()
        parameters.addObjectID(3726)
        
        let result = try await layer.featureTable?.queryFeatures(using: parameters)
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
            "Electric Distribution Line"
        )
        XCTAssertEqual(
            startingPoints.first?.utilityElement?.assetGroup.name,
            "Low Voltage"
        )
    }
    
    /// Test modifying the terminal configuration of a utility element that supports terminal
    /// configuration.
    @MainActor
    func testCase_2_2() async throws {
        let map = try await makeMapWithPortalItem()
        
        let layer = try XCTUnwrap(map.operationalLayers[0].subLayerContents[7] as? FeatureLayer)
        
        let parameters = QueryParameters()
        parameters.addObjectID(3174)
        
        let result = try await layer.featureTable?.queryFeatures(using: parameters)
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
            $0.name == "Upstream Trace"
        })
        
        viewModel.setTerminalConfigurationFor(startingPoint: viewModel.pendingTrace.startingPoints.first!, to: terminal)
        
        viewModel.setPendingTrace(configuration: configuration)
        
        XCTAssertTrue(viewModel.canRunTrace)
        
        let succeeded = await viewModel.trace()
        
        XCTAssertTrue(succeeded)
        XCTAssertEqual(viewModel.completedTraces.count, 1)
        XCTAssertFalse(viewModel.canRunTrace)
    }
    
    /// Test modifying the fractional starting point along an edge based utility element.
    @MainActor
    func testCase_2_3() async throws {
        let map = try await makeMapWithPortalItem()
        
        let layer = try XCTUnwrap(map.operationalLayers[0].subLayerContents[4] as? FeatureLayer)
        
        let parameters = QueryParameters()
        parameters.addObjectID(1748)
        
        let result = try await layer.featureTable?.queryFeatures(using: parameters)
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
    
    // Test an upstream trace and validate a function result.
    @MainActor
    func testCase_3_1() async throws {
        let map = try await makeMapWithPortalItem()
        
        let layer = try XCTUnwrap(map.operationalLayers[0].subLayerContents[7] as? FeatureLayer)
        
        let parameters = QueryParameters()
        parameters.addObjectID(2247)
        
        let result = try await layer.featureTable?.queryFeatures(using: parameters)
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
            $0.name == "Upstream Trace"
        })
        
        viewModel.setPendingTrace(configuration: configuration)
        
        XCTAssertEqual(viewModel.pendingTrace.startingPoints.count, 1)
        XCTAssertTrue(viewModel.canRunTrace)
        
        let success = await viewModel.trace()
        let functionOutput = try XCTUnwrap(viewModel.completedTraces.first?.functionOutputs[1])
        
        XCTAssertTrue(success)
        XCTAssertFalse(viewModel.canRunTrace)
        XCTAssertEqual(viewModel.completedTraces.first?.functionOutputs.count, 6)
        XCTAssertEqual(functionOutput.function.functionType, .add)
        XCTAssertEqual(functionOutput.function.networkAttribute.name, "Service Load")
        XCTAssertEqual(functionOutput.result as? Double, 600.0)
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
    
    func makeMapWithPortalItem() async throws -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
        )
        let map = Map(item: portalItem)
        try await map.load()
        return map
    }
    
    /// A token to a sample public utility network dataset as previously published in the
    /// [Javascript sample](https://developers.arcgis.com/javascript/latest/sample-code/widgets-untrace/).
    var tokenForSampleServer7: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL.sampleServer7,
                username: "viewer01",
                password: "I68VGU^nMurF"
            )
        }
    }
}

private extension URL {
    static let sampleServer7 = URL(string: "https://sampleserver7.arcgisonline.com/portal/sharing/rest")!
}
