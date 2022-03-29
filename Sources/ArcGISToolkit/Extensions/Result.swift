***REMOVED***.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

extension Result where Failure == Error {
***REMOVED******REMOVED***/ Creates a result based on the outcome of the given task. If the task
***REMOVED******REMOVED***/ succeeds, the result is `success`. If the task fails, the result is
***REMOVED******REMOVED***/ `failure`.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Returns `nil` in the event that the task was cancelled.
***REMOVED***init?(awaiting task: () async throws -> Success) async {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***self = .success(try await task())
***REMOVED*** catch is CancellationError {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***self = .failure(error)
***REMOVED***
***REMOVED***
***REMOVED***
