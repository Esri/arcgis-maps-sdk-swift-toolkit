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

***REMOVED***/ An object that represents an ArcGIS OAuth authentication challenge in the queue of challenges.
@MainActor
final class QueuedOAuthChallenge: QueuedArcGISChallenge {
***REMOVED******REMOVED***/ The OAuth configuration to be used for this challenge.
***REMOVED***let configuration: OAuthConfiguration
***REMOVED***
***REMOVED******REMOVED***/ Creates a `QueuedOAuthChallenge`.
***REMOVED******REMOVED***/ - Parameter configuration: The OAuth configuration to be used for this challenge.
***REMOVED***init(configuration: OAuthConfiguration) {
***REMOVED******REMOVED***self.configuration = configuration
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Presents the user with a prompt to login with OAuth. This is done by creating the OAuth
***REMOVED******REMOVED***/ credential.
***REMOVED***func presentPrompt() {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***_result = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***.useCredential(try await .oauth(configuration: configuration))
***REMOVED******REMOVED***
***REMOVED***
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
