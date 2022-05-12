// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

public final class ChallengeContinuation {
    let challenge: ArcGISAuthenticationChallenge
    var continuation: CheckedContinuation<ArcGISAuthenticationChallenge.Disposition, Error>?
    
    init(challenge: ArcGISAuthenticationChallenge, continuation: CheckedContinuation<ArcGISAuthenticationChallenge.Disposition, Error>) {
        self.challenge = challenge
        self.continuation = continuation
    }

    func resume(with result: Result<ArcGISAuthenticationChallenge.Disposition, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }
    
    func cancel() {
        continuation?.resume(throwing: CancellationError())
        continuation = nil
    }
}

extension ChallengeContinuation: Identifiable {}

@MainActor
public final class Authenticator: ObservableObject {
    public init() {}

    @Published
    public var continuation: ChallengeContinuation?
}

extension Authenticator: AuthenticationChallengeHandler {
    public func handleArcGISChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        guard challenge.proposedCredential == nil else {
            return .performDefaultHandling
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = ChallengeContinuation(challenge: challenge, continuation: continuation)
        }
    }
}
