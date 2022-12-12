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

class AngleTests: XCTestCase {
***REMOVED******REMOVED***/ Tests the behvaior of `Angle`'s normalized member.
***REMOVED***func testNormalizedAngle() {
***REMOVED******REMOVED***XCTAssertEqual(Angle(degrees: -361.0).normalizedDegrees, 359)
***REMOVED******REMOVED***XCTAssertEqual(Angle(degrees: -360.0).normalizedDegrees, 0)
***REMOVED******REMOVED***XCTAssertEqual(Angle(degrees: -180.0).normalizedDegrees, 180)
***REMOVED******REMOVED***XCTAssertEqual(Angle(degrees: -0).normalizedDegrees, 0)
***REMOVED******REMOVED***XCTAssertEqual(Angle(degrees: 0).normalizedDegrees, 0)
***REMOVED******REMOVED***XCTAssertEqual(Angle(degrees: 45).normalizedDegrees, 45)
***REMOVED******REMOVED***XCTAssertEqual(Angle(degrees: 180).normalizedDegrees, 180)
***REMOVED******REMOVED***XCTAssertEqual(Angle(degrees: 360).normalizedDegrees, 0)
***REMOVED******REMOVED***XCTAssertEqual(Angle(degrees: 405).normalizedDegrees, 45)
***REMOVED***
***REMOVED***
