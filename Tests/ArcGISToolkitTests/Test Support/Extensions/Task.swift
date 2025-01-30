***REMOVED*** Copyright 2025 Esri
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
import QuartzCore

***REMOVED***/ An error that signals a timeout has occurred.
struct TimeoutError: Error {***REMOVED***

extension Task {
***REMOVED******REMOVED***/ Yield until a condition is met or a timeout occurs.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - timeout: The interval at which a timeout error will occur.
***REMOVED******REMOVED***/   - until: The condition to yield until.
***REMOVED***static func yield(
***REMOVED******REMOVED***timeout: TimeInterval,
***REMOVED******REMOVED***until condition: @escaping @Sendable () async -> Bool
***REMOVED***) async throws where Failure == Never, Success == Never {
***REMOVED******REMOVED***try await Task<Void, any Error>(priority: .low) {
***REMOVED******REMOVED******REMOVED***let start = CACurrentMediaTime()
***REMOVED******REMOVED******REMOVED***repeat {
***REMOVED******REMOVED******REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED******REMOVED******REMOVED***let now = CACurrentMediaTime()
***REMOVED******REMOVED******REMOVED******REMOVED***guard now - start < timeout else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***throw TimeoutError()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** while await !condition()
***REMOVED***.value
***REMOVED***
***REMOVED***
