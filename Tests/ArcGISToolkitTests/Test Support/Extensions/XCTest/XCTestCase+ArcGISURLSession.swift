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

import XCTest
import ArcGIS

extension XCTestCase {
    /// Sets up an ArcGIS challenge handler on the `ArcGISURLSession` and registers a tear-down block to
    /// reset it to previous handler.
    func setArcGISChallengeHandler(_ challengeHandler: ArcGISAuthenticationChallengeHandler) {
        let previous = ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler
        ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = challengeHandler
        addTeardownBlock { ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = previous }
    }
    
    /// Sets up a network challenge handler on the `ArcGISURLSession` and registers a tear-down block to
    /// reset it to  previous handler.
    func setNetworkChallengeHandler(_ challengeHandler: NetworkAuthenticationChallengeHandler) {
        let previous = ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler
        ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = challengeHandler
        addTeardownBlock { ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = previous }
    }
}
