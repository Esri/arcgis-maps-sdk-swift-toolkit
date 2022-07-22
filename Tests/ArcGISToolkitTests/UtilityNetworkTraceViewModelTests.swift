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
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.removeAll()
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_1() async {
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: await makeMapWithNoUtilityNetworks(),
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: []
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.userWarning,
***REMOVED******REMOVED******REMOVED***"No utility networks found."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_2() async throws {
***REMOVED******REMOVED***let sampleServer7Password: String? = nil
***REMOVED******REMOVED***try XCTSkipIf(sampleServer7Password == nil)
***REMOVED******REMOVED***let token = try await ArcGISCredential.token(
***REMOVED******REMOVED******REMOVED***url: .sampleServer7,
***REMOVED******REMOVED******REMOVED***username: "viewer01",
***REMOVED******REMOVED******REMOVED***password: sampleServer7Password!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.add(token)
***REMOVED******REMOVED***let map = await makeMapWithNoUtilityNetworks()
***REMOVED******REMOVED***map.addUtilityNetwork(
***REMOVED******REMOVED******REMOVED***await makeNetworkWith(url: .sampleServer7)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewModel = UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay(),
***REMOVED******REMOVED******REMOVED***startingPoints: []
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let configurations = await viewModel.utilityNamedTraceConfigurations(from: map)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let expectation = expectation(description: "init completed")
***REMOVED******REMOVED***
***REMOVED******REMOVED***var subscription = Set<AnyCancellable>()
***REMOVED******REMOVED***viewModel.$initializationCompleted.sink { v in
***REMOVED******REMOVED******REMOVED***if v == true {
***REMOVED******REMOVED******REMOVED******REMOVED***expectation.fulfill()
***REMOVED******REMOVED***
***REMOVED***.store(in: &subscription)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED***wait(for: [expectation], timeout: 2.0)
***REMOVED******REMOVED***XCTAssertTrue(configurations.isEmpty)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_3() {***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_4() {***REMOVED***
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
***REMOVED***static var sampleServer7 = URL(string: "https:***REMOVED***sampleserver7.arcgisonline.com/server/rest/services/UtilityNetwork/NapervilleElectric/FeatureServer")!
***REMOVED***
