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

public final class Foo {
***REMOVED***let challenge: ArcGISAuthenticationChallenge
***REMOVED***var continuation: CheckedContinuation<ArcGISAuthenticationChallenge.Disposition, Error>?
***REMOVED***
***REMOVED***init(challenge: ArcGISAuthenticationChallenge) {
***REMOVED******REMOVED***print("***REMOVED***-- initing foo: \(challenge.request.url!)")
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED***

***REMOVED***func resume(with result: Result<ArcGISAuthenticationChallenge.Disposition, Error>) {
***REMOVED******REMOVED***continuation?.resume(with: result)
***REMOVED******REMOVED***continuation = nil
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***continuation?.resume(throwing: CancellationError())
***REMOVED******REMOVED***continuation = nil
***REMOVED***
***REMOVED***
***REMOVED***func waitForChallengeToBeHandled() async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED***return try await withCheckedThrowingContinuation { continuation in
***REMOVED******REMOVED******REMOVED***self.continuation = continuation
***REMOVED***
***REMOVED***
***REMOVED***

extension Foo: Identifiable {
***REMOVED***public var id: ObjectIdentifier {
***REMOVED******REMOVED***ObjectIdentifier(self)
***REMOVED***
***REMOVED***

private class QueuedChallenge {
***REMOVED***let challenge: ArcGISAuthenticationChallenge
***REMOVED***var continuation: CheckedContinuation<ArcGISAuthenticationChallenge.Disposition, Error>
***REMOVED***
***REMOVED***init(challenge: ArcGISAuthenticationChallenge, continuation: CheckedContinuation<ArcGISAuthenticationChallenge.Disposition, Error>) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED******REMOVED***self.continuation = continuation
***REMOVED***
***REMOVED***

@MainActor
public final class Authenticator: ObservableObject {
***REMOVED***public init() {
***REMOVED******REMOVED***Task { await observeChallengeQueue() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func observeChallengeQueue() async {
***REMOVED******REMOVED***for await queuedChallenge in challengeQueue {
***REMOVED******REMOVED******REMOVED***print("  -- handing challenge")
***REMOVED******REMOVED******REMOVED***let foo = Foo(challenge: queuedChallenge.challenge)
***REMOVED******REMOVED******REMOVED***currentFoo = foo
***REMOVED******REMOVED******REMOVED***queuedChallenge.continuation.resume(
***REMOVED******REMOVED******REMOVED******REMOVED***with: await Result { try await foo.waitForChallengeToBeHandled() ***REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***currentFoo = nil
***REMOVED***
***REMOVED***

***REMOVED***@Published
***REMOVED***public var currentFoo: Foo?
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
***REMOVED******REMOVED***return try await withCheckedThrowingContinuation { continuation in
***REMOVED******REMOVED******REMOVED***subject.send(QueuedChallenge(challenge: challenge, continuation: continuation))
***REMOVED***
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
