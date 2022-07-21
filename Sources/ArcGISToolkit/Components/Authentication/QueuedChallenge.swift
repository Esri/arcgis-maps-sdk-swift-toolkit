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

***REMOVED***/ A type that represents a challenge in the queue of authentication challenges.
protocol QueuedChallenge: AnyObject {
***REMOVED******REMOVED***/ Waits for the challenge to complete.
***REMOVED***func complete() async
***REMOVED***

protocol QueuedArcGISChallenge: QueuedChallenge {
***REMOVED******REMOVED***/ The result of the challenge.
***REMOVED***var result: Result<ArcGISAuthenticationChallenge.Disposition, Error> { get async ***REMOVED***
***REMOVED***
