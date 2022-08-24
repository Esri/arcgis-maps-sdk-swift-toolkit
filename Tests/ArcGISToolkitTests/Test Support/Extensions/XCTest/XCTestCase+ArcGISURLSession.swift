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
***REMOVED***func setChallengeHandler(_ challengeHandler: AuthenticationChallengeHandler) {
***REMOVED******REMOVED***let previous = ArcGISRuntimeEnvironment.authenticationChallengeHandler
***REMOVED******REMOVED***ArcGISRuntimeEnvironment.authenticationChallengeHandler = challengeHandler
***REMOVED******REMOVED***addTeardownBlock { ArcGISRuntimeEnvironment.authenticationChallengeHandler = previous ***REMOVED***
***REMOVED***
***REMOVED***
