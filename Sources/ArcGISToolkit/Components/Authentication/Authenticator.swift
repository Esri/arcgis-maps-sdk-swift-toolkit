***REMOVED***
***REMOVED*** COPYRIGHT 1995-2022 ESRI
***REMOVED***
***REMOVED*** TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
***REMOVED*** Unpublished material - all rights reserved under the
***REMOVED*** Copyright Laws of the United States and applicable international
***REMOVED*** laws, treaties, and conventions.
***REMOVED***
***REMOVED*** For additional information, contact:
***REMOVED*** Environmental Systems Research Institute, Inc.
***REMOVED*** Attn: Contracts and Legal Services Department
***REMOVED*** 380 New York Street
***REMOVED*** Redlands, California, 92373
***REMOVED*** USA
***REMOVED***
***REMOVED*** email: contracts@esri.com
***REMOVED***

***REMOVED***
***REMOVED***

final class ChallengeContinuation {
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

@MainActor
final class Authenticator: ObservableObject {
***REMOVED***init() {***REMOVED***

***REMOVED***@Published
***REMOVED***var continuation: ChallengeContinuation?
***REMOVED***

extension Authenticator: AuthenticationChallengeHandler {
***REMOVED***func handleArcGISChallenge(
***REMOVED******REMOVED***_ challenge: ArcGISAuthenticationChallenge
***REMOVED***) async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED***guard challenge.proposedCredential == nil else {
***REMOVED******REMOVED******REMOVED***return .performDefaultHandling
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return try await withUnsafeThrowingContinuation { continuation in
***REMOVED******REMOVED******REMOVED***self.continuation = ChallengeContinuation(challenge: challenge, continuation: continuation)
***REMOVED***
***REMOVED***
***REMOVED***
