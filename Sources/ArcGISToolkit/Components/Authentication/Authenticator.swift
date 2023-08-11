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
    /// A value indicating whether we should prompt the user when encountering an untrusted host.
    public let promptForUntrustedHosts: Bool
    
    /// The OAuth configurations that this authenticator can work with.
    public var oAuthUserConfigurations: [OAuthUserConfiguration]
    
    /// The closure to call once the user has signed out.
    public var signOutAction: (() async -> Void) = {}
    
    /// The smart card manager.
    @ObservedObject public var smartCardManager: SmartCardManager
    
    /// Creates an authenticator.
    /// - Parameters:
    ///   - promptForUntrustedHosts: A value indicating whether we should prompt the user when
    ///   encountering an untrusted host.
    ///   - oAuthConfigurations: The OAuth configurations that this authenticator can work with.
    public init(
        promptForUntrustedHosts: Bool = false,
        oAuthUserConfigurations: [OAuthUserConfiguration] = []
    ) {
        self.promptForUntrustedHosts = promptForUntrustedHosts
        self.oAuthUserConfigurations = oAuthUserConfigurations
        self.smartCardManager = SmartCardManager()
    }
    
    /// The current challenge.
    /// This property is not set for OAuth challenges.
    @Published var currentChallenge: ChallengeContinuation?
}

extension Authenticator: ArcGISAuthenticationChallengeHandler {
    public func handleArcGISAuthenticationChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        // Alleviates an error with "already presenting".
        await Task.yield()
        
        // Create the correct challenge type.
        if let configuration = oAuthUserConfigurations.first(where: { $0.canBeUsed(for: challenge.requestURL) }) {
            do {
                return .continueWithCredential(try await OAuthUserCredential.credential(for: configuration))
            } catch is CancellationError {
                // If user cancels the creation of OAuth user credential then catch the
                // cancellation error and cancel the challenge. This will make the request which
                // issued the challenge fail with `ArcGISChallengeCancellationError`.
                return .cancel
            }
        } else {
            let tokenChallengeContinuation = TokenChallengeContinuation(arcGISChallenge: challenge)
            
            // Set the current challenge, which will present the UX.
            self.currentChallenge = tokenChallengeContinuation
            defer { self.currentChallenge = nil }
            
            // Wait for it to complete and return the resulting disposition.
            return try await tokenChallengeContinuation.value.get()
        }
    }
}

extension Authenticator: NetworkAuthenticationChallengeHandler {
    public func handleNetworkAuthenticationChallenge(
        _ challenge: NetworkAuthenticationChallenge
    ) async -> NetworkAuthenticationChallenge.Disposition {
        // If `promptForUntrustedHosts` is `false` then perform default handling
        // for server trust challenges.
        guard promptForUntrustedHosts || challenge.kind != .serverTrust else {
            return .continueWithoutCredential
        }
        
        // If smart card is connected to the device then a personal identity verification (PIV) token
        // is available then create a smart card network credential and continue.
        if challenge.kind == .clientCertificate,
           let pivToken = smartCardManager.pivToken,
           let credential = try? NetworkCredential.smartCard(pivToken: pivToken) {
            // Set last used PIV token on the manager.
            smartCardManager.setLastUsedPIVToken(pivToken)
            
            return .continueWithCredential(credential)
        }
        
        let challengeContinuation = NetworkChallengeContinuation(networkChallenge: challenge)
        
        // Alleviates an error with "already presenting".
        await Task.yield()
        
        // Set the current challenge, which will present the UX.
        self.currentChallenge = challengeContinuation
        defer { self.currentChallenge = nil }
        
        // Wait for it to complete and return the resulting disposition.
        return await challengeContinuation.value
    }
}

public extension Authenticator {
    /// Signs out by revoking tokens and clearing the credential stores.
    func signOut() async {
        await ArcGISEnvironment.authenticationManager.revokeOAuthTokens()
        await ArcGISEnvironment.authenticationManager.clearCredentialStores()
        smartCardManager.setLastUsedPIVToken(nil)
    }
}
