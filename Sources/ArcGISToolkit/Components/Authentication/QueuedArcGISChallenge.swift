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

***REMOVED***/ An object that represents an ArcGIS authentication challenge in the queue of challenges.
@MainActor
final class QueuedArcGISChallenge: QueuedChallenge {
***REMOVED******REMOVED***/ The host that prompted the challenge.
***REMOVED***let host: String
***REMOVED***
***REMOVED******REMOVED***/ A closure that provides a token credential from a username and password.
***REMOVED***let tokenCredentialProvider: (LoginCredential) async throws -> ArcGISCredential
***REMOVED***
***REMOVED******REMOVED***/ Creates a `QueuedArcGISChallenge`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - host: The host that prompted the challenge.
***REMOVED******REMOVED***/   - tokenCredentialProvider: A closure that provides a token credential from a username and password.
***REMOVED***init(
***REMOVED******REMOVED***host: String,
***REMOVED******REMOVED***tokenCredentialProvider: @escaping (LoginCredential) async throws -> ArcGISCredential
***REMOVED***) {
***REMOVED******REMOVED***self.host = host
***REMOVED******REMOVED***self.tokenCredentialProvider = tokenCredentialProvider
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `QueuedArcGISChallenge`.
***REMOVED******REMOVED***/ - Parameter arcGISChallenge: The associated ArcGIS authentication challenge.
***REMOVED***convenience init(arcGISChallenge: ArcGISAuthenticationChallenge) {
***REMOVED******REMOVED***self.init(host: arcGISChallenge.request.url?.host ?? "") { loginCredential in
***REMOVED******REMOVED******REMOVED***try await .token(
***REMOVED******REMOVED******REMOVED******REMOVED***challenge: arcGISChallenge,
***REMOVED******REMOVED******REMOVED******REMOVED***username: loginCredential.username,
***REMOVED******REMOVED******REMOVED******REMOVED***password: loginCredential.password
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Resumes the challenge with a username and password.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - loginCredential: The username and password.
***REMOVED***func resume(with loginCredential: LoginCredential) {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***guard _result == nil else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***_result = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***.useCredential(try await tokenCredentialProvider(loginCredential))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels the challenge.
***REMOVED***func cancel() {
***REMOVED******REMOVED***guard _result == nil else { return ***REMOVED***
***REMOVED******REMOVED***_result = .success(.cancelAuthenticationChallenge)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Use a streamed property because we need to support multiple listeners
***REMOVED******REMOVED***/ to know when the challenge completed.
***REMOVED***@Streamed private var _result: Result<ArcGISAuthenticationChallenge.Disposition, Error>?
***REMOVED***
***REMOVED******REMOVED***/ The result of the challenge.
***REMOVED***var result: Result<ArcGISAuthenticationChallenge.Disposition, Error> {
***REMOVED******REMOVED***get async {
***REMOVED******REMOVED******REMOVED***await $_result
***REMOVED******REMOVED******REMOVED******REMOVED***.compactMap({ $0 ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.first(where: { _ in true ***REMOVED***)!
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func complete() async {
***REMOVED******REMOVED***_ = await result
***REMOVED***
***REMOVED***
