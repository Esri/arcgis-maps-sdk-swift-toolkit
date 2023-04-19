***REMOVED*** Copyright 2023 Esri.

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

public extension AuthenticationManager {
***REMOVED******REMOVED***/ Sets up authenticator as ArcGIS and Network challenge handlers to handle authentication
***REMOVED******REMOVED***/ challenges.
***REMOVED******REMOVED***/ - Parameter authenticator: The authenticator to be used for handling challenges or `nil` to
***REMOVED******REMOVED***/ reset the challenge handlers.
***REMOVED***func handleChallenges(using authenticator: Authenticator?) {
***REMOVED******REMOVED***arcGISAuthenticationChallengeHandler = authenticator
***REMOVED******REMOVED***networkAuthenticationChallengeHandler = authenticator
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets up new credential stores that will be persisted to the keychain.
***REMOVED******REMOVED***/ - Remark: The credentials will be stored in the default access group of the keychain.
***REMOVED******REMOVED***/ You can find more information about what the default group would be here:
***REMOVED******REMOVED***/ https:***REMOVED***developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - access: When the credentials stored in the keychain can be accessed.
***REMOVED******REMOVED***/   - synchronizesWithiCloud: A Boolean value indicating whether the credentials are synchronized with iCloud.
***REMOVED***func setupPersistentCredentialStorage(
***REMOVED******REMOVED***access: ArcGIS.KeychainAccess,
***REMOVED******REMOVED***synchronizesWithiCloud: Bool = false
***REMOVED***) async throws {
***REMOVED******REMOVED***let previousArcGISCredentialStore = arcGISCredentialStore
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set a persistent ArcGIS credential store on the ArcGIS environment.
***REMOVED******REMOVED***arcGISCredentialStore = try await .makePersistent(
***REMOVED******REMOVED******REMOVED***access: access,
***REMOVED******REMOVED******REMOVED***synchronizesWithiCloud: synchronizesWithiCloud
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED*** Set a persistent network credential store on the ArcGIS environment.
***REMOVED******REMOVED******REMOVED***await setNetworkCredentialStore(
***REMOVED******REMOVED******REMOVED******REMOVED***try await .makePersistent(access: access, synchronizesWithiCloud: synchronizesWithiCloud)
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED*** If making the shared network credential store persistent fails,
***REMOVED******REMOVED******REMOVED******REMOVED*** then restore the ArcGIS credential store.
***REMOVED******REMOVED******REMOVED***arcGISCredentialStore = previousArcGISCredentialStore
***REMOVED******REMOVED******REMOVED***throw error
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Clears all ArcGIS and network credentials from the respective stores.
***REMOVED******REMOVED***/ Note: This sets up new `URLSessions` so that removed network credentials are respected
***REMOVED******REMOVED***/ right away.
***REMOVED***func clearCredentialStores() async {
***REMOVED******REMOVED******REMOVED*** Clear ArcGIS Credentials.
***REMOVED******REMOVED***arcGISCredentialStore.removeAll()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Clear network credentials.
***REMOVED******REMOVED***await networkCredentialStore.removeAll()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Revokes tokens of OAuth user credentials.
***REMOVED******REMOVED***/ - Returns: `true` if successfully revokes tokens for all `OAuthUserCredential`, otherwise
***REMOVED******REMOVED***/ `false`.
***REMOVED***@discardableResult
***REMOVED***func revokeOAuthTokens() async -> Bool {
***REMOVED******REMOVED***let oAuthUserCredentials = arcGISCredentialStore.credentials.compactMap { $0 as? OAuthUserCredential ***REMOVED***
***REMOVED******REMOVED***return await withTaskGroup(of: Bool.self, returning: Bool.self) { group in
***REMOVED******REMOVED******REMOVED***for credential in oAuthUserCredentials {
***REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await credential.revokeToken()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return await group.allSatisfy { $0 == true ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
