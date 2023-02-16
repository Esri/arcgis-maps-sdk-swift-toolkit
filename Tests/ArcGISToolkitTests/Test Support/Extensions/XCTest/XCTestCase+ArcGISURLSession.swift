***REMOVED***
***REMOVED*** COPYRIGHT 1995-2022 ESRI
***REMOVED***
***REMOVED*** TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
***REMOVED*** Unpublished material - all rights reserved under the
***REMOVED*** Copyright Laws of the United States and applicable international
***REMOVED*** laws, treaties, and conventions.
***REMOVED***
***REMOVED*** For additional information, contact:
***REMOVED*** Environmental Systems Research Institute, Inc.
***REMOVED*** Attn: Contracts and Legal Services Department
***REMOVED*** 380 New York Street
***REMOVED*** Redlands, California, 92373
***REMOVED*** USA
***REMOVED***
***REMOVED*** email: contracts@esri.com
***REMOVED***

import XCTest
***REMOVED***

extension XCTestCase {
***REMOVED******REMOVED***/ Sets up an ArcGIS challenge handler on the `ArcGISURLSession` and registers a tear-down block to
***REMOVED******REMOVED***/ reset it to previous handler.
***REMOVED***func setArcGISChallengeHandler(_ challengeHandler: ArcGISAuthenticationChallengeHandler) {
***REMOVED******REMOVED***let previous = ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = challengeHandler
***REMOVED******REMOVED***addTeardownBlock { ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = previous ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets up a network challenge handler on the `ArcGISURLSession` and registers a tear-down block to
***REMOVED******REMOVED***/ reset it to  previous handler.
***REMOVED***func setNetworkChallengeHandler(_ challengeHandler: NetworkAuthenticationChallengeHandler) {
***REMOVED******REMOVED***let previous = ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = challengeHandler
***REMOVED******REMOVED***addTeardownBlock { ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = previous ***REMOVED***
***REMOVED***
***REMOVED***
