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
    
    deinit {
        observationTask?.cancel()
    }
    
    /// The task for the observation of the challenge queue.
    private var observationTask: Task<Void, Never>?
    
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
        observationTask = Task { [weak self] in
            // Cannot unwrap self on the `for await` line or it will introduce a retain cycle.
            guard let challengeQueue = self?.challengeQueue else { return }
            for await queuedChallenge in challengeQueue {
                guard let self = self else { break }
                
                // A yield here helps alleviate the already presenting bug.
                await Task.yield()
                
                // Set the current challenge, this should present the appropriate view.
                self.currentChallenge = queuedChallenge
                
                // Wait for the queued challenge to finish.
                await queuedChallenge.complete()
                
                // Reset the current challenge to `nil`, that will dismiss the view.
                self.currentChallenge = nil
            }
        }
    }
    
    /// Sets up new credential stores that will be persisted to the keychain.
    /// - Remark: The credentials will be stored in the default access group of the keychain.
    /// You can find more information about what the default group would be here:
    /// https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps
    /// - Parameters:
    ///   - access: When the credentials stored in the keychain can be accessed.
    ///   - isSynchronizable: A value indicating whether the credentials are synchronized with iCloud.
    public func makePersistent(
        access: ArcGIS.KeychainAccess,
        isSynchronizable: Bool = false
    ) async throws {
        let previousArcGISCredentialStore = ArcGISRuntimeEnvironment.credentialStore
        
        // Set a persistent ArcGIS credential store on the ArcGIS environment.
        ArcGISRuntimeEnvironment.credentialStore = try await .makePersistent(
            access: access,
            isSynchronizable: isSynchronizable
        )
        
        do {
            // Set a persistent network credential store on the ArcGIS environment.
            ArcGISRuntimeEnvironment.networkCredentialStore =
                try await .makePersistent(access: access, isSynchronizable: isSynchronizable)
        } catch {
            // If making the shared network credential store persistent fails,
            // then restore the ArcGIS credential store.
            ArcGISRuntimeEnvironment.credentialStore = previousArcGISCredentialStore
            throw error
        }
    }
    
    /// Clears all ArcGIS and network credentials from the respective stores.
    /// Note: This sets up new `URLSessions` so that removed network credentials are respected
    /// right away.
    public func clearCredentialStores() async {
        // Clear ArcGIS Credentials.
        await ArcGISRuntimeEnvironment.credentialStore.removeAll()
        
        // Clear network credentials.
        await ArcGISRuntimeEnvironment.networkCredentialStore.removeAll()
        
        // We have to set new sessions for URLCredential storage to respect the removed credentials
        // right away.
        ArcGISRuntimeEnvironment.urlSession = ArcGISURLSession(configuration: .default)
        ArcGISRuntimeEnvironment.backgroundURLSession = ArcGISURLSession(
            configuration: .background(withIdentifier: "com.esri.arcgis.toolkit." + UUID().uuidString)
        )
    }
    
    var subject = PassthroughSubject<QueuedChallenge, Never>()
    
    /// A serial queue for authentication challenges.
    private var challengeQueue: AsyncPublisher<AnyPublisher<QueuedChallenge, Never>> {
        AsyncPublisher(
            subject
                .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
                .eraseToAnyPublisher()
        )
    }
    
    /// The current queued challenge.
    @Published var currentChallenge: QueuedChallenge?
}

extension Authenticator: AuthenticationChallengeHandler {
    public func handleArcGISChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        let queuedChallenge: QueuedArcGISChallenge
        
        // Create the correct challenge type.
        if let url = challenge.request.url,
           let config = oAuthConfigurations.first(where: { $0.canBeUsed(for: url) }) {
            let oAuthChallenge = QueuedOAuthChallenge(configuration: config)
            queuedChallenge = oAuthChallenge
            oAuthChallenge.presentPrompt()
        } else {
            queuedChallenge = QueuedTokenChallenge(arcGISChallenge: challenge)
        }
        
        // Queue up the challenge.
        subject.send(queuedChallenge)
        
        // Wait for it to complete and return the resulting disposition.
        return try await queuedChallenge.result.get()
    }
    
    public func handleNetworkChallenge(
        _ challenge: NetworkAuthenticationChallenge
    ) async -> NetworkAuthenticationChallengeDisposition {
        // If `promptForUntrustedHosts` is `false` then perform default handling
        // for server trust challenges.
        guard promptForUntrustedHosts || challenge.kind != .serverTrust else {
            return .performDefaultHandling
        }
        
        let queuedChallenge = QueuedNetworkChallenge(networkChallenge: challenge)
        
        // Queue up the challenge.
        subject.send(queuedChallenge)
        
        // Wait for it to complete and return the resulting disposition.
        return await queuedChallenge.disposition
    }
}
