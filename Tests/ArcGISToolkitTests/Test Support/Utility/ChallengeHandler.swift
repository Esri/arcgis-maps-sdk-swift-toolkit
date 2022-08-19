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
@testable ***REMOVED***

***REMOVED***/ A `ChallengeHandler` that that can handle trusting hosts with a self-signed certificate, the URL credential,
***REMOVED***/ and the token credential.
class ChallengeHandler: AuthenticationChallengeHandler {
***REMOVED******REMOVED***/ The hosts that can be trusted if they have certificate trust issues.
***REMOVED***let trustedHosts: Set<String>
***REMOVED***
***REMOVED******REMOVED***/ The url credential used when a challenge is thrown.
***REMOVED***let networkCredentialProvider: ((NetworkAuthenticationChallenge) async -> NetworkCredential?)?
***REMOVED***
***REMOVED******REMOVED***/ The arcgis credential used when an ArcGIS challenge is received.
***REMOVED***let arcgisCredentialProvider: ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)?
***REMOVED***
***REMOVED******REMOVED***/ The network authentication challenges.
***REMOVED***private(set) var networkChallenges: [NetworkAuthenticationChallenge] = []
***REMOVED***
***REMOVED******REMOVED***/ The ArcGIS authentication challenges.
***REMOVED***private(set) var arcGISChallenges: [ArcGISAuthenticationChallenge] = []
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***trustedHosts: Set<String> = [],
***REMOVED******REMOVED***networkCredentialProvider: ((NetworkAuthenticationChallenge) async -> NetworkCredential?)? = nil,
***REMOVED******REMOVED***arcgisCredentialProvider: ((ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?)? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.trustedHosts = trustedHosts
***REMOVED******REMOVED***self.networkCredentialProvider = networkCredentialProvider
***REMOVED******REMOVED***self.arcgisCredentialProvider = arcgisCredentialProvider
***REMOVED***
***REMOVED***
***REMOVED***convenience init(
***REMOVED******REMOVED***trustedHosts: Set<String>,
***REMOVED******REMOVED***networkCredential: NetworkCredential
***REMOVED***) {
***REMOVED******REMOVED***self.init(trustedHosts: trustedHosts, networkCredentialProvider: { _ in networkCredential ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func handleNetworkAuthenticationChallenge(
***REMOVED******REMOVED***_ challenge: NetworkAuthenticationChallenge
***REMOVED***) async -> NetworkAuthenticationChallenge.Disposition {
***REMOVED******REMOVED******REMOVED*** Record challenge only if it is not a server trust.
***REMOVED******REMOVED***if challenge.kind != .serverTrust {
***REMOVED******REMOVED******REMOVED***networkChallenges.append(challenge)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if challenge.kind == .serverTrust {
***REMOVED******REMOVED******REMOVED***if trustedHosts.contains(challenge.host) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** This will cause a self-signed certificate to be trusted.
***REMOVED******REMOVED******REMOVED******REMOVED***return .useCredential(.serverTrust)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return .allowRequestToFail
***REMOVED******REMOVED***
***REMOVED*** else if let networkCredentialProvider = networkCredentialProvider,
***REMOVED******REMOVED******REMOVED******REMOVED***  let networkCredential = await networkCredentialProvider(challenge) {
***REMOVED******REMOVED******REMOVED***return .useCredential(networkCredential)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .cancelAuthenticationChallenge
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func handleArcGISAuthenticationChallenge(
***REMOVED******REMOVED***_ challenge: ArcGISAuthenticationChallenge
***REMOVED***) async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED***arcGISChallenges.append(challenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let arcgisCredentialProvider = arcgisCredentialProvider,
***REMOVED******REMOVED***   let arcgisCredential = try? await arcgisCredentialProvider(challenge) {
***REMOVED******REMOVED******REMOVED***return .useCredential(arcgisCredential)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .cancelAuthenticationChallenge
***REMOVED***
***REMOVED***
***REMOVED***
