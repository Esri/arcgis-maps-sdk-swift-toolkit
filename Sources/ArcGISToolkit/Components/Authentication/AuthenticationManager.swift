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

import ArcGIS

public extension AuthenticationManager {
    /// Sets up authenticator as ArcGIS and Network challenge handlers to handle authentication
    /// challenges.
    /// - Parameter authenticator: The authenticator to be used for handling challenges or `nil` to
    /// reset the challenge handlers.
    func handleChallenges(using authenticator: Authenticator?) {
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
    /// - Returns: `true` if successfully revokes tokens for all `OAuthUserCredential`, otherwise
    /// `false`.
    @discardableResult
    func revokeOAuthTokens() async -> Bool {
        let oAuthUserCredentials = arcGISCredentialStore.credentials.compactMap { $0 as? OAuthUserCredential }
        return await withTaskGroup(of: Bool.self, returning: Bool.self) { group in
            for credential in oAuthUserCredentials {
                group.addTask {
                    do {
                        try await credential.revokeToken()
                        return true
                    } catch {
                        return false
                    }
                }
            }
            
            return await group.allSatisfy { $0 == true }
        }
    }
    
    /// Initiates a logout request, invalidating the user's identity within the
    /// web session and removing all associated tokens for all IAP credentials.
    /// - Returns: `true` if all IAP credentials are invalidated, otherwise `false`.
    /// - Since: 200.8
    @discardableResult
    func invalidateIAPCredentials() async -> Bool {
        let iapCredentials = arcGISCredentialStore.credentials.compactMap {
            $0 as? IAPCredential
        }
        return await withTaskGroup(of: Bool.self, returning: Bool.self) { group in
            for credential in iapCredentials {
                group.addTask {
                    do {
                        return try await credential.invalidate()
                    } catch {
                        return false
                    }
                }
            }

            return await group.allSatisfy(\.self)
        }
    }
}
