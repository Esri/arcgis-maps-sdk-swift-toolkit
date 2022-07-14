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
***REMOVED***init() {***REMOVED***
***REMOVED***
***REMOVED***public func complete() async {
***REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***var result: Result<ArcGISAuthenticationChallenge.Disposition, Error> {
***REMOVED******REMOVED***get async { fatalError() ***REMOVED***
***REMOVED***
***REMOVED***
