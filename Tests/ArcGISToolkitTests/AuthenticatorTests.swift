***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import XCTest
@testable ***REMOVED***Toolkit
***REMOVED***
import Combine

class AuthenticatorTests: XCTestCase {
***REMOVED***@MainActor
***REMOVED***func testInit() {
***REMOVED******REMOVED***let config = OAuthConfiguration(
***REMOVED******REMOVED******REMOVED***portalURL: URL(string:"www.arcgis.com")!,
***REMOVED******REMOVED******REMOVED***clientID: "client id",
***REMOVED******REMOVED******REMOVED***redirectURL: URL(string:"myapp:***REMOVED***oauth")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let authenticator = Authenticator(promptForUntrustedHosts: true, oAuthConfigurations: [config])
***REMOVED******REMOVED***XCTAssertTrue(authenticator.promptForUntrustedHosts)
***REMOVED******REMOVED***XCTAssertEqual(authenticator.oAuthConfigurations, [config])
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testMakePersistent() async throws {
***REMOVED******REMOVED******REMOVED*** Make sure credential stores are restored.
***REMOVED******REMOVED***addTeardownBlock {
***REMOVED******REMOVED******REMOVED***ArcGISRuntimeEnvironment.credentialStore = ArcGISCredentialStore()
***REMOVED******REMOVED******REMOVED***ArcGISRuntimeEnvironment.networkCredentialStore = NetworkCredentialStore()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** This tests that calling makePersistent tries to sync with the keychain.
***REMOVED******REMOVED***let authenticator = Authenticator()
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await authenticator.makePersistent(access: .whenUnlocked)
***REMOVED******REMOVED******REMOVED***XCTFail("Expected an error to be thrown as unit tests should not have access to the keychain")
***REMOVED*** catch {***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testClearCredentialStores() async {
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.add(
***REMOVED******REMOVED******REMOVED***.staticToken(
***REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "www.arcgis.com")!,
***REMOVED******REMOVED******REMOVED******REMOVED***tokenInfo: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***accessToken: "token",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSSLRequired: false,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***expirationDate: .distantFuture
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let authenticator = Authenticator()
***REMOVED******REMOVED***
***REMOVED******REMOVED***var arcGISCreds = await ArcGISRuntimeEnvironment.credentialStore.credentials
***REMOVED******REMOVED***XCTAssertEqual(arcGISCreds.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await authenticator.clearCredentialStores()
***REMOVED******REMOVED***
***REMOVED******REMOVED***arcGISCreds = await ArcGISRuntimeEnvironment.credentialStore.credentials
***REMOVED******REMOVED***XCTAssertTrue(arcGISCreds.isEmpty)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testChallengeQueue() async throws {
***REMOVED******REMOVED***actor MockQueuedChallenge: QueuedChallenge {
***REMOVED******REMOVED******REMOVED***nonisolated let host: String
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***init(host: String) {
***REMOVED******REMOVED******REMOVED******REMOVED***self.host = host
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***private var isComplete: Bool = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func setCompleted() {
***REMOVED******REMOVED******REMOVED******REMOVED***isComplete = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***func complete() async {
***REMOVED******REMOVED******REMOVED******REMOVED***while !isComplete {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let authenticator = Authenticator()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Give chance for authenticator to start observation
***REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(authenticator.currentChallenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create and enqueue first challenge.
***REMOVED******REMOVED***let challenge = MockQueuedChallenge(host: "host1")
***REMOVED******REMOVED***authenticator.subject.send(challenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure first challenge is published as the current challenge.
***REMOVED******REMOVED***let currentChallenge = await AsyncPublisher(authenticator.$currentChallenge)
***REMOVED******REMOVED******REMOVED***.compactMap( { $0 as? MockQueuedChallenge ***REMOVED***)
***REMOVED******REMOVED******REMOVED***.first(where: { _ in true ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(currentChallenge?.host, "host1")
***REMOVED******REMOVED***XCTAssertNotNil(authenticator.currentChallenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create and enqueue second challenge.
***REMOVED******REMOVED***let challenge2 = MockQueuedChallenge(host: "host2")
***REMOVED******REMOVED***authenticator.subject.send(challenge2)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure first challenge is still the current challenge
***REMOVED******REMOVED***let mockedCurrentChallenge = try XCTUnwrap(authenticator.currentChallenge as? MockQueuedChallenge)
***REMOVED******REMOVED***XCTAssertEqual(mockedCurrentChallenge.host, "host1")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Complete first challenge.
***REMOVED******REMOVED***await challenge.setCompleted()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Check next queued challenge
***REMOVED******REMOVED***let currentChallenge2 = await AsyncPublisher(authenticator.$currentChallenge)
***REMOVED******REMOVED******REMOVED***.compactMap( { $0 as? MockQueuedChallenge ***REMOVED***)
***REMOVED******REMOVED******REMOVED***.dropFirst()
***REMOVED******REMOVED******REMOVED***.first(where: { _ in true ***REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(currentChallenge2?.host, "host2")
***REMOVED******REMOVED***XCTAssertNotNil(authenticator.currentChallenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Complete second challenge.
***REMOVED******REMOVED***await challenge2.setCompleted()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Check next queued challenge, should be nil
***REMOVED******REMOVED***let currentChallenge3 = await AsyncPublisher(authenticator.$currentChallenge)
***REMOVED******REMOVED******REMOVED***.dropFirst()
***REMOVED******REMOVED******REMOVED***.first(where: { _ in true ***REMOVED***)
***REMOVED******REMOVED******REMOVED*** nil coalescing seems required because currentChallenge3 is Optional<Optional<QueuedChallenge>>
***REMOVED******REMOVED***XCTAssertNil(currentChallenge3 ?? nil)
***REMOVED***
***REMOVED***
