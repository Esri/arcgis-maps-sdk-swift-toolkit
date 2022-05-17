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

public final class QueuedArcGISChallenge: QueuedChallenge {
    let arcGISChallenge: ArcGISAuthenticationChallenge
    
    init(arcGISChallenge: ArcGISAuthenticationChallenge) {
        self.arcGISChallenge = arcGISChallenge
    }

    func resume(with result: Result<ArcGISAuthenticationChallenge.Disposition, Error>) {
        guard _result == nil else { return }
        _result = result
    }
    
    func cancel() {
        guard _result == nil else { return }
        _result = .failure(CancellationError())
    }
    
    /// Use a streamed property because we need to support multiple listeners
    /// to know when the challenge completed.
    @Streamed
    private var _result: Result<ArcGISAuthenticationChallenge.Disposition, Error>?
    
    var disposition: ArcGISAuthenticationChallenge.Disposition {
        get async throws {
            try await $_result
                .compactMap({ $0 })
                .first(where: { _ in true })!
                .get()
        }
    }
    
    public func complete() async {
        _ = try? await disposition
    }
}

public final class QueuedURLChallenge: QueuedChallenge {
    let urlChallenge: URLAuthenticationChallenge
    
    init(urlChallenge: URLAuthenticationChallenge) {
        self.urlChallenge = urlChallenge
    }

    func resume(with response: Response) {
        guard _response == nil else { return }
        _response = response
    }
    
    func cancel() {
        guard _response == nil else { return }
        _response = .cancel
    }
    
    /// Use a streamed property because we need to support multiple listeners
    /// to know when the challenge completed.
    @Streamed
    private var _response: (Response)?
    
    var response: Response {
        get async {
            await $_response
                .compactMap({ $0 })
                .first(where: { _ in true })!
        }
    }
    
    public func complete() async {
        _ = await response
    }
    
    enum Response {
        case userCredential(username: String, password: String)
        case trustHost
        case cancel
    }
}

public protocol QueuedChallenge: AnyObject {
    func complete() async
}

@MainActor
public final class Authenticator: ObservableObject {
    let oAuthConfigurations: [OAuthConfiguration]
    var trustedHosts: [String] = []
    
    public init(
        oAuthConfigurations: [OAuthConfiguration] = []
    ) {
        self.oAuthConfigurations = oAuthConfigurations
        Task { await observeChallengeQueue() }
    }
    
    private func observeChallengeQueue() async {
        for await queuedChallenge in challengeQueue {
            if let queuedArcGISChallenge = queuedChallenge as? QueuedArcGISChallenge,
               let url = queuedArcGISChallenge.arcGISChallenge.request.url,
               let config = oAuthConfigurations.first(where: { $0.canBeUsed(for: url) }) {
                // For an OAuth challenge, we create the credential and resume.
                // Creating the OAuth credential will present the OAuth login view.
                queuedArcGISChallenge.resume(
                    with: await Result {
                        .useCredential(try await .oauth(configuration: config))
                    }
                )
            } else {
                // Set the current challenge, this should show the challenge view.
                currentChallenge = IdentifiableQueuedChallenge(queuedChallenge: queuedChallenge)
                // Wait for the queued challenge to finish.
                await queuedChallenge.complete()
                // Set the current challenge to `nil`, this should dismiss the challenge view.
                currentChallenge = nil
            }
        }
    }

    @Published
    public var currentChallenge: IdentifiableQueuedChallenge?
    
    private var subject = PassthroughSubject<QueuedChallenge, Never>()
    private var challengeQueue: AsyncPublisher<AnyPublisher<QueuedChallenge, Never>> {
        AsyncPublisher(
            subject
                .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
                .eraseToAnyPublisher()
        )
    }
}

public struct IdentifiableQueuedChallenge {
    public let queuedChallenge: QueuedChallenge
}

extension IdentifiableQueuedChallenge: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(queuedChallenge) }
}

extension Authenticator: AuthenticationChallengeHandler {
    public func handleArcGISChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        guard challenge.proposedCredential == nil else {
            return .performDefaultHandling
        }
        
        // Queue up the challenge.
        let queuedChallenge = QueuedArcGISChallenge(arcGISChallenge: challenge)
        subject.send(queuedChallenge)
        
        // Wait for it to complete and return the resulting disposition.
        return try await queuedChallenge.disposition
    }
    
    public func handleURLSessionChallenge(
        _ challenge: URLAuthenticationChallenge,
        scope: URLAuthenticationChallengeScope
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        //return (.performDefaultHandling, nil)
        guard challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodDefault else {
            return (.performDefaultHandling, nil)
        }
        
        guard challenge.proposedCredential == nil else {
            return (.performDefaultHandling, nil)
        }
        
        // If the host is already trusted, then continue trusting it.
        if let trust = challenge.protectionSpace.serverTrust,
           trustedHosts.contains(challenge.protectionSpace.host) {
            return (.useCredential, URLCredential(trust: trust))
        }
        
        // Queue up the url challenge.
        let queuedChallenge = QueuedURLChallenge(urlChallenge: challenge)
        subject.send(queuedChallenge)
        
        switch await queuedChallenge.response {
        case .cancel:
            return (.cancelAuthenticationChallenge, nil)
        case .trustHost:
            if let trust = challenge.protectionSpace.serverTrust {
                trustedHosts.append(challenge.protectionSpace.host)
                return (.useCredential, URLCredential(trust: trust))
            } else {
                return (.performDefaultHandling, nil)
            }
        case .userCredential(let user, let password):
            return (.useCredential, URLCredential(user: user, password: password, persistence: .forSession))
        }
    }
}
