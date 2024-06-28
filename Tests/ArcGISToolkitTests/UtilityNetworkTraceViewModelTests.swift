***REMOVED***
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
import XCTest

@testable ***REMOVED***Toolkit

final class UtilityNetworkTraceViewModelTests: XCTestCase {
***REMOVED***override func setUp() async throws {
***REMOVED******REMOVED***ArcGISEnvironment.apiKey = .default
***REMOVED******REMOVED***
***REMOVED******REMOVED***setNetworkChallengeHandler(NetworkChallengeHandler(allowUntrustedHosts: true))
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(
***REMOVED******REMOVED******REMOVED***try await tokenForSampleServer7
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func tearDownWithError() async throws {
***REMOVED******REMOVED***ArcGISEnvironment.apiKey = nil
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = nil
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = nil
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISCredentialStore.removeAll()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test `UtilityNetworkTraceViewModel` on a map that does not contain a utility network.
***REMOVED***@MainActor
***REMOVED***func testCase_1_1() async throws {
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: try await makeMap(),
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(viewModel.network)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.userAlert?.description,
***REMOVED******REMOVED******REMOVED***"No utility networks found."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test `UtilityNetworkTraceViewModel` on a map that contains a utility network.
***REMOVED***@MainActor
***REMOVED***func testCase_1_4() async throws {
***REMOVED******REMOVED***let map = try await makeMapWithPortalItem()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNotNil(viewModel.network)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.configurations.count, 5)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.network?.name,
***REMOVED******REMOVED******REMOVED***"NapervilleElectric Utility Network"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test initializing a `UtilityNetworkTraceViewModel` with starting points.
***REMOVED***@MainActor
***REMOVED***func testCase_2_1() async throws {
***REMOVED******REMOVED***let map = try await makeMapWithPortalItem()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let layer = try XCTUnwrap(map.operationalLayers.first?.subLayerContents.first { $0.name == "Electric Distribution Line" ***REMOVED*** as? FeatureLayer)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let parameters = QueryParameters()
***REMOVED******REMOVED***parameters.addObjectID(3726)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let result = try await layer.featureTable?.queryFeatures(using: parameters)
***REMOVED******REMOVED***let features = try XCTUnwrap(result?.features().compactMap { $0 ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(features.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let feature = try XCTUnwrap(features.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: [
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkTraceStartingPoint(geoElement: feature)
***REMOVED******REMOVED******REMOVED***],
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let startingPoints = viewModel.pendingTrace.startingPoints
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(viewModel.pendingTrace.configuration)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertEqual(startingPoints.count, 1)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***startingPoints.first?.utilityElement?.networkSource.name,
***REMOVED******REMOVED******REMOVED***"Electric Distribution Line"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***startingPoints.first?.utilityElement?.assetGroup.name,
***REMOVED******REMOVED******REMOVED***"Low Voltage"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test modifying the terminal configuration of a utility element that supports terminal
***REMOVED******REMOVED***/ configuration.
***REMOVED***@MainActor
***REMOVED***func testCase_2_2() async throws {
***REMOVED******REMOVED***let map = try await makeMapWithPortalItem()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let layer = try XCTUnwrap(map.operationalLayers.first?.subLayerContents.first { $0.name == "Electric Distribution Device" ***REMOVED*** as? FeatureLayer)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let parameters = QueryParameters()
***REMOVED******REMOVED***parameters.addObjectID(3174)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let result = try await layer.featureTable?.queryFeatures(using: parameters)
***REMOVED******REMOVED***let features = try XCTUnwrap(result?.features().compactMap { $0 ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(features.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let feature = try XCTUnwrap(features.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: [
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkTraceStartingPoint(geoElement: feature)
***REMOVED******REMOVED******REMOVED***],
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(viewModel.pendingTrace.startingPoints.count, 1)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let startingPoint = try XCTUnwrap(viewModel.pendingTrace.startingPoints.first)
***REMOVED******REMOVED***let assetType = try XCTUnwrap(startingPoint.utilityElement?.assetType)
***REMOVED******REMOVED***let terminals = try XCTUnwrap(assetType.terminalConfiguration?.terminals)
***REMOVED******REMOVED***let terminal = try XCTUnwrap(terminals.first { $0.name == "Low" ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let configuration = try XCTUnwrap( viewModel.configurations.first {
***REMOVED******REMOVED******REMOVED***$0.name == "Upstream Trace"
***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***viewModel.setTerminalConfigurationFor(startingPoint: viewModel.pendingTrace.startingPoints.first!, to: terminal)
***REMOVED******REMOVED***
***REMOVED******REMOVED***viewModel.setPendingTrace(configuration: configuration)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(viewModel.canRunTrace)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let succeeded = await viewModel.trace()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(succeeded)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.completedTraces.count, 1)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test modifying the fractional starting point along an edge based utility element.
***REMOVED***@MainActor
***REMOVED***func testCase_2_3() async throws {
***REMOVED******REMOVED***let map = try await makeMapWithPortalItem()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let layer = try XCTUnwrap(map.operationalLayers.first?.subLayerContents.first { $0.name == "Electric Distribution Line" ***REMOVED*** as? FeatureLayer)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let parameters = QueryParameters()
***REMOVED******REMOVED***parameters.addObjectID(1748)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let result = try await layer.featureTable?.queryFeatures(using: parameters)
***REMOVED******REMOVED***let features = try XCTUnwrap(result?.features().compactMap { $0 ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(features.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let feature = try XCTUnwrap(features.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: [
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkTraceStartingPoint(geoElement: feature)
***REMOVED******REMOVED******REMOVED***],
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(viewModel.pendingTrace.startingPoints.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let extent1 = try XCTUnwrap(viewModel.pendingTrace.startingPoints.first?.graphic?.geometry?.extent)
***REMOVED******REMOVED***viewModel.setFractionAlongEdgeFor(
***REMOVED******REMOVED******REMOVED***startingPoint: viewModel.pendingTrace.startingPoints.first!,
***REMOVED******REMOVED******REMOVED***to: 0.789
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let extent2 = try XCTUnwrap(viewModel.pendingTrace.startingPoints.first?.graphic?.geometry?.extent)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNotEqual(
***REMOVED******REMOVED******REMOVED***extent1.center,
***REMOVED******REMOVED******REMOVED***extent2.center
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** Test an upstream trace and validate a function result.
***REMOVED***@MainActor
***REMOVED***func testCase_3_1() async throws {
***REMOVED******REMOVED***let map = try await makeMapWithPortalItem()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let layer = try XCTUnwrap(map.operationalLayers.first?.subLayerContents.first { $0.name == "Electric Distribution Device" ***REMOVED*** as? FeatureLayer)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let parameters = QueryParameters()
***REMOVED******REMOVED***parameters.addObjectID(2247)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let result = try await layer.featureTable?.queryFeatures(using: parameters)
***REMOVED******REMOVED***let features = try XCTUnwrap(result?.features().compactMap { $0 ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(features.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let feature = try XCTUnwrap(features.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: [
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkTraceStartingPoint(geoElement: feature)
***REMOVED******REMOVED******REMOVED***],
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let configuration = try XCTUnwrap( viewModel.configurations.first {
***REMOVED******REMOVED******REMOVED***$0.name == "Upstream Trace"
***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***viewModel.setPendingTrace(configuration: configuration)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(viewModel.pendingTrace.startingPoints.count, 1)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.canRunTrace)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let success = await viewModel.trace()
***REMOVED******REMOVED***let functionOutput = try XCTUnwrap(viewModel.completedTraces.first?.functionOutputs[1])
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(success)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.completedTraces.first?.functionOutputs.count, 6)
***REMOVED******REMOVED***XCTAssertEqual(functionOutput.function.functionType, .add)
***REMOVED******REMOVED***XCTAssertEqual(functionOutput.function.networkAttribute.name, "Service Load")
***REMOVED******REMOVED***XCTAssertEqual(functionOutput.result as? Double, 600.0)
***REMOVED***
***REMOVED***

extension UtilityNetworkTraceViewModelTests {
***REMOVED******REMOVED***/ Creates and loads a topographic map.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The returned map contains no utility networks.
***REMOVED******REMOVED***/ - Returns: A loaded map.
***REMOVED***func makeMap() async throws -> Map {
***REMOVED******REMOVED***let map = Map(basemapStyle: .arcGISTopographic)
***REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED***return map
***REMOVED***
***REMOVED***
***REMOVED***func makeMapWithPortalItem() async throws -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let map = Map(item: portalItem)
***REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED***return map
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A token to a sample public utility network dataset as previously published in the
***REMOVED******REMOVED***/ [Javascript sample](https:***REMOVED***developers.arcgis.com/javascript/latest/sample-code/widgets-untrace/).
***REMOVED***var tokenForSampleServer7: ArcGISCredential {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***try await TokenCredential.credential(
***REMOVED******REMOVED******REMOVED******REMOVED***for: URL.sampleServer7,
***REMOVED******REMOVED******REMOVED******REMOVED***username: "viewer01",
***REMOVED******REMOVED******REMOVED******REMOVED***password: "I68VGU^nMurF"
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED***static let sampleServer7 = URL(string: "https:***REMOVED***sampleserver7.arcgisonline.com/portal/sharing/rest")!
***REMOVED***
