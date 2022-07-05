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

protocol QueuedChallenge: AnyObject {
***REMOVED***func complete() async
***REMOVED***

final class QueuedArcGISChallenge: QueuedChallenge {
***REMOVED***let arcGISChallenge: ArcGISAuthenticationChallenge
***REMOVED***
***REMOVED***init(arcGISChallenge: ArcGISAuthenticationChallenge) {
***REMOVED******REMOVED***self.arcGISChallenge = arcGISChallenge
***REMOVED***

***REMOVED***func resume(with response: Response) {
***REMOVED******REMOVED***guard _response == nil else { return ***REMOVED***
***REMOVED******REMOVED***_response = response
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***guard _response == nil else { return ***REMOVED***
***REMOVED******REMOVED***_response = .cancel
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Use a streamed property because we need to support multiple listeners
***REMOVED******REMOVED***/ to know when the challenge completed.
***REMOVED***@Streamed private var _response: Response?
***REMOVED***
***REMOVED***var response: Response {
***REMOVED******REMOVED***get async {
***REMOVED******REMOVED******REMOVED***await $_response
***REMOVED******REMOVED******REMOVED******REMOVED***.compactMap({ $0 ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.first(where: { _ in true ***REMOVED***)!
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func complete() async {
***REMOVED******REMOVED***_ = await response
***REMOVED***
***REMOVED***
***REMOVED***enum Response {
***REMOVED******REMOVED***case tokenCredential(username: String, password: String)
***REMOVED******REMOVED***case oAuth(configuration: OAuthConfiguration)
***REMOVED******REMOVED***case cancel
***REMOVED***
***REMOVED***

final class QueuedNetworkChallenge: QueuedChallenge {
***REMOVED***let networkChallenge: NetworkAuthenticationChallenge
***REMOVED***
***REMOVED***init(networkChallenge: NetworkAuthenticationChallenge) {
***REMOVED******REMOVED***self.networkChallenge = networkChallenge
***REMOVED***

***REMOVED***func resume(with response: NetworkAuthenticationChallengeDisposition) {
***REMOVED******REMOVED***guard _disposition == nil else { return ***REMOVED***
***REMOVED******REMOVED***_disposition = response
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Use a streamed property because we need to support multiple listeners
***REMOVED******REMOVED***/ to know when the challenge completed.
***REMOVED***@Streamed private var _disposition: (NetworkAuthenticationChallengeDisposition)?
***REMOVED***
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
***REMOVED***enum Kind {
***REMOVED******REMOVED***case serverTrust
***REMOVED******REMOVED***case login
***REMOVED******REMOVED***case certificate
***REMOVED***
***REMOVED***
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
