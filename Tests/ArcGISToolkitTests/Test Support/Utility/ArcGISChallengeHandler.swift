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

import Foundation
***REMOVED***

***REMOVED***/ An `ArcGISChallengeHandler` that can handle challenges using ArcGIS credential.
final class ArcGISChallengeHandler: ArcGISAuthenticationChallengeHandler {
***REMOVED******REMOVED***/ The arcgis credential used when an ArcGIS challenge is received.
***REMOVED***let credentialProvider: ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)
***REMOVED***
***REMOVED******REMOVED***/ The ArcGIS authentication challenges.
***REMOVED***private(set) var challenges: [ArcGISAuthenticationChallenge] = []
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***credentialProvider: @escaping ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)
***REMOVED***) {
***REMOVED******REMOVED***self.credentialProvider = credentialProvider
***REMOVED***
***REMOVED***
***REMOVED***func handleArcGISAuthenticationChallenge(
***REMOVED******REMOVED***_ challenge: ArcGISAuthenticationChallenge
***REMOVED***) async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED***challenges.append(challenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let arcgisCredential = try await credentialProvider(challenge) {
***REMOVED******REMOVED******REMOVED***return .continueWithCredential(arcgisCredential)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .continueWithoutCredential
***REMOVED***
***REMOVED***
***REMOVED***
