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

import Foundation
***REMOVED***

***REMOVED***/ An object that represents an ArcGIS token authentication challenge continuation.
@MainActor
final class TokenChallengeContinuation: ValueContinuation<Result<ArcGISAuthenticationChallenge.Disposition, Error>>, ChallengeContinuation {
***REMOVED******REMOVED***/ The host that prompted the challenge.
***REMOVED***let host: String
***REMOVED***
***REMOVED******REMOVED***/ A closure that provides a token credential from a username and password.
***REMOVED***let tokenCredentialProvider: (LoginCredential) async throws -> ArcGISCredential
***REMOVED***
***REMOVED******REMOVED***/ Creates a `ArcGISChallengeContinuation`.
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
***REMOVED******REMOVED***/ Creates a `ArcGISChallengeContinuation`.
***REMOVED******REMOVED***/ - Parameter arcGISChallenge: The associated ArcGIS authentication challenge.
***REMOVED***convenience init(arcGISChallenge: ArcGISAuthenticationChallenge) {
***REMOVED******REMOVED***self.init(host: arcGISChallenge.requestURL.host ?? "") { loginCredential in
***REMOVED******REMOVED******REMOVED***try await TokenCredential.credential(
***REMOVED******REMOVED******REMOVED******REMOVED***for: arcGISChallenge,
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
***REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED***setValue(await Result { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED***.continueWithCredential(try await tokenCredentialProvider(loginCredential))
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels the challenge.
***REMOVED***func cancel() {
***REMOVED******REMOVED***setValue(.success(.cancel))
***REMOVED***
***REMOVED***
