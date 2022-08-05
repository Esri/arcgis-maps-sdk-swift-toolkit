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

@MainActor final class AuthenticatorTests: XCTestCase {
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
***REMOVED***func testMakePersistent() async throws {
***REMOVED******REMOVED******REMOVED*** Make sure credential stores are restored.
***REMOVED******REMOVED***addTeardownBlock {
***REMOVED******REMOVED******REMOVED***ArcGISRuntimeEnvironment.credentialStore = ArcGISCredentialStore()
***REMOVED******REMOVED******REMOVED***await ArcGISRuntimeEnvironment.setNetworkCredentialStore(NetworkCredentialStore())
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
