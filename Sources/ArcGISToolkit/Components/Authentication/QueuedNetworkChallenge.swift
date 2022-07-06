***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import Foundation
***REMOVED***

***REMOVED***/ An object that represents a network authentication challenge in the queue of challenges.
final class QueuedNetworkChallenge: QueuedChallenge {
***REMOVED******REMOVED***/ The associated network authentication challenge.
***REMOVED***let networkChallenge: NetworkAuthenticationChallenge
***REMOVED***
***REMOVED******REMOVED***/ Creates a `QueuedNetworkChallenge`.
***REMOVED******REMOVED***/ - Parameter networkChallenge: The associated network authentication challenge.
***REMOVED***init(networkChallenge: NetworkAuthenticationChallenge) {
***REMOVED******REMOVED***self.networkChallenge = networkChallenge
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Resumes the queued challenge.
***REMOVED******REMOVED***/ - Parameter disposition: The disposition to resume with.
***REMOVED***func resume(with disposition: NetworkAuthenticationChallengeDisposition) {
***REMOVED******REMOVED***guard _disposition == nil else { return ***REMOVED***
***REMOVED******REMOVED***_disposition = disposition
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Use a streamed property because we need to support multiple listeners
***REMOVED******REMOVED***/ to know when the challenge completed.
***REMOVED***@Streamed private var _disposition: (NetworkAuthenticationChallengeDisposition)?
***REMOVED***
***REMOVED******REMOVED***/ The resulting disposition of the challenge.
***REMOVED***var disposition: NetworkAuthenticationChallengeDisposition {
***REMOVED******REMOVED***get async {
***REMOVED******REMOVED******REMOVED***await $_disposition
***REMOVED******REMOVED******REMOVED******REMOVED***.compactMap({ $0 ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.first(where: { _ in true ***REMOVED***)!
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func complete() async {
***REMOVED******REMOVED***_ = await disposition
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ An enumeration that describes the kind of challenge.
***REMOVED***enum Kind {
***REMOVED******REMOVED******REMOVED***/ A challenge for an untrusted host.
***REMOVED******REMOVED***case serverTrust
***REMOVED******REMOVED******REMOVED***/ A challenge that requires a login via username and password.
***REMOVED******REMOVED***case login
***REMOVED******REMOVED******REMOVED***/ A challenge that requires a client certificate.
***REMOVED******REMOVED***case certificate
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The kind of challenge.
***REMOVED***var kind: Kind {
***REMOVED******REMOVED***switch networkChallenge.kind {
***REMOVED******REMOVED***case .serverTrust:
***REMOVED******REMOVED******REMOVED***return .serverTrust
***REMOVED******REMOVED***case .ntlm, .basic, .digest:
***REMOVED******REMOVED******REMOVED***return .login
***REMOVED******REMOVED***case .pki:
***REMOVED******REMOVED******REMOVED***return .certificate
***REMOVED******REMOVED***case .htmlForm, .negotiate:
***REMOVED******REMOVED******REMOVED***fatalError("TODO: ")
***REMOVED***
***REMOVED***
***REMOVED***
