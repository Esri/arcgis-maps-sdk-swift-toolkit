***REMOVED***
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

import Combine

extension Publisher where Self: Sendable {
***REMOVED******REMOVED***/ Asynchronously returns the first value emitted from the publisher.
***REMOVED******REMOVED***/ This property will return `nil` if this publisher completes without an error before
***REMOVED******REMOVED***/ it emits a value.
***REMOVED***var first: Output? {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***if let output = try await AsyncThrowingPublisher(self).first {
***REMOVED******REMOVED******REMOVED******REMOVED***return output
***REMOVED******REMOVED*** else if Task.isCancelled {
***REMOVED******REMOVED******REMOVED******REMOVED***throw CancellationError()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension AsyncSequence {
***REMOVED******REMOVED***/ The first element emitted by the async sequence.
***REMOVED***var first: Element? {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***try await first { _ in true ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
