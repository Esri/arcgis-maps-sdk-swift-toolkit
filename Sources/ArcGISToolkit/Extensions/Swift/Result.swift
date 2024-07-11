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

public extension Result where Failure == Error {
***REMOVED******REMOVED***/ Creates a result based on the outcome of the given task. If the task
***REMOVED******REMOVED***/ succeeds, the result is `success`. If the task fails, the result is
***REMOVED******REMOVED***/ `failure`.
***REMOVED***init(awaiting task: @Sendable () async throws -> Success) async {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***self = .success(try await task())
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***self = .failure(error)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Converts the result to a `nil` in the case of a user cancelled error.
***REMOVED******REMOVED***/ - Returns: `Self` or `nil` if there was a cancellation error.
***REMOVED******REMOVED***/ - Attention: Deprecated at 200.3.
***REMOVED***@available(*, deprecated, message: "Check the 'failure' case for 'CancellationError' instead.")
***REMOVED***func cancellationToNil() -> Self? {
***REMOVED******REMOVED***guard case .failure(_ as CancellationError) = self else {
***REMOVED******REMOVED******REMOVED***return self
***REMOVED***
***REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
