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
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***oAuthConfigurations: [OAuthConfiguration] = []
***REMOVED***) {
***REMOVED******REMOVED***self.oAuthConfigurations = oAuthConfigurations
***REMOVED******REMOVED***Task { await observeChallengeQueue() ***REMOVED***
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
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** See if the challenge is a recoverable trust failure, if so then we can
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** challenge the user.  If not, then we perform default handling.
***REMOVED******REMOVED******REMOVED******REMOVED***var secResult = SecTrustResultType.invalid
***REMOVED******REMOVED******REMOVED******REMOVED***SecTrustGetTrustResult(trust, &secResult)
***REMOVED******REMOVED******REMOVED******REMOVED***if secResult != .recoverableTrustFailure {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return (.performDefaultHandling, nil)
***REMOVED******REMOVED******REMOVED***
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
