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

***REMOVED***/ A configurable object that handles authentication challenges.
@MainActor
public final class Authenticator: ObservableObject {
***REMOVED******REMOVED***/ The OAuth configurations that this authenticator can work with.
***REMOVED***let oAuthUserConfigurations: [OAuthUserConfiguration]
***REMOVED***
***REMOVED******REMOVED***/ A value indicating whether we should prompt the user when encountering an untrusted host.
***REMOVED***var promptForUntrustedHosts: Bool
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
***REMOVED******REMOVED******REMOVED***return .continueWithCredential(try await OAuthUserCredential.credential(for: configuration))
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
