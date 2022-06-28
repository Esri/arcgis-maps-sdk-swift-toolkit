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

@MainActor
public final class Authenticator: ObservableObject {
    let oAuthConfigurations: [OAuthConfiguration]
    var promptForUntrustedHosts: Bool
    
    public init(
        promptForUntrustedHosts: Bool = false,
        oAuthConfigurations: [OAuthConfiguration] = []
    ) {
        self.promptForUntrustedHosts = promptForUntrustedHosts
        self.oAuthConfigurations = oAuthConfigurations
        Task { await observeChallengeQueue() }
    }
    
    /// Sets up a credential store that is synchronized with the keychain.
    /// - Remark: The item will be stored in the default access group.
    /// To know more about what the default group would be you can find information about that here:
    /// https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps.
    /// - Parameters:
    ///   - access: When the credentials stored in the keychain can be accessed.
    ///   - isSynchronizable: A value indicating whether the item is synchronized with iCloud.
    public func synchronizeWithKeychain(
        access: ArcGIS.KeychainAccess,
        isCloudSynchronizable: Bool = false
    ) async throws {
        ArcGISURLSession.credentialStore = try await .makePersistent(
            access: access,
            isSynchronizable: isCloudSynchronizable
        )
        
        NetworkCredentialStore.setShared(
            try await .makePersistent(access: access, isSynchronizable: isCloudSynchronizable)
        )
    }
    
    public func clearCredentialStores() async {
        // Clear ArcGIS Credentials.
        await ArcGISURLSession.credentialStore.removeAll()
        
        // Clear network credentials.
        await NetworkCredentialStore.shared.removeAll()
        
        // We have to reset the sessions for URLCredential storage to respect the removed credentials
        ArcGISURLSession.shared = ArcGISURLSession.makeDefaultSharedSession()
        ArcGISURLSession.sharedBackground = ArcGISURLSession.makeDefaultSharedBackgroundSession()
    }
    
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
                
                if let challenge = queuedChallenge as? QueuedArcGISChallenge,
                   let previous = await ArcGISURLSession.credentialStore.credential(for: challenge.arcGISChallenge.request.url!) {
                    print("-- previous: \(previous)")
                }
                    
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
    private var challengeQueue: AsyncPublisher<AnyPublisher<QueuedChallenge, Never>> {
        AsyncPublisher(
            subject
                .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
                .eraseToAnyPublisher()
        )
    }
    
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
