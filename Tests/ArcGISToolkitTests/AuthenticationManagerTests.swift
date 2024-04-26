// Copyright 2023 Esri
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

import XCTest
import ArcGIS
@testable import ArcGISToolkit

final class AuthenticationManagerTests: XCTestCase {
    @MainActor
    func testHandleChallengesUsingAuthenticator() {
        addTeardownBlock {
            ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = nil
            ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = nil
        }
        
        let authenticator = Authenticator()
        ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
        XCTAssertIdentical(ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler as? Authenticator, authenticator)
        XCTAssertIdentical(ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler as? Authenticator, authenticator)
    }
    
    func testMakePersistent() async throws {
        // Make sure credential stores are restored.
        addTeardownBlock {
            ArcGISEnvironment.authenticationManager.arcGISCredentialStore = ArcGISCredentialStore()
            await ArcGISEnvironment.authenticationManager.setNetworkCredentialStore(NetworkCredentialStore())
        }
        
        // This tests that calling setupPersistentCredentialStorage tries to sync with the keychain.
#if targetEnvironment(macCatalyst)
        do {
            try await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlocked)
        } catch {
            XCTFail("Persistent credential storage setup failed")
        }
#elseif !targetEnvironment(macCatalyst)
        do {
            try await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlocked)
            XCTFail("Expected an error to be thrown as unit tests should not have access to the keychain")
        } catch {}
#endif
    }
    
    func testClearCredentialStores() async {
        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(
            PregeneratedTokenCredential(
                url: URL(string: "www.arcgis.com")!,
                tokenInfo: .init(
                    accessToken: "token",
                    expirationDate: .distantFuture,
                    isSSLRequired: false
                )!
            )
        )
        
        XCTAssertEqual(ArcGISEnvironment.authenticationManager.arcGISCredentialStore.credentials.count, 1)
        
        await ArcGISEnvironment.authenticationManager.clearCredentialStores()
        
        XCTAssertTrue(ArcGISEnvironment.authenticationManager.arcGISCredentialStore.credentials.isEmpty)
    }
    
    func testRevokeOAuthTokens() async {
        let result = await ArcGISEnvironment.authenticationManager.revokeOAuthTokens()
        XCTAssertTrue(result)
    }
}
