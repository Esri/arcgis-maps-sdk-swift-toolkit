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

***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

class ResultTests: XCTestCase {
***REMOVED******REMOVED***/ Tests the conversion of a cancellation error result to `nil.`
***REMOVED***func testCancellationToNil() {
***REMOVED******REMOVED***var result: Result<String, Error> = .success("hello")
***REMOVED******REMOVED***XCTAssertNotNil(result.cancellationToNil())
***REMOVED******REMOVED***
***REMOVED******REMOVED***struct MockError: Error {***REMOVED***
***REMOVED******REMOVED***result = .failure(MockError())
***REMOVED******REMOVED***XCTAssertNotNil(result.cancellationToNil())
***REMOVED******REMOVED***
***REMOVED******REMOVED***result = .failure(CancellationError())
***REMOVED******REMOVED***XCTAssertNil(result.cancellationToNil())
***REMOVED***
***REMOVED***
