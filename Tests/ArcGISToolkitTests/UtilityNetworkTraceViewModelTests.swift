***REMOVED***.

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
import Combine
import XCTest

@testable ***REMOVED***Toolkit

***REMOVED***/ - See Also: [Test Design](https:***REMOVED***devtopia.esri.com/runtime/common-toolkit/blob/main/designs/UtilityNetworkTraceTool/UtilityNetworkTraceTool_Test_Design.md)
@MainActor final class UtilityNetworkTraceViewModelTests: XCTestCase {
***REMOVED***override func setUpWithError() throws {
***REMOVED******REMOVED***ArcGISRuntimeEnvironment.apiKey = APIKey("<#API Key#>")
***REMOVED******REMOVED***try XCTSkipIf(ArcGISRuntimeEnvironment.apiKey == .placeholder)
***REMOVED***
***REMOVED***
***REMOVED***func tearDownWithError() async throws {
***REMOVED******REMOVED***ArcGISRuntimeEnvironment.apiKey = nil
***REMOVED******REMOVED***ArcGISRuntimeEnvironment.authenticationChallengeHandler = nil
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.removeAll()
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_1() async {
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: await makeMapWithNoUtilityNetworks(),
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: [],
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(viewModel.network)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.userWarning,
***REMOVED******REMOVED******REMOVED***"No utility networks found."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_2() async throws {
***REMOVED******REMOVED***let serverPassword: String? = nil
***REMOVED******REMOVED***try XCTSkipIf(serverPassword == nil)
***REMOVED******REMOVED***let token = try await ArcGISCredential.token(
***REMOVED******REMOVED******REMOVED***url: .sampleServer7,
***REMOVED******REMOVED******REMOVED***username: "viewer01",
***REMOVED******REMOVED******REMOVED***password: serverPassword!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.add(token)
***REMOVED******REMOVED***let map = await makeMapWithNoUtilityNetworks()
***REMOVED******REMOVED***map.addUtilityNetwork(
***REMOVED******REMOVED******REMOVED***await makeNetworkWith(url: .sampleServer7)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: [],
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNotNil(viewModel.network)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.configurations.isEmpty)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.userWarning,
***REMOVED******REMOVED******REMOVED***"No trace types found."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_3() async throws {
***REMOVED******REMOVED***let serverPassword: String? = nil
***REMOVED******REMOVED***try XCTSkipIf(serverPassword == nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED***setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rtc_100_8.host!]))
***REMOVED******REMOVED***
***REMOVED******REMOVED***let token = try await ArcGISCredential.token(
***REMOVED******REMOVED******REMOVED***url: .rtc_100_8,
***REMOVED******REMOVED******REMOVED***username: "publisher1",
***REMOVED******REMOVED******REMOVED***password: serverPassword!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.add(token)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let map = Map(url: .rtc_100_8) else {
***REMOVED******REMOVED******REMOVED***XCTFail("Failed to load map")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: [],
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNotNil(viewModel.network)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.configurations.isEmpty)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.userWarning,
***REMOVED******REMOVED******REMOVED***"No trace types found."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_4() async throws {
***REMOVED******REMOVED***let serverPassword: String? = nil
***REMOVED******REMOVED***try XCTSkipIf(serverPassword == nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED***setChallengeHandler(ChallengeHandler(trustedHosts: [URL.rt_server109.host!]))
***REMOVED******REMOVED***
***REMOVED******REMOVED***let token = try await ArcGISCredential.token(
***REMOVED******REMOVED******REMOVED***url: .rt_server109,
***REMOVED******REMOVED******REMOVED***username: "publisher1",
***REMOVED******REMOVED******REMOVED***password: serverPassword!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.add(token)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let map = Map(url: .rt_server109) else {
***REMOVED******REMOVED******REMOVED***XCTFail("Failed to load map")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: [],
***REMOVED******REMOVED******REMOVED***autoLoad: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await viewModel.load()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNotNil(viewModel.network)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.configurations.isEmpty)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.network?.name,
***REMOVED******REMOVED******REMOVED***"L23UtilityNetwork_Utility_Network Utility Network"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_2_1() {***REMOVED***
***REMOVED***
***REMOVED***func testCase_2_2() {***REMOVED***
***REMOVED***
***REMOVED***func testCase_2_3() {***REMOVED***
***REMOVED***
***REMOVED***func testCase_3_1() {***REMOVED***
***REMOVED***
***REMOVED***func testCase_3_2() {***REMOVED***
***REMOVED***

extension UtilityNetworkTraceViewModelTests {
***REMOVED******REMOVED***/ - Returns: A loaded map that contains no utility networks.
***REMOVED***func makeMapWithNoUtilityNetworks() async -> Map {
***REMOVED******REMOVED***let map = Map(basemapStyle: .arcGISTopographic)
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail(error.localizedDescription)
***REMOVED***
***REMOVED******REMOVED***return map
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ - Returns: A loaded map that contains no utility networks.
***REMOVED***func makeMapWith(url: URL) async -> Map? {
***REMOVED******REMOVED***let map = Map(url: url)
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await map?.load()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail(error.localizedDescription)
***REMOVED***
***REMOVED******REMOVED***return map
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ - Returns: A loaded utility network.
***REMOVED***func makeNetworkWith(url: URL) async -> UtilityNetwork {
***REMOVED******REMOVED***let network = UtilityNetwork(url: url)
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await network.load()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail(error.localizedDescription)
***REMOVED***
***REMOVED******REMOVED***return network
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED***static var rt_server109 = URL(string: "https:***REMOVED***rt-server109.esri.com/portal/home/item.html?id=54fa9aadf6c645d39f006cf279147204")!
***REMOVED***
***REMOVED***static var rtc_100_8 = URL(string: "http:***REMOVED***rtc-100-8.esri.com/portal/home/webmap/viewer.html?webmap=78f993b89bad4ba0a8a22ce2e0bcfbd0")!
***REMOVED***
***REMOVED***static var sampleServer7 = URL(string: "https:***REMOVED***sampleserver7.arcgisonline.com/server/rest/services/UtilityNetwork/NapervilleElectric/FeatureServer")!
***REMOVED***
