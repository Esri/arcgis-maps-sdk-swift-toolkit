***REMOVED*** Copyright 2022 Esri
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

***REMOVED***
import Combine
import CryptoTokenKit

***REMOVED***/ The `Authenticator` is a configurable object that handles authentication challenges. It will
***REMOVED***/ display a user interface when network and ArcGIS authentication challenges occur.
***REMOVED***/
***REMOVED***/ ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203615041-c887d5e3-bb64-469a-a76b-126059329e92.png)
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/ 
***REMOVED***/ The `Authenticator` has a view modifier that will display a prompt when the `Authenticator` is
***REMOVED***/ asked to handle an authentication challenge. This will handle many different types of
***REMOVED***/ authentication, for example:
***REMOVED***/
***REMOVED***/   - ArcGIS authentication (token and OAuth)
***REMOVED***/   - Integrated Windows Authentication (IWA)
***REMOVED***/   - Client Certificate (PKI)
***REMOVED***/
***REMOVED***/ The `Authenticator` can be configured to support securely persisting credentials to the keychain.
***REMOVED***/
***REMOVED***/ `Authenticator` is accessible via a modifier on `View`:
***REMOVED***/
***REMOVED***/ ```swift
***REMOVED***/ ***REMOVED***/ Presents user experiences for collecting network authentication credentials from the user.
***REMOVED***/ ***REMOVED***/ - Parameter authenticator: The authenticator for which credentials will be prompted.
***REMOVED***/ @ViewBuilder func authenticator(_ authenticator: Authenticator) -> some View
***REMOVED***/ ```
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ The `authenticator(_:)` view modifier will display an alert prompting the user for credentials. If
***REMOVED***/ credentials were persisted to the keychain, the authenticator will use those instead of
***REMOVED***/ requiring the user to re-enter credentials.
***REMOVED***/
***REMOVED***/ To see the `Authenticator` in action, check out the [Authentication Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/AuthenticationExample)
***REMOVED***/ and refer to [AuthenticationApp.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/AuthenticationExample/AuthenticationExample/AuthenticationApp.swift).
***REMOVED***/ To learn more about using the `Authenticator`, see the <doc:AuthenticatorTutorial>.
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
***REMOVED***) async -> NetworkAuthenticationChallenge.Disposition {
***REMOVED******REMOVED******REMOVED*** If `promptForUntrustedHosts` is `false` then perform default handling
***REMOVED******REMOVED******REMOVED*** for server trust challenges.
***REMOVED******REMOVED***guard promptForUntrustedHosts || challenge.kind != .serverTrust else {
***REMOVED******REMOVED******REMOVED***return .continueWithoutCredential
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If the smart card is connected to the device then a personal identity verification (PIV)
***REMOVED******REMOVED******REMOVED*** token is available in the `TKTokenWatcher().tokenIDs`. Create a smart card network
***REMOVED******REMOVED******REMOVED*** credential with first available PIV token and continue with credential.
***REMOVED******REMOVED***if challenge.kind == .clientCertificate,
***REMOVED******REMOVED***   let pivToken = TKTokenWatcher().tokenIDs.filter({ $0.localizedCaseInsensitiveContains("pivtoken") ***REMOVED***).first,
***REMOVED******REMOVED***   let credential = try? NetworkCredential.smartCard(pivToken: pivToken) {
***REMOVED******REMOVED******REMOVED***return .continueWithCredential(credential)
***REMOVED*** else if challenge.kind == .negotiate {
***REMOVED******REMOVED******REMOVED******REMOVED*** Reject the negotiate challenge so next authentication protection
***REMOVED******REMOVED******REMOVED******REMOVED*** space is tried.
***REMOVED******REMOVED******REMOVED***return .rejectProtectionSpace
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
