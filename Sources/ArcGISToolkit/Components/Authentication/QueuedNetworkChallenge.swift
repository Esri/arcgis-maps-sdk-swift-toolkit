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
@MainActor
final class QueuedNetworkChallenge: ValueContinuation<NetworkAuthenticationChallengeDisposition>, QueuedChallenge {
***REMOVED******REMOVED***/ The host that prompted the challenge.
***REMOVED***let host: String
***REMOVED***
***REMOVED******REMOVED***/ The kind of challenge.
***REMOVED***let kind: Kind
***REMOVED***
***REMOVED******REMOVED***/ Creates a `QueuedNetworkChallenge`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - host: The host that prompted the challenge.
***REMOVED******REMOVED***/   - kind: The kind of challenge.
***REMOVED***init(host: String, kind: Kind) {
***REMOVED******REMOVED***self.host = host
***REMOVED******REMOVED***self.kind = kind
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Resumes the queued challenge.
***REMOVED******REMOVED***/ - Parameter disposition: The disposition to resume with.
***REMOVED***func resume(with disposition: NetworkAuthenticationChallengeDisposition) {
***REMOVED******REMOVED***setValue(disposition)
***REMOVED***
***REMOVED***

extension QueuedNetworkChallenge {
***REMOVED******REMOVED***/ Creates a `QueuedNetworkChallenge`.
***REMOVED******REMOVED***/ - Parameter networkChallenge: The associated network authentication challenge.
***REMOVED***convenience init(networkChallenge: NetworkAuthenticationChallenge) {
***REMOVED******REMOVED***self.init(host: networkChallenge.host, kind: Kind(networkChallenge.kind))
***REMOVED***
***REMOVED***

extension QueuedNetworkChallenge {
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

extension QueuedNetworkChallenge.Kind {
***REMOVED******REMOVED***/ Creates an instance.
***REMOVED******REMOVED***/ - Parameter networkAuthenticationChallengeKind: The kind of network authentication
***REMOVED******REMOVED***/ challenge.
***REMOVED***init(_ networkAuthenticationChallengeKind: NetworkAuthenticationChallenge.Kind) {
***REMOVED******REMOVED***switch networkAuthenticationChallengeKind {
***REMOVED******REMOVED***case .serverTrust:
***REMOVED******REMOVED******REMOVED***self = .serverTrust
***REMOVED******REMOVED***case .ntlm, .basic, .digest:
***REMOVED******REMOVED******REMOVED***self = .login
***REMOVED******REMOVED***case .clientCertificate:
***REMOVED******REMOVED******REMOVED***self = .certificate
***REMOVED***
***REMOVED***
***REMOVED***
