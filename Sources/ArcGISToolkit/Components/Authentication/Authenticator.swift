// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Combine
import CryptoTokenKit

/// The `Authenticator` is a configurable object that handles authentication challenges. It will
/// display a user interface when network and ArcGIS authentication challenges occur.
///
/// ![image](https://user-images.githubusercontent.com/3998072/203615041-c887d5e3-bb64-469a-a76b-126059329e92.png)
///
/// **Features**
/// 
/// The `Authenticator` has a view modifier that will display a prompt when the `Authenticator` is
/// asked to handle an authentication challenge. This will handle many different types of
/// authentication, for example:
///
///   - ArcGIS authentication (token and OAuth)
///   - Integrated Windows Authentication (IWA)
///   - Client Certificate (PKI)
///
/// The `Authenticator` can be configured to support securely persisting credentials to the keychain.
///
/// `Authenticator` is accessible via a modifier on `View`:
///
/// ```swift
/// /// Presents user experiences for collecting network authentication credentials from the user.
/// /// - Parameter authenticator: The authenticator for which credentials will be prompted.
/// @ViewBuilder func authenticator(_ authenticator: Authenticator) -> some View
/// ```
///
/// **Behavior**
///
/// The `authenticator(_:)` view modifier will display an alert prompting the user for credentials. If
/// credentials were persisted to the keychain, the authenticator will use those instead of
/// requiring the user to re-enter credentials.
///
/// To see the `Authenticator` in action, check out the [Authentication Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/AuthenticationExample)
/// and refer to [AuthenticationApp.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/AuthenticationExample/AuthenticationExample/AuthenticationApp.swift).
/// To learn more about using the `Authenticator`, see the <doc:AuthenticatorTutorial>.
@MainActor
public final class Authenticator: ObservableObject {
    /// A value indicating whether we should prompt the user when encountering an untrusted host.
    let promptForUntrustedHosts: Bool
    /// The OAuth configurations that this authenticator can work with.
    let oAuthUserConfigurations: [OAuthUserConfiguration]
    
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
        
        // If the smart card is connected to the device then a personal identity verification (PIV)
        // token is available in the `TKTokenWatcher().tokenIDs`. Create a smart card network
        // credential with first available PIV token and continue with credential.
        if challenge.kind == .clientCertificate,
           let pivToken = TKTokenWatcher().tokenIDs.filter({ $0.localizedCaseInsensitiveContains("pivtoken") }).first,
           let credential = try? NetworkCredential.smartCard(pivToken: pivToken) {
            return .continueWithCredential(credential)
        } else if challenge.kind == .negotiate {
            // Reject the negotiate challenge so next authentication protection
            // space is tried.
            return .rejectProtectionSpace
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
