***REMOVED*** Copyright 2022 Esri
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

import XCTest
@testable ***REMOVED***Toolkit

final class ValueContinuationTests: XCTestCase {
***REMOVED***@MainActor
***REMOVED***func testValueContinuation() async {
***REMOVED******REMOVED******REMOVED*** Tests setting value before awaiting.
***REMOVED******REMOVED***let valueContinuation = ValueContinuation<String>()
***REMOVED******REMOVED***valueContinuation.setValue("hello")
***REMOVED******REMOVED***let value = await valueContinuation.value
***REMOVED******REMOVED***XCTAssertEqual(value, "hello")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Tests setting value after awaiting.
***REMOVED******REMOVED***let valueContinuation2 = ValueContinuation<Int>()
***REMOVED******REMOVED***Task { valueContinuation2.setValue(1) ***REMOVED***
***REMOVED******REMOVED***let value2 = await valueContinuation2.value
***REMOVED******REMOVED***XCTAssertEqual(value2, 1)
***REMOVED***
***REMOVED***
