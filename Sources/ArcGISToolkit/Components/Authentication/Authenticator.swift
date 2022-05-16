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

public final class QueuedArcGISChallenge: QueuedChallenge {
***REMOVED***let arcGISChallenge: ArcGISAuthenticationChallenge
***REMOVED***
***REMOVED***init(arcGISChallenge: ArcGISAuthenticationChallenge) {
***REMOVED******REMOVED***self.arcGISChallenge = arcGISChallenge
***REMOVED***

***REMOVED***func resume(with result: Result<ArcGISAuthenticationChallenge.Disposition, Error>) {
***REMOVED******REMOVED***guard _result == nil else { return ***REMOVED***
***REMOVED******REMOVED***_result = result
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***guard _result == nil else { return ***REMOVED***
***REMOVED******REMOVED***_result = .failure(CancellationError())
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Use a streamed property because we need to support multiple listeners
***REMOVED******REMOVED***/ to know when the challenge completed.
***REMOVED***@Streamed
***REMOVED***private var _result: Result<ArcGISAuthenticationChallenge.Disposition, Error>?
***REMOVED***
***REMOVED***var disposition: ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***try await $_result
***REMOVED******REMOVED******REMOVED******REMOVED***.compactMap({ $0 ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.first(where: { _ in true ***REMOVED***)!
***REMOVED******REMOVED******REMOVED******REMOVED***.get()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func complete() async {
***REMOVED******REMOVED***_ = try? await disposition
***REMOVED***
***REMOVED***

public final class QueuedURLChallenge: QueuedChallenge {
***REMOVED***let urlChallenge: URLAuthenticationChallenge
***REMOVED***
***REMOVED***init(urlChallenge: URLAuthenticationChallenge) {
***REMOVED******REMOVED***self.urlChallenge = urlChallenge
***REMOVED***

***REMOVED***func resume(with result: Result<URLSession.AuthChallengeDisposition, Error>) {
***REMOVED******REMOVED***guard _result == nil else { return ***REMOVED***
***REMOVED******REMOVED***_result = result
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***guard _result == nil else { return ***REMOVED***
***REMOVED******REMOVED***_result = .failure(CancellationError())
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Use a streamed property because we need to support multiple listeners
***REMOVED******REMOVED***/ to know when the challenge completed.
***REMOVED***@Streamed
***REMOVED***private var _result: Result<URLSession.AuthChallengeDisposition, Error>?
***REMOVED***
***REMOVED***var disposition: URLSession.AuthChallengeDisposition {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***try await $_result
***REMOVED******REMOVED******REMOVED******REMOVED***.compactMap({ $0 ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.first(where: { _ in true ***REMOVED***)!
***REMOVED******REMOVED******REMOVED******REMOVED***.get()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func complete() async {
***REMOVED******REMOVED***_ = try? await disposition
***REMOVED***
***REMOVED***

public protocol QueuedChallenge: AnyObject {
***REMOVED***func complete() async
***REMOVED***

@MainActor
public final class Authenticator: ObservableObject {
***REMOVED***let oAuthConfigurations: [OAuthConfiguration]
***REMOVED***let trustedHosts: [String]
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***oAuthConfigurations: [OAuthConfiguration] = [],
***REMOVED******REMOVED***trustedHosts: [String] = []
***REMOVED***) {
***REMOVED******REMOVED***self.oAuthConfigurations = oAuthConfigurations
***REMOVED******REMOVED***self.trustedHosts = trustedHosts
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
***REMOVED******REMOVED******REMOVED******REMOVED***queuedArcGISChallenge.resume(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: await Result {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.useCredential(try await .oauth(configuration: config))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
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

public struct IdentifiableQueuedChallenge {
***REMOVED***public let queuedChallenge: QueuedChallenge
***REMOVED***

extension IdentifiableQueuedChallenge: Identifiable {
***REMOVED***public var id: ObjectIdentifier { ObjectIdentifier(queuedChallenge) ***REMOVED***
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
***REMOVED******REMOVED***return try await queuedChallenge.disposition
***REMOVED***
***REMOVED***
***REMOVED***public func handleURLSessionChallenge(
***REMOVED******REMOVED***_ challenge: URLAuthenticationChallenge,
***REMOVED******REMOVED***scope: URLAuthenticationChallengeScope
***REMOVED***) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
***REMOVED******REMOVED***if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
***REMOVED******REMOVED***   let trust = challenge.protectionSpace.serverTrust,
***REMOVED******REMOVED***   trustedHosts.contains(challenge.protectionSpace.host) {
***REMOVED******REMOVED******REMOVED******REMOVED*** This will cause a self-signed certificate to be trusted.
***REMOVED******REMOVED******REMOVED***return (.useCredential, URLCredential(trust: trust))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Queue up the challenge.
***REMOVED******REMOVED******REMOVED***let queuedChallenge = QueuedURLChallenge(urlChallenge: challenge)
***REMOVED******REMOVED******REMOVED***subject.send(queuedChallenge)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return (.performDefaultHandling, nil)
***REMOVED***
***REMOVED***
***REMOVED***
