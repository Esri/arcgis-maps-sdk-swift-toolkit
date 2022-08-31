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

***REMOVED***/ An object that represents an ArcGIS OAuth challenge continuation.
@MainActor
final class OAuthChallengeContinuation: ValueContinuation<Result<ArcGISAuthenticationChallenge.Disposition, Error>>, ArcGISChallengeContinuation {
***REMOVED******REMOVED***/ The OAuth configuration to be used for this challenge.
***REMOVED***let configuration: OAuthConfiguration
***REMOVED***
***REMOVED******REMOVED***/ Creates a `OAuthChallengeContinuation`.
***REMOVED******REMOVED***/ - Parameter configuration: The OAuth configuration to be used for this challenge.
***REMOVED***init(configuration: OAuthConfiguration) {
***REMOVED******REMOVED***self.configuration = configuration
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Presents the user with a prompt to login with OAuth. This is done by creating the OAuth
***REMOVED******REMOVED***/ credential.
***REMOVED***func presentPrompt() async {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let credential = try await ArcGISCredential.oauth(configuration: configuration)
***REMOVED******REMOVED******REMOVED***setValue(.success(.useCredential(credential)))
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***if let authorizationError = error as? OAuthCredential.AuthorizationError,
***REMOVED******REMOVED******REMOVED***   authorizationError == .userCancelled {
***REMOVED******REMOVED******REMOVED******REMOVED***setValue(.success(.cancel))
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***setValue(.failure(error))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
