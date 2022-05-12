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

public final class ChallengeContinuation {
***REMOVED***let challenge: ArcGISAuthenticationChallenge
***REMOVED***let continuation: UnsafeContinuation<ArcGISAuthenticationChallenge.Disposition, Error>
***REMOVED***
***REMOVED***init(challenge: ArcGISAuthenticationChallenge, continuation: UnsafeContinuation<ArcGISAuthenticationChallenge.Disposition, Error>) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED******REMOVED***self.continuation = continuation
***REMOVED***

***REMOVED***func resume(with result: Result<ArcGISAuthenticationChallenge.Disposition, Error>) {
***REMOVED******REMOVED***continuation.resume(with: result)
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***continuation.resume(throwing: CancellationError())
***REMOVED***
***REMOVED***

extension ChallengeContinuation: Identifiable {***REMOVED***

@MainActor
public final class Authenticator: ObservableObject {
***REMOVED***public init() {***REMOVED***

***REMOVED***@Published
***REMOVED***public var continuation: ChallengeContinuation?
***REMOVED***

extension Authenticator: AuthenticationChallengeHandler {
***REMOVED***public func handleArcGISChallenge(
***REMOVED******REMOVED***_ challenge: ArcGISAuthenticationChallenge
***REMOVED***) async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED***guard challenge.proposedCredential == nil else {
***REMOVED******REMOVED******REMOVED***return .performDefaultHandling
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return try await withUnsafeThrowingContinuation { continuation in
***REMOVED******REMOVED******REMOVED***print("-- auth challenge: \(challenge.request.url!)")
***REMOVED******REMOVED******REMOVED***self.continuation = ChallengeContinuation(challenge: challenge, continuation: continuation)
***REMOVED***
***REMOVED***
***REMOVED***
