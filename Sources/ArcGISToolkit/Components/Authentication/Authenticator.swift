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

/// A configurable object that handles authentication challenges.
@MainActor
public final class Authenticator: ObservableObject {
    /// The OAuth configurations that this authenticator can work with.
    let oAuthConfigurations: [OAuthConfiguration]
    
    /// A value indicating whether we should prompt the user when encountering an untrusted host.
    var promptForUntrustedHosts: Bool
    
    /// Creates an authenticator.
    /// - Parameters:
    ///   - promptForUntrustedHosts: A value indicating whether we should prompt the user when
    ///   encountering an untrusted host.
    ///   - oAuthConfigurations: The OAuth configurations that this authenticator can work with.
    public init(
        promptForUntrustedHosts: Bool = false,
        oAuthConfigurations: [OAuthConfiguration] = []
    ) {
        self.promptForUntrustedHosts = promptForUntrustedHosts
        self.oAuthConfigurations = oAuthConfigurations
        // TODO: how to cancel this task?
        Task { await observeChallengeQueue() }
    }
    
    /// Sets up new credential stores that will be persisted to the keychain.
    /// - Remark: The credentials will be stored in the default access group of the keychain.
    /// To know more about what the default group would be you can find information about that here:
    /// https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps.
    /// - Parameters:
    ///   - access: When the credentials stored in the keychain can be accessed.
    ///   - isSynchronizable: A value indicating whether the credentials are synchronized with iCloud.
    public func makePersistent(
        access: ArcGIS.KeychainAccess,
        isSynchronizable: Bool = false
    ) async throws {
        ArcGISURLSession.credentialStore = try await .makePersistent(
            access: access,
            isSynchronizable: isSynchronizable
        )
        
        await NetworkCredentialStore.setShared(
            try await .makePersistent(access: access, isSynchronizable: isSynchronizable)
        )
    }
    
    /// Clears all ArcGIS and network credentials from the respective stores.
    /// Note: This sets up new `URLSessions` so that removed network credentials are respected
    /// right away.
    public func clearCredentialStores() async {
        // Clear ArcGIS Credentials.
        await ArcGISURLSession.credentialStore.removeAll()
        
        // Clear network credentials.
        await NetworkCredentialStore.shared.removeAll()
        
        // We have to reset the sessions for URLCredential storage to respect the removed credentials
        ArcGISURLSession.shared = ArcGISURLSession.makeDefaultSharedSession()
        ArcGISURLSession.sharedBackground = ArcGISURLSession.makeDefaultSharedBackgroundSession()
    }
    
    /// Observes the challenge queue and sets the current challenge.
    private func observeChallengeQueue() async {
        for await queuedChallenge in challengeQueue {
            // A yield here helps alleviate the already presenting bug.
            await Task.yield()
            
            if let queuedArcGISChallenge = queuedChallenge as? QueuedArcGISChallenge,
               let url = queuedArcGISChallenge.arcGISChallenge.request.url,
               let config = oAuthConfigurations.first(where: { $0.canBeUsed(for: url) }) {
                // For an OAuth challenge, we create the credential and resume.
                // Creating the OAuth credential will present the OAuth login view.
                queuedArcGISChallenge.resume(with: .oAuth(configuration: config))
            } else {
                // Set the current challenge, this should present the appropriate view.
                currentChallenge = queuedChallenge

                // Wait for the queued challenge to finish.
                await queuedChallenge.complete()
                
                // Reset the crrent challenge to `nil`, that will dismiss the view.
                currentChallenge = nil
            }
        }
    }
    
    private var subject = PassthroughSubject<QueuedChallenge, Never>()
    
    /// A serial queue for authentication challenges.
    private var challengeQueue: AsyncPublisher<AnyPublisher<QueuedChallenge, Never>> {
        AsyncPublisher(
            subject
                .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
                .eraseToAnyPublisher()
        )
    }
    
    /// The current queued challenge.
    @Published
    var currentChallenge: QueuedChallenge?
}

extension Authenticator: AuthenticationChallengeHandler {
    public func handleArcGISChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        // Queue up the challenge.
        let queuedChallenge = QueuedArcGISChallenge(arcGISChallenge: challenge)
        subject.send(queuedChallenge)
        
        // Wait for it to complete and return the resulting disposition.
        switch await queuedChallenge.response {
        case .tokenCredential(let username, let password):
            return try await .useCredential(.token(challenge: challenge, username: username, password: password))
        case .oAuth(let configuration):
            return try await .useCredential(.oauth(configuration: configuration))
        case .cancel:
            return .cancelAuthenticationChallenge
        }
    }
    
    public func handleNetworkChallenge(
        _ challenge: NetworkAuthenticationChallenge
    ) async -> NetworkAuthenticationChallengeDisposition {
        // If `promptForUntrustedHosts` is `false` then perform default handling
        // for server trust challenges.
        guard promptForUntrustedHosts || challenge.kind != .serverTrust else {
            return .performDefaultHandling
        }
        
        // Queue up the url challenge.
        let queuedChallenge = QueuedNetworkChallenge(networkChallenge: challenge)
        subject.send(queuedChallenge)
        
        // Respond accordingly.
        switch await queuedChallenge.response {
        case .cancel:
            return .cancelAuthenticationChallenge
        case .trustHost:
            return .useCredential(.serverTrust)
        case .login(let user, let password):
            return .useCredential(.login(username: user, password: password))
        case .certificate(let url, let password):
            do {
                return .useCredential(try .certificate(at: url, password: password))
            } catch {
                // TODO: handle error
                fatalError()
            }
        }
    }
}
