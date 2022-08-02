// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
@testable import ArcGISToolkit
import ArcGIS
import Combine

@MainActor final class AuthenticatorTests: XCTestCase {
    func testInit() {
        let config = OAuthConfiguration(
            portalURL: URL(string:"www.arcgis.com")!,
            clientID: "client id",
            redirectURL: URL(string:"myapp://oauth")!
        )
        let authenticator = Authenticator(promptForUntrustedHosts: true, oAuthConfigurations: [config])
        XCTAssertTrue(authenticator.promptForUntrustedHosts)
        XCTAssertEqual(authenticator.oAuthConfigurations, [config])
    }
    
    func testMakePersistent() async throws {
        // Make sure credential stores are restored.
        addTeardownBlock {
            ArcGISRuntimeEnvironment.credentialStore = ArcGISCredentialStore()
            ArcGISRuntimeEnvironment.networkCredentialStore = NetworkCredentialStore()
        }
        
        // This tests that calling makePersistent tries to sync with the keychain.
        let authenticator = Authenticator()
        do {
            try await authenticator.makePersistent(access: .whenUnlocked)
            XCTFail("Expected an error to be thrown as unit tests should not have access to the keychain")
        } catch {}
    }
    
    func testClearCredentialStores() async {
        await ArcGISRuntimeEnvironment.credentialStore.add(
            .staticToken(
                url: URL(string: "www.arcgis.com")!,
                tokenInfo: .init(
                    accessToken: "token",
                    isSSLRequired: false,
                    expirationDate: .distantFuture
                )!
            )
        )
        
        let authenticator = Authenticator()
        
        var arcGISCreds = await ArcGISRuntimeEnvironment.credentialStore.credentials
        XCTAssertEqual(arcGISCreds.count, 1)
        
        await authenticator.clearCredentialStores()
        
        arcGISCreds = await ArcGISRuntimeEnvironment.credentialStore.credentials
        XCTAssertTrue(arcGISCreds.isEmpty)
    }
}
