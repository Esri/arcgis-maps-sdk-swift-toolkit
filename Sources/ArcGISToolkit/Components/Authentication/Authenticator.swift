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
    let oAuthUserConfigurations: [OAuthUserConfiguration]
    
    /// A value indicating whether we should prompt the user when encountering an untrusted host.
    var promptForUntrustedHosts: Bool
    
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
            return .continueWithCredential(try await OAuthUserCredential.credential(for: configuration))
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
    ) async -> NetworkAuthenticationChallenge.Disposition  {
        // If `promptForUntrustedHosts` is `false` then perform default handling
        // for server trust challenges.
        guard promptForUntrustedHosts || challenge.kind != .serverTrust else {
            return .continueWithoutCredential
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
