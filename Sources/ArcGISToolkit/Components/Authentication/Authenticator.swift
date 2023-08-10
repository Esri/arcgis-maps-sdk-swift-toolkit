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

***REMOVED***
***REMOVED***
import Combine

***REMOVED***/ The `Authenticator` is a configurable object that handles authentication challenges. It will
***REMOVED***/ display a user interface when network and ArcGIS authentication challenges occur.
***REMOVED***/
***REMOVED***/ ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203615041-c887d5e3-bb64-469a-a76b-126059329e92.png)
***REMOVED***/
***REMOVED***/ The `Authenticator` has a view modifier that will display a prompt when the `Authenticator` is
***REMOVED***/ asked to handle an authentication challenge. This will handle many different types of
***REMOVED***/ authentication, for example:
***REMOVED***/   - ArcGIS authentication (token and OAuth)
***REMOVED***/   - Integrated Windows Authentication (IWA)
***REMOVED***/   - Client Certificate (PKI)
***REMOVED***/
***REMOVED***/ The `Authenticator` can be configured to support securely persisting credentials to the keychain.
***REMOVED***/
***REMOVED***/ `Authenticator` has the following view modifier:
***REMOVED***/
***REMOVED***/ ```swift
***REMOVED***/ ***REMOVED***/ Presents user experiences for collecting network authentication credentials from the user.
***REMOVED***/ ***REMOVED***/ - Parameter authenticator: The authenticator for which credentials will be prompted.
***REMOVED***/ @ViewBuilder func authenticator(_ authenticator: Authenticator) -> some View
***REMOVED***/ ```
***REMOVED***/ To securely store credentials in the keychain, use the following extension method of `AuthenticationManager`:
***REMOVED***/
***REMOVED***/ ```swift
***REMOVED***/  ***REMOVED***/ Sets up new credential stores that will be persisted to the keychain.
***REMOVED***/ ***REMOVED***/ - Remark: The credentials will be stored in the default access group of the keychain.
***REMOVED***/ ***REMOVED***/ You can find more information about what the default group would be here:
***REMOVED***/ https:***REMOVED***developer.a.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps
***REMOVED***/ ***REMOVED***/ - Parameters:
***REMOVED***/ ***REMOVED***/   - access: When the credentials stored in the keychain can be accessed.
***REMOVED***/ ***REMOVED***/   - synchronizesWithiCloud: A Boolean value indicating whether the credentials are synchronized with iCloud.
***REMOVED***/ public func setupPersistentCredentialStorage(
***REMOVED***/***REMOVED*** access: ArcGIS.KeychainAccess,
***REMOVED***/***REMOVED*** synchronizesWithiCloud: Bool = false
***REMOVED***/ ) async throws
***REMOVED***/ ```
***REMOVED***/
***REMOVED***/ During sign-out, use the following extension methods of `AuthenticationManager`:
***REMOVED***/
***REMOVED***/ ```swift
***REMOVED***/ ***REMOVED***/ Revokes tokens of OAuth user credentials.
***REMOVED***/ func revokeOAuthTokens() async
***REMOVED***/
***REMOVED***/ ***REMOVED***/ Clears all ArcGIS and network credentials from the respective stores.
***REMOVED***/ ***REMOVED***/ Note: This sets up new `URLSessions` so that removed network credentials are respected
***REMOVED***/ ***REMOVED***/ right away.
***REMOVED***/ func clearCredentialStores() async
***REMOVED***/ ```
***REMOVED***/
***REMOVED***/ The Authenticator view modifier will display an alert prompting the user for credentials. If
***REMOVED***/ credentials were persisted to the keychain, the Authenticator will use those instead of
***REMOVED***/ requiring the user to reenter credentials.
***REMOVED***/
***REMOVED***/ Basic usage for displaying the `Authenticator`.
***REMOVED***/
***REMOVED***/ This would typically go in your application's `App` struct.
***REMOVED***/
***REMOVED***/ ```swift
***REMOVED***/ init() {
***REMOVED***/***REMOVED*** ***REMOVED*** Create an authenticator.
***REMOVED***/***REMOVED*** authenticator = Authenticator(
***REMOVED***/***REMOVED******REMOVED*** ***REMOVED*** If you want to use OAuth, uncomment this code:
***REMOVED***/***REMOVED******REMOVED*** ***REMOVED***oAuthConfigurations: [.arcgisDotCom]
***REMOVED***/***REMOVED*** )
***REMOVED***/***REMOVED*** ***REMOVED*** Sets authenticator as ArcGIS and Network challenge handlers to handle authentication
***REMOVED***/***REMOVED*** ***REMOVED*** challenges.
***REMOVED***/***REMOVED*** ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
***REMOVED***/ ***REMOVED***
***REMOVED***/
***REMOVED***/ var body: some SwiftUI.Scene {
***REMOVED***/***REMOVED*** WindowGroup {
***REMOVED***/***REMOVED******REMOVED*** HomeView()
***REMOVED***/***REMOVED******REMOVED******REMOVED*** .authenticator(authenticator)
***REMOVED***/***REMOVED******REMOVED******REMOVED*** .task {
***REMOVED***/***REMOVED******REMOVED******REMOVED******REMOVED*** ***REMOVED*** Here we setup credential stores to be persistent, which means that it will
***REMOVED***/***REMOVED******REMOVED******REMOVED******REMOVED*** ***REMOVED*** synchronize with the keychain for storing credentials.
***REMOVED***/***REMOVED******REMOVED******REMOVED******REMOVED*** ***REMOVED*** It also means that a user can sign in without having to be prompted for
***REMOVED***/***REMOVED******REMOVED******REMOVED******REMOVED*** ***REMOVED*** credentials. Once credentials are cleared from the stores ("sign-out"),
***REMOVED***/***REMOVED******REMOVED******REMOVED******REMOVED*** ***REMOVED*** then the user will need to be prompted once again.
***REMOVED***/***REMOVED******REMOVED******REMOVED******REMOVED*** try? await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
***REMOVED***/***REMOVED*** ***REMOVED***
***REMOVED***/ ***REMOVED***
***REMOVED***/ ***REMOVED***
***REMOVED***/ ```
***REMOVED***/ To see the `Authenticator` in action, check out the [Authentication Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/AuthenticationExample)
***REMOVED***/ and refer to [AuthenticationApp.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/AuthenticationExample/AuthenticationExample/AuthenticationApp.swift)
***REMOVED***/ in the project.
@MainActor
public final class Authenticator: ObservableObject {
***REMOVED******REMOVED***/ A value indicating whether we should prompt the user when encountering an untrusted host.
***REMOVED***let promptForUntrustedHosts: Bool
***REMOVED******REMOVED***/ The OAuth configurations that this authenticator can work with.
***REMOVED***let oAuthUserConfigurations: [OAuthUserConfiguration]
***REMOVED***
***REMOVED******REMOVED***/ Creates an authenticator.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - promptForUntrustedHosts: A value indicating whether we should prompt the user when
***REMOVED******REMOVED***/   encountering an untrusted host.
***REMOVED******REMOVED***/   - oAuthConfigurations: The OAuth configurations that this authenticator can work with.
***REMOVED***public init(
***REMOVED******REMOVED***promptForUntrustedHosts: Bool = false,
***REMOVED******REMOVED***oAuthUserConfigurations: [OAuthUserConfiguration] = []
***REMOVED***) {
***REMOVED******REMOVED***self.promptForUntrustedHosts = promptForUntrustedHosts
***REMOVED******REMOVED***self.oAuthUserConfigurations = oAuthUserConfigurations
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current challenge.
***REMOVED******REMOVED***/ This property is not set for OAuth challenges.
***REMOVED***@Published var currentChallenge: ChallengeContinuation?
***REMOVED***

extension Authenticator: ArcGISAuthenticationChallengeHandler {
***REMOVED***public func handleArcGISAuthenticationChallenge(
***REMOVED******REMOVED***_ challenge: ArcGISAuthenticationChallenge
***REMOVED***) async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED******REMOVED*** Alleviates an error with "already presenting".
***REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create the correct challenge type.
***REMOVED******REMOVED***if let configuration = oAuthUserConfigurations.first(where: { $0.canBeUsed(for: challenge.requestURL) ***REMOVED***) {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***return .continueWithCredential(try await OAuthUserCredential.credential(for: configuration))
***REMOVED******REMOVED*** catch is CancellationError {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If user cancels the creation of OAuth user credential then catch the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** cancellation error and cancel the challenge. This will make the request which
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** issued the challenge fail with `ArcGISChallengeCancellationError`.
***REMOVED******REMOVED******REMOVED******REMOVED***return .cancel
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***let tokenChallengeContinuation = TokenChallengeContinuation(arcGISChallenge: challenge)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Set the current challenge, which will present the UX.
***REMOVED******REMOVED******REMOVED***self.currentChallenge = tokenChallengeContinuation
***REMOVED******REMOVED******REMOVED***defer { self.currentChallenge = nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Wait for it to complete and return the resulting disposition.
***REMOVED******REMOVED******REMOVED***return try await tokenChallengeContinuation.value.get()
***REMOVED***
***REMOVED***
***REMOVED***

extension Authenticator: NetworkAuthenticationChallengeHandler {
***REMOVED***public func handleNetworkAuthenticationChallenge(
***REMOVED******REMOVED***_ challenge: NetworkAuthenticationChallenge
***REMOVED***) async -> NetworkAuthenticationChallenge.Disposition  {
***REMOVED******REMOVED******REMOVED*** If `promptForUntrustedHosts` is `false` then perform default handling
***REMOVED******REMOVED******REMOVED*** for server trust challenges.
***REMOVED******REMOVED***guard promptForUntrustedHosts || challenge.kind != .serverTrust else {
***REMOVED******REMOVED******REMOVED***return .continueWithoutCredential
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let challengeContinuation = NetworkChallengeContinuation(networkChallenge: challenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Alleviates an error with "already presenting".
***REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set the current challenge, which will present the UX.
***REMOVED******REMOVED***self.currentChallenge = challengeContinuation
***REMOVED******REMOVED***defer { self.currentChallenge = nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for it to complete and return the resulting disposition.
***REMOVED******REMOVED***return await challengeContinuation.value
***REMOVED***
***REMOVED***
