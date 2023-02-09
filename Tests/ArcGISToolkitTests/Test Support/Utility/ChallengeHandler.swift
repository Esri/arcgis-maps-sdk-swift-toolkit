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

/// A `ChallengeHandler` that that can handle trusting hosts with a self-signed certificate, the URL credential,
/// and the token credential.
class ChallengeHandler: ArcGISAuthenticationChallengeHandler {
    /// The hosts that can be trusted if they have certificate trust issues.
    let trustedHosts: Set<String>
    
    /// The url credential used when a challenge is thrown.
    let networkCredentialProvider: ((NetworkAuthenticationChallenge) async -> NetworkCredential?)?
    
    /// The arcgis credential used when an ArcGIS challenge is received.
    let arcgisCredentialProvider: ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)?
    
    /// The network authentication challenges.
    private(set) var networkChallenges: [NetworkAuthenticationChallenge] = []
    
    /// The ArcGIS authentication challenges.
    private(set) var arcGISChallenges: [ArcGISAuthenticationChallenge] = []
    
    init(
        trustedHosts: Set<String> = [],
        networkCredentialProvider: ((NetworkAuthenticationChallenge) async -> NetworkCredential?)? = nil,
        arcgisCredentialProvider: ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)? = nil
    ) {
        self.trustedHosts = trustedHosts
        self.networkCredentialProvider = networkCredentialProvider
        self.arcgisCredentialProvider = arcgisCredentialProvider
    }
    
    convenience init(
        trustedHosts: Set<String>,
        networkCredential: NetworkCredential
    ) {
        self.init(trustedHosts: trustedHosts, networkCredentialProvider: { _ in networkCredential })
    }
    
    func handleNetworkAuthenticationChallenge(
        _ challenge: NetworkAuthenticationChallenge
    ) async -> NetworkAuthenticationChallenge.Disposition {
        // Record challenge only if it is not a server trust.
        if challenge.kind != .serverTrust {
            networkChallenges.append(challenge)
        }
        
        if challenge.kind == .serverTrust {
            if trustedHosts.contains(challenge.host) {
                // This will cause a self-signed certificate to be trusted.
                return .continueWithCredential(.serverTrust)
            } else {
                return .continueWithoutCredential
            }
        } else if let networkCredentialProvider = networkCredentialProvider,
                  let networkCredential = await networkCredentialProvider(challenge) {
            return .continueWithCredential(networkCredential)
        } else {
            return .cancel
        }
    }
    
    func handleArcGISAuthenticationChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        arcGISChallenges.append(challenge)
        
        if let arcgisCredentialProvider = arcgisCredentialProvider,
           let arcgisCredential = try? await arcgisCredentialProvider(challenge) {
            return .continueWithCredential(arcgisCredential)
        } else {
            return .cancel
        }
    }
}
