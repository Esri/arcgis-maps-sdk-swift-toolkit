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
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.configurations.isEmpty)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.userWarning,
***REMOVED******REMOVED******REMOVED***"No trace types found."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_3() async throws {
***REMOVED******REMOVED***
***REMOVED******REMOVED***let serverUsername = "publisher1"
***REMOVED******REMOVED***let serverPassword: String? = nil
***REMOVED******REMOVED***try XCTSkipIf(serverPassword == nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let challengeHandler = ChallengeHandler(
***REMOVED******REMOVED******REMOVED***trustedHosts: [URL.rtc_100_8.host!],
***REMOVED******REMOVED******REMOVED***arcgisCredentialProvider: { challenge in
***REMOVED******REMOVED******REMOVED******REMOVED***try await .token(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge: challenge,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***username: serverUsername,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***password: serverPassword!
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***ArcGISRuntimeEnvironment.authenticationChallengeHandler = challengeHandler
***REMOVED******REMOVED***
***REMOVED******REMOVED***let token = try await ArcGISCredential.token(
***REMOVED******REMOVED******REMOVED***url: .rtc_100_8,
***REMOVED******REMOVED******REMOVED***username: serverUsername,
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
***REMOVED******REMOVED***XCTAssertFalse(viewModel.canRunTrace)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.configurations.isEmpty)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.userWarning,
***REMOVED******REMOVED******REMOVED***"No trace types found."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_4() async throws {
***REMOVED******REMOVED***
***REMOVED******REMOVED***try XCTSkipIf(true, "Server trust handling required")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let serverPassword: String? = nil
***REMOVED******REMOVED***try XCTSkipIf(serverPassword == nil)
***REMOVED******REMOVED***let token = try await ArcGISCredential.token(
***REMOVED******REMOVED******REMOVED***url: .rt_server109,
***REMOVED******REMOVED******REMOVED***username: "publisher1",
***REMOVED******REMOVED******REMOVED***password: serverPassword!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.add(token)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** - TODO: Finish implementation after server trust handling is resolved
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


***REMOVED***/ A `ChallengeHandler` that that can handle trusting hosts with a self-signed certificate, the URL credential,
***REMOVED***/ and the token credential.
class ChallengeHandler: AuthenticationChallengeHandler {
***REMOVED******REMOVED***/ The hosts that can be trusted if they have certificate trust issues.
***REMOVED***let trustedHosts: Set<String>
***REMOVED***
***REMOVED******REMOVED***/ The url credential used when a challenge is thrown.
***REMOVED***let networkCredentialProvider: ((NetworkAuthenticationChallenge) async -> NetworkCredential?)?
***REMOVED***
***REMOVED******REMOVED***/ The arcgis credential used when an ArcGIS challenge is received.
***REMOVED***let arcgisCredentialProvider: ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)?
***REMOVED***
***REMOVED******REMOVED***/ The network authentication challenges.
***REMOVED***private(set) var networkChallenges: [NetworkAuthenticationChallenge] = []
***REMOVED***
***REMOVED******REMOVED***/ The ArcGIS authentication challenges.
***REMOVED***private(set) var arcGISChallenges: [ArcGISAuthenticationChallenge] = []
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***trustedHosts: Set<String> = [],
***REMOVED******REMOVED***networkCredentialProvider: ((NetworkAuthenticationChallenge) async -> NetworkCredential?)? = nil,
***REMOVED******REMOVED***arcgisCredentialProvider: ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.trustedHosts = trustedHosts
***REMOVED******REMOVED***self.networkCredentialProvider = networkCredentialProvider
***REMOVED******REMOVED***self.arcgisCredentialProvider = arcgisCredentialProvider
***REMOVED***
***REMOVED***
***REMOVED***convenience init(
***REMOVED******REMOVED***trustedHosts: Set<String>,
***REMOVED******REMOVED***networkCredential: NetworkCredential
***REMOVED***) {
***REMOVED******REMOVED***self.init(trustedHosts: trustedHosts, networkCredentialProvider: { _ in networkCredential ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func handleNetworkChallenge(_ challenge: NetworkAuthenticationChallenge) async -> NetworkAuthenticationChallengeDisposition {
***REMOVED******REMOVED******REMOVED*** Record challenge only if it is not a server trust.
***REMOVED******REMOVED***if challenge.kind != .serverTrust {
***REMOVED******REMOVED******REMOVED***networkChallenges.append(challenge)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if challenge.kind == .serverTrust {
***REMOVED******REMOVED******REMOVED***if trustedHosts.contains(challenge.host) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** This will cause a self-signed certificate to be trusted.
***REMOVED******REMOVED******REMOVED******REMOVED***return .useCredential(.serverTrust)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return .performDefaultHandling
***REMOVED******REMOVED***
***REMOVED*** else if let networkCredentialProvider = networkCredentialProvider,
***REMOVED******REMOVED******REMOVED******REMOVED***  let networkCredential = await networkCredentialProvider(challenge) {
***REMOVED******REMOVED******REMOVED***return .useCredential(networkCredential)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .cancelAuthenticationChallenge
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func handleArcGISChallenge(
***REMOVED******REMOVED***_ challenge: ArcGISAuthenticationChallenge
***REMOVED***) async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED***arcGISChallenges.append(challenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let arcgisCredentialProvider = arcgisCredentialProvider,
***REMOVED******REMOVED***   let arcgisCredential = try? await arcgisCredentialProvider(challenge) {
***REMOVED******REMOVED******REMOVED***return .useCredential(arcgisCredential)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .cancelAuthenticationChallenge
***REMOVED***
***REMOVED***
***REMOVED***
