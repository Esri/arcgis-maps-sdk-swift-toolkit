//
// COPYRIGHT 1995-2022 ESRI
//
// TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
// Unpublished material - all rights reserved under the
// Copyright Laws of the United States and applicable international
// laws, treaties, and conventions.
//
// For additional information, contact:
// Environmental Systems Research Institute, Inc.
// Attn: Contracts and Legal Services Department
// 380 New York Street
// Redlands, California, 92373
// USA
//
// email: contracts@esri.com
//

import Foundation
import ArcGIS

/// A `NetworkChallengeHandler` that can handle trusting hosts with a self-signed certificate
/// and the network credential.
final class NetworkChallengeHandler: NetworkAuthenticationChallengeHandler {
    /// A Boolean value indicating whether to allow hosts that have certificate trust issues.
    let allowUntrustedHosts: Bool
    
    /// The url credential used when a challenge is thrown.
    let networkCredential: NetworkCredential?
        
    /// The network authentication challenges.
    private(set) var challenges: [NetworkAuthenticationChallenge] = []
        
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
            challenges.append(challenge)
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
