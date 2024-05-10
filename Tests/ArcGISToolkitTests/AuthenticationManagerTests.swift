***REMOVED*** Copyright 2023 Esri
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

import XCTest
***REMOVED***
@testable ***REMOVED***Toolkit

final class AuthenticationManagerTests: XCTestCase {
***REMOVED***@MainActor
***REMOVED***func testHandleChallengesUsingAuthenticator() {
***REMOVED******REMOVED***addTeardownBlock {
***REMOVED******REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = nil
***REMOVED******REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let authenticator = Authenticator()
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
***REMOVED******REMOVED***XCTAssertIdentical(ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler as? Authenticator, authenticator)
***REMOVED******REMOVED***XCTAssertIdentical(ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler as? Authenticator, authenticator)
***REMOVED***
***REMOVED***
***REMOVED***func testMakePersistent() async throws {
***REMOVED******REMOVED******REMOVED*** Make sure credential stores are restored.
***REMOVED******REMOVED***addTeardownBlock {
***REMOVED******REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISCredentialStore = ArcGISCredentialStore()
***REMOVED******REMOVED******REMOVED***await ArcGISEnvironment.authenticationManager.setNetworkCredentialStore(NetworkCredentialStore())
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** This tests that calling setupPersistentCredentialStorage tries to sync with the keychain.
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlocked)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail("Persistent credential storage setup failed")
***REMOVED***
#elseif !targetEnvironment(macCatalyst)
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlocked)
***REMOVED******REMOVED******REMOVED***XCTFail("Expected an error to be thrown as unit tests should not have access to the keychain")
***REMOVED*** catch {***REMOVED***
#endif
***REMOVED***
***REMOVED***
***REMOVED***func testClearCredentialStores() async {
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(
***REMOVED******REMOVED******REMOVED***PregeneratedTokenCredential(
***REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "www.arcgis.com")!,
***REMOVED******REMOVED******REMOVED******REMOVED***tokenInfo: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***accessToken: "token",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***expirationDate: .distantFuture,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSSLRequired: false
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(ArcGISEnvironment.authenticationManager.arcGISCredentialStore.credentials.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await ArcGISEnvironment.authenticationManager.clearCredentialStores()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(ArcGISEnvironment.authenticationManager.arcGISCredentialStore.credentials.isEmpty)
***REMOVED***
***REMOVED***
***REMOVED***func testRevokeOAuthTokens() async {
***REMOVED******REMOVED***let result = await ArcGISEnvironment.authenticationManager.revokeOAuthTokens()
***REMOVED******REMOVED***XCTAssertTrue(result)
***REMOVED***
***REMOVED***
