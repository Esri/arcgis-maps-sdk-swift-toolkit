***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import os

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
***REMOVED***var challenges: [NetworkAuthenticationChallenge] {
***REMOVED******REMOVED***_challenges.withLock { $0 ***REMOVED***
***REMOVED***
***REMOVED***private let _challenges = OSAllocatedUnfairLock<[NetworkAuthenticationChallenge]>(initialState: [])
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
***REMOVED******REMOVED******REMOVED***_challenges.withLock { $0.append(challenge) ***REMOVED***
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
