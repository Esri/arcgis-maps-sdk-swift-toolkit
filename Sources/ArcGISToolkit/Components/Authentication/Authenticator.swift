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

public final class QueuedChallenge {
***REMOVED***let challenge: ArcGISAuthenticationChallenge
***REMOVED***
***REMOVED***init(challenge: ArcGISAuthenticationChallenge) {
***REMOVED******REMOVED***self.challenge = challenge
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
***REMOVED***@Streamed
***REMOVED***private var _result: Result<ArcGISAuthenticationChallenge.Disposition, Error>?
***REMOVED***
***REMOVED***var result: Result<ArcGISAuthenticationChallenge.Disposition, Error> {
***REMOVED******REMOVED***get async {
***REMOVED******REMOVED******REMOVED***await $_result.compactMap({ $0 ***REMOVED***).first(where: { _ in true ***REMOVED***)!
***REMOVED***
***REMOVED***
***REMOVED***

extension QueuedChallenge: Identifiable {***REMOVED***

@MainActor
public final class Authenticator: ObservableObject {
***REMOVED***public init() {
***REMOVED******REMOVED***Task { await observeChallengeQueue() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func observeChallengeQueue() async {
***REMOVED******REMOVED***for await queuedChallenge in challengeQueue {
***REMOVED******REMOVED******REMOVED***print("  -- handing challenge")
***REMOVED******REMOVED******REMOVED***currentChallenge = queuedChallenge
***REMOVED******REMOVED******REMOVED***_ = await queuedChallenge.result
***REMOVED******REMOVED******REMOVED***currentChallenge = nil
***REMOVED***
***REMOVED***

***REMOVED***@Published
***REMOVED***public var currentChallenge: QueuedChallenge?
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
***REMOVED******REMOVED***print("-- high level challenge receieved")
***REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard challenge.proposedCredential == nil else {
***REMOVED******REMOVED******REMOVED***print("  -- performing default handling")
***REMOVED******REMOVED******REMOVED***return .performDefaultHandling
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let queuedChallenge = QueuedChallenge(challenge: challenge)
***REMOVED******REMOVED***subject.send(queuedChallenge)
***REMOVED******REMOVED***return try await queuedChallenge.result.get()
***REMOVED***
***REMOVED***
***REMOVED***public func handleURLSessionChallenge(
***REMOVED******REMOVED***_ challenge: URLAuthenticationChallenge,
***REMOVED******REMOVED***scope: URLAuthenticationChallengeScope
***REMOVED***) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
***REMOVED******REMOVED***if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
***REMOVED******REMOVED***   let trust = challenge.protectionSpace.serverTrust {
***REMOVED******REMOVED******REMOVED******REMOVED*** This will cause a self-signed certificate to be trusted.
***REMOVED******REMOVED******REMOVED***return (.useCredential, URLCredential(trust: trust))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return (.performDefaultHandling, nil)
***REMOVED***
***REMOVED***
***REMOVED***
