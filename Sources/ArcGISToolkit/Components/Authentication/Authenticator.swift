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

@MainActor
public final class Authenticator: ObservableObject {
***REMOVED***let oAuthConfigurations: [OAuthConfiguration]
***REMOVED***var trustedHosts: [String] = []
***REMOVED***let hasPersistentStore: Bool
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***oAuthConfigurations: [OAuthConfiguration] = []
***REMOVED***) {
***REMOVED******REMOVED***self.oAuthConfigurations = oAuthConfigurations
***REMOVED******REMOVED***hasPersistentStore = false
***REMOVED******REMOVED***Task { await observeChallengeQueue() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Foo...
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - oAuthConfigurations: Foo...
***REMOVED******REMOVED***/   - access: When the item can be accessed.
***REMOVED******REMOVED***/   - accessGroup: The access group that the item will be in.
***REMOVED******REMOVED***/   - isSynchronizable: A value indicating whether the item is synchronized with iCloud.
***REMOVED***public init(
***REMOVED******REMOVED***oAuthConfigurations: [OAuthConfiguration] = [],
***REMOVED******REMOVED***access: KeychainAccess,
***REMOVED******REMOVED***accessGroup: String,
***REMOVED******REMOVED***isSynchronizable: Bool
***REMOVED***) async throws {
***REMOVED******REMOVED***ArcGISURLSession.credentialStore = try await .makePersistent(
***REMOVED******REMOVED******REMOVED***access: .whenUnlockedThisDeviceOnly,
***REMOVED******REMOVED******REMOVED***accessGroup: "",
***REMOVED******REMOVED******REMOVED***isSynchronizable: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.oAuthConfigurations = oAuthConfigurations
***REMOVED******REMOVED***hasPersistentStore = true
***REMOVED***
***REMOVED***
***REMOVED***public func clearCredentialStores() async {
***REMOVED******REMOVED******REMOVED*** Clear ArcGIS Credentials.
***REMOVED******REMOVED***await ArcGISURLSession.credentialStore.removeAll()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Clear URLCredentials.
***REMOVED******REMOVED***URLCredentialStorage.shared.removeAllCredentials()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** We have to reset the sessions for URLCredential storage to respect the removed credentials
***REMOVED******REMOVED***ArcGISURLSession.shared = ArcGISURLSession.makeDefaultSharedSession()
***REMOVED******REMOVED***ArcGISURLSession.sharedBackground = ArcGISURLSession.makeDefaultSharedBackgroundSession()
***REMOVED***
***REMOVED***
***REMOVED***private func observeChallengeQueue() async {
***REMOVED******REMOVED***for await queuedChallenge in challengeQueue {
***REMOVED******REMOVED******REMOVED***if let queuedArcGISChallenge = queuedChallenge as? QueuedArcGISChallenge,
***REMOVED******REMOVED******REMOVED***   let url = queuedArcGISChallenge.arcGISChallenge.request.url,
***REMOVED******REMOVED******REMOVED***   let config = oAuthConfigurations.first(where: { $0.canBeUsed(for: url) ***REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** For an OAuth challenge, we create the credential and resume.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Creating the OAuth credential will present the OAuth login view.
***REMOVED******REMOVED******REMOVED******REMOVED***queuedArcGISChallenge.resume(with: .oAuth(configuration: config))
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Set the current challenge, this should show the challenge view.
***REMOVED******REMOVED******REMOVED******REMOVED***currentChallenge = IdentifiableQueuedChallenge(queuedChallenge: queuedChallenge)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Wait for the queued challenge to finish.
***REMOVED******REMOVED******REMOVED******REMOVED***await queuedChallenge.complete()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Set the current challenge to `nil`, this should dismiss the challenge view.
***REMOVED******REMOVED******REMOVED******REMOVED***currentChallenge = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***@Published
***REMOVED***public var currentChallenge: IdentifiableQueuedChallenge?
***REMOVED***
***REMOVED***private var subject = PassthroughSubject<QueuedChallenge, Never>()
***REMOVED***private var challengeQueue: AsyncPublisher<AnyPublisher<QueuedChallenge, Never>> {
***REMOVED******REMOVED***AsyncPublisher(
***REMOVED******REMOVED******REMOVED***subject
***REMOVED******REMOVED******REMOVED******REMOVED***.buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
***REMOVED******REMOVED******REMOVED******REMOVED***.eraseToAnyPublisher()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension Authenticator: AuthenticationChallengeHandler {
***REMOVED***public func handleArcGISChallenge(
***REMOVED******REMOVED***_ challenge: ArcGISAuthenticationChallenge
***REMOVED***) async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED***guard challenge.proposedCredential == nil else {
***REMOVED******REMOVED******REMOVED***return .performDefaultHandling
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Queue up the challenge.
***REMOVED******REMOVED***let queuedChallenge = QueuedArcGISChallenge(arcGISChallenge: challenge)
***REMOVED******REMOVED***subject.send(queuedChallenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for it to complete and return the resulting disposition.
***REMOVED******REMOVED***switch await queuedChallenge.response {
***REMOVED******REMOVED***case .tokenCredential(let username, let password):
***REMOVED******REMOVED******REMOVED***return try await .useCredential(.token(challenge: challenge, username: username, password: password))
***REMOVED******REMOVED***case .oAuth(let configuration):
***REMOVED******REMOVED******REMOVED***return try await .useCredential(.oauth(configuration: configuration))
***REMOVED******REMOVED***case .cancel:
***REMOVED******REMOVED******REMOVED***return .cancelAuthenticationChallenge
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func handleURLSessionChallenge(
***REMOVED******REMOVED***_ challenge: URLAuthenticationChallenge,
***REMOVED******REMOVED***scope: URLAuthenticationChallengeScope
***REMOVED***) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
***REMOVED******REMOVED***guard challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodDefault else {
***REMOVED******REMOVED******REMOVED***return (.performDefaultHandling, nil)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard challenge.proposedCredential == nil else {
***REMOVED******REMOVED******REMOVED***return (.performDefaultHandling, nil)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Check for server trust challenge.
***REMOVED******REMOVED***if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
***REMOVED******REMOVED***   let trust = challenge.protectionSpace.serverTrust {
***REMOVED******REMOVED******REMOVED***if trustedHosts.contains(challenge.protectionSpace.host) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If the host is already trusted, then continue trusting it.
***REMOVED******REMOVED******REMOVED******REMOVED***return (.useCredential, URLCredential(trust: trust))
***REMOVED******REMOVED*** else if !trust.isRecoverableTrustFailure {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** See if the challenge is a recoverable trust failure, if so then we can
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** challenge the user.  If not, then we perform default handling.
***REMOVED******REMOVED******REMOVED******REMOVED***return (.performDefaultHandling, nil)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Queue up the url challenge.
***REMOVED******REMOVED***let queuedChallenge = QueuedURLChallenge(urlChallenge: challenge)
***REMOVED******REMOVED***subject.send(queuedChallenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Respond accordingly.
***REMOVED******REMOVED***switch await queuedChallenge.response {
***REMOVED******REMOVED***case .cancel:
***REMOVED******REMOVED******REMOVED***return (.cancelAuthenticationChallenge, nil)
***REMOVED******REMOVED***case .trustHost:
***REMOVED******REMOVED******REMOVED***if let trust = challenge.protectionSpace.serverTrust {
***REMOVED******REMOVED******REMOVED******REMOVED***trustedHosts.append(challenge.protectionSpace.host)
***REMOVED******REMOVED******REMOVED******REMOVED***return (.useCredential, URLCredential(trust: trust))
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return (.performDefaultHandling, nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .userCredential(let user, let password):
***REMOVED******REMOVED******REMOVED***return (.useCredential, URLCredential(user: user, password: password, persistence: .forSession))
***REMOVED***
***REMOVED***
***REMOVED***

extension SecTrust {
***REMOVED***var isRecoverableTrustFailure: Bool {
***REMOVED******REMOVED***var result = SecTrustResultType.invalid
***REMOVED******REMOVED***SecTrustGetTrustResult(self, &result)
***REMOVED******REMOVED***return result == .recoverableTrustFailure
***REMOVED***
***REMOVED***

extension URLCredentialStorage {
***REMOVED******REMOVED***func removeCredentials(for host: String) {
***REMOVED******REMOVED******REMOVED***allCredentials.forEach { (protectionSpace: URLProtectionSpace, usernamesToCredentials: [String : URLCredential]) in
***REMOVED******REMOVED******REMOVED******REMOVED***guard protectionSpace.host.lowercased() == host.lowercased() else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***for credential in usernamesToCredentials.values {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***remove(credential, for: protectionSpace)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***func removeAllCredentials() {
***REMOVED******REMOVED***allCredentials.forEach { (protectionSpace: URLProtectionSpace, usernamesToCredentials: [String : URLCredential]) in
***REMOVED******REMOVED******REMOVED***for credential in usernamesToCredentials.values {
***REMOVED******REMOVED******REMOVED******REMOVED***remove(credential, for: protectionSpace)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
