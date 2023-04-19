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

***REMOVED***/ A `NetworkChallengeHandler` that can handle trusting hosts with a self-signed certificate
***REMOVED***/ and the network credential.
final class NetworkChallengeHandler: NetworkAuthenticationChallengeHandler {
***REMOVED******REMOVED***/ A Boolean value indicating whether to allow hosts that have certificate trust issues.
***REMOVED***let allowUntrustedHosts: Bool
***REMOVED***
***REMOVED******REMOVED***/ The url credential used when a challenge is thrown.
***REMOVED***let networkCredential: NetworkCredential?
***REMOVED******REMOVED***
***REMOVED******REMOVED***/ The network authentication challenges.
***REMOVED***private(set) var challenges: [NetworkAuthenticationChallenge] = []
***REMOVED******REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***allowUntrustedHosts: Bool,
***REMOVED******REMOVED***networkCredential: NetworkCredential? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.allowUntrustedHosts = allowUntrustedHosts
***REMOVED******REMOVED***self.networkCredential = networkCredential
***REMOVED***
***REMOVED******REMOVED***
***REMOVED***func handleNetworkAuthenticationChallenge(
***REMOVED******REMOVED***_ challenge: NetworkAuthenticationChallenge
***REMOVED***) async -> NetworkAuthenticationChallenge.Disposition {
***REMOVED******REMOVED******REMOVED*** Record challenge only if it is not a server trust.
***REMOVED******REMOVED***if challenge.kind != .serverTrust {
***REMOVED******REMOVED******REMOVED***challenges.append(challenge)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if challenge.kind == .serverTrust {
***REMOVED******REMOVED******REMOVED***if allowUntrustedHosts {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** This will cause a self-signed certificate to be trusted.
***REMOVED******REMOVED******REMOVED******REMOVED***return .continueWithCredential(.serverTrust)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return .continueWithoutCredential
***REMOVED******REMOVED***
***REMOVED*** else if let networkCredential = networkCredential {
***REMOVED******REMOVED******REMOVED***return .continueWithCredential(networkCredential)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .cancel
***REMOVED***
***REMOVED***
***REMOVED***
