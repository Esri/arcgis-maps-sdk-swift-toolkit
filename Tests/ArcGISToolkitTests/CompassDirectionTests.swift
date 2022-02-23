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

import XCTest
@testable ***REMOVED***Toolkit

class CompassDirectionTests: XCTestCase {
***REMOVED******REMOVED***/ Tests the behvaior of `CompassDirection.init(_ : Double)`
***REMOVED***func testInitCompassDirection() {
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(-405), .northwest)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(-360), .north)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(0), .north)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(22.4), .north)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(22.5), .northeast)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(45), .northeast)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(90), .east)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(135), .southeast)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(180), .south)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(225), .southwest)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(270), .west)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(315), .northwest)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(359), .north)
***REMOVED******REMOVED***XCTAssertEqual(CompassDirection(450), .east)
***REMOVED***
***REMOVED***
