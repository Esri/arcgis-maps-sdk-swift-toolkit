//
// COPYRIGHT 1995-2022 ESRI
//
// TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
// Unpublished material - all rights reserved under the
// Copyright Laws of the United States and applicable international
// laws, treaties, and conventions.
//
// For additional information, contact:
// Environmental Systems Research Institute, Inc.
// Attn: Contracts and Legal Services Department
// 380 New York Street
// Redlands, California, 92373
// USA
//
// email: contracts@esri.com
//

import ArcGIS
import SwiftUI

final class ChallengeContinuation {
    let challenge: ArcGISAuthenticationChallenge
    let continuation: UnsafeContinuation<ArcGISAuthenticationChallenge.Disposition, Error>
    
    init(challenge: ArcGISAuthenticationChallenge, continuation: UnsafeContinuation<ArcGISAuthenticationChallenge.Disposition, Error>) {
        self.challenge = challenge
        self.continuation = continuation
    }

    func resume(with result: Result<ArcGISAuthenticationChallenge.Disposition, Error>) {
        continuation.resume(with: result)
    }
    
    func cancel() {
        continuation.resume(throwing: CancellationError())
    }
}

@MainActor
final class Authenticator: ObservableObject {
    init() {}

    @Published
    var continuation: ChallengeContinuation?
}

extension Authenticator: AuthenticationChallengeHandler {
    func handleArcGISChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        guard challenge.proposedCredential == nil else {
            return .performDefaultHandling
        }
        
        return try await withUnsafeThrowingContinuation { continuation in
            self.continuation = ChallengeContinuation(challenge: challenge, continuation: continuation)
        }
    }
}
