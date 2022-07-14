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
final class QueuedArcGISChallenge: QueuedChallenge {
***REMOVED******REMOVED***/ The ArcGIS authentication challenge.
***REMOVED***let arcGISChallenge: ArcGISAuthenticationChallenge
***REMOVED***
***REMOVED******REMOVED***/ Creates a `QueuedArcGISChallenge`.
***REMOVED******REMOVED***/ - Parameter arcGISChallenge: The associated ArcGIS authentication challenge.
***REMOVED***init(arcGISChallenge: ArcGISAuthenticationChallenge) {
***REMOVED******REMOVED***self.arcGISChallenge = arcGISChallenge
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Resumes the challenge with a result.
***REMOVED******REMOVED***/ - Parameter result: The result of the challenge.
***REMOVED***func resume(with result: Result<ArcGISAuthenticationChallenge.Disposition, Error>) {
***REMOVED******REMOVED***guard _result == nil else { return ***REMOVED***
***REMOVED******REMOVED***_result = result
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
***REMOVED******REMOVED***/ The host that prompted the challenge.
***REMOVED***var host: String {
***REMOVED******REMOVED***arcGISChallenge.request.url?.host ?? ""
***REMOVED***
***REMOVED***
***REMOVED***public func complete() async {
***REMOVED******REMOVED***_ = await result
***REMOVED***
***REMOVED***
