// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS

public extension AuthenticationManager {
    /// Sets up authenticator as ArcGIS and Network challenge handlers to handle authentication
    /// challenges.
    /// - Parameter authenticator: The authenticator to be used for handling challenges.
    func handleChallenges(using authenticator: Authenticator) {
        arcGISAuthenticationChallengeHandler = authenticator
        networkAuthenticationChallengeHandler = authenticator
    }
    
    /// Sets up new credential stores that will be persisted to the keychain.
    /// - Remark: The credentials will be stored in the default access group of the keychain.
    /// You can find more information about what the default group would be here:
    /// https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps
    /// - Parameters:
    ///   - access: When the credentials stored in the keychain can be accessed.
    ///   - synchronizesWithiCloud: A Boolean value indicating whether the credentials are synchronized with iCloud.
    func setupPersistentCredentialStorage(
        access: ArcGIS.KeychainAccess,
        synchronizesWithiCloud: Bool = false
    ) async throws {
        let previousArcGISCredentialStore = arcGISCredentialStore
        
        // Set a persistent ArcGIS credential store on the ArcGIS environment.
        arcGISCredentialStore = try await .makePersistent(
            access: access,
            synchronizesWithiCloud: synchronizesWithiCloud
        )
        
        do {
            // Set a persistent network credential store on the ArcGIS environment.
            await setNetworkCredentialStore(
                try await .makePersistent(access: access, synchronizesWithiCloud: synchronizesWithiCloud)
            )
        } catch {
            // If making the shared network credential store persistent fails,
            // then restore the ArcGIS credential store.
            arcGISCredentialStore = previousArcGISCredentialStore
            throw error
        }
    }
    
    /// Clears all ArcGIS and network credentials from the respective stores.
    /// Note: This sets up new `URLSessions` so that removed network credentials are respected
    /// right away.
    func clearCredentialStores() async {
        // Clear ArcGIS Credentials.
        arcGISCredentialStore.removeAll()
        
        // Clear network credentials.
        await networkCredentialStore.removeAll()
    }
    
    /// Revokes tokens of OAuth user credentials.
    func revokeOAuthTokens() async {
        let oAuthUserCredentials = arcGISCredentialStore.credentials.compactMap { $0 as? OAuthUserCredential }
        await withTaskGroup(of: Void.self) { group in
            for credential in oAuthUserCredentials {
                group.addTask {
                    try? await credential.revokeToken()
                }
            }
            
            // Make sure that all tasks complete.
            await group.waitForAll()
        }
    }
}
