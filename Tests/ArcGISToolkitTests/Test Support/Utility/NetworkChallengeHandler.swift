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
import os

/// A `NetworkChallengeHandler` that can handle trusting hosts with a self-signed certificate
/// and the network credential.
final class NetworkChallengeHandler: NetworkAuthenticationChallengeHandler {
    /// A Boolean value indicating whether to allow hosts that have certificate trust issues.
    let allowUntrustedHosts: Bool
    
    /// The url credential used when a challenge is thrown.
    let networkCredential: NetworkCredential?
        
    /// The network authentication challenges.
    var challenges: [NetworkAuthenticationChallenge] {
        _challenges.withLock { $0 }
    }
    private let _challenges = OSAllocatedUnfairLock<[NetworkAuthenticationChallenge]>(initialState: [])
        
    init(
        allowUntrustedHosts: Bool,
        networkCredential: NetworkCredential? = nil
    ) {
        self.allowUntrustedHosts = allowUntrustedHosts
        self.networkCredential = networkCredential
    }
        
    func handleNetworkAuthenticationChallenge(
        _ challenge: NetworkAuthenticationChallenge
    ) async -> NetworkAuthenticationChallenge.Disposition {
        // Record challenge only if it is not a server trust.
        if challenge.kind != .serverTrust {
            _challenges.withLock { $0.append(challenge) }
        }
        
        if challenge.kind == .serverTrust {
            if allowUntrustedHosts {
                // This will cause a self-signed certificate to be trusted.
                return .continueWithCredential(.serverTrust)
            } else {
                return .continueWithoutCredential
            }
        } else if let networkCredential = networkCredential {
            return .continueWithCredential(networkCredential)
        } else {
            return .cancel
        }
    }
}
