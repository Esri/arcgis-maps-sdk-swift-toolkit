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
import Combine

public final class Foo {
    let challenge: ArcGISAuthenticationChallenge
    var continuation: CheckedContinuation<ArcGISAuthenticationChallenge.Disposition, Error>?
    
    init(challenge: ArcGISAuthenticationChallenge) {
        self.challenge = challenge
    }

    func resume(with result: Result<ArcGISAuthenticationChallenge.Disposition, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }
    
    func cancel() {
        continuation?.resume(throwing: CancellationError())
        continuation = nil
    }
    
    func waitForChallengeToBeHandled() async throws -> ArcGISAuthenticationChallenge.Disposition {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }
}

extension Foo: Identifiable {}

private struct QueuedChallenge {
    let challenge: ArcGISAuthenticationChallenge
    var continuation: CheckedContinuation<ArcGISAuthenticationChallenge.Disposition, Error>
    
    init(challenge: ArcGISAuthenticationChallenge, continuation: CheckedContinuation<ArcGISAuthenticationChallenge.Disposition, Error>) {
        self.challenge = challenge
        self.continuation = continuation
    }
}

@MainActor
public final class Authenticator: ObservableObject {
    public init() {
        Task { await observeChallengeQueue() }
    }
    
    private func observeChallengeQueue() async {
        for await queuedChallenge in challengeQueue {
            let foo = Foo(challenge: queuedChallenge.challenge)
            currentFoo = foo
            queuedChallenge.continuation.resume(
                with: await Result { try await foo.waitForChallengeToBeHandled() }
            )
            currentFoo = nil
        }
    }

    @Published
    public var currentFoo: Foo?
    
    private var subject = PassthroughSubject<QueuedChallenge, Never>()
    private var challengeQueue: AsyncPublisher<PassthroughSubject<QueuedChallenge, Never>> {
        AsyncPublisher(subject)
    }
}

extension Authenticator: AuthenticationChallengeHandler {
    public func handleArcGISChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        guard challenge.proposedCredential == nil else {
            return .performDefaultHandling
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            subject.send(QueuedChallenge(challenge: challenge, continuation: continuation))
        }
    }
}
