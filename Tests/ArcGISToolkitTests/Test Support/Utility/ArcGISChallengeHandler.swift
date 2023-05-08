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

/// An `ArcGISChallengeHandler` that can handle challenges using ArcGIS credential.
final class ArcGISChallengeHandler: ArcGISAuthenticationChallengeHandler {
    /// The arcgis credential used when an ArcGIS challenge is received.
    let credentialProvider: ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)
    
    /// The ArcGIS authentication challenges.
    private(set) var challenges: [ArcGISAuthenticationChallenge] = []
    
    init(
        credentialProvider: @escaping ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)
    ) {
        self.credentialProvider = credentialProvider
    }
    
    func handleArcGISAuthenticationChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        challenges.append(challenge)
        
        if let arcgisCredential = try await credentialProvider(challenge) {
            return .continueWithCredential(arcgisCredential)
        } else {
            return .continueWithoutCredential
        }
    }
}
