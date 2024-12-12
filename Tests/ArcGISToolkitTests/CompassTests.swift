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

#if !os(visionOS)
***REMOVED***
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

final class CompassTests: XCTestCase {
***REMOVED******REMOVED***/ Verifies that the compass accurately indicates it shouldn't be hidden when `autoHideDisabled`
***REMOVED******REMOVED***/ is applied.
***REMOVED***@MainActor
***REMOVED***func testHiddenWithAutoHideOff() {
***REMOVED******REMOVED***let compass1Heading = Double.zero
***REMOVED******REMOVED***let compass1 = Compass(rotation: compass1Heading, mapViewProxy: nil, action: nil)
***REMOVED******REMOVED******REMOVED***.autoHideDisabled()
***REMOVED******REMOVED***XCTAssertFalse(compass1.shouldHide(forHeading: compass1Heading))
***REMOVED******REMOVED***
***REMOVED******REMOVED***let compass2Heading = 45.0
***REMOVED******REMOVED***let compass2 = Compass(rotation: compass2Heading, mapViewProxy: nil, action: nil)
***REMOVED******REMOVED******REMOVED***.autoHideDisabled()
***REMOVED******REMOVED***XCTAssertFalse(compass2.shouldHide(forHeading: compass2Heading))
***REMOVED******REMOVED***
***REMOVED******REMOVED***let compass3Heading = Double.nan
***REMOVED******REMOVED***let compass3 = Compass(rotation: compass3Heading, mapViewProxy: nil, action: nil)
***REMOVED******REMOVED******REMOVED***.autoHideDisabled()
***REMOVED******REMOVED***XCTAssertFalse(compass3.shouldHide(forHeading: compass3Heading))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Verifies that the compass accurately indicates when it should be hidden.
***REMOVED***@MainActor
***REMOVED***func testHiddenWithAutoHideOn() {
***REMOVED******REMOVED***let compass1Heading: Double = .zero
***REMOVED******REMOVED***let compass1 = Compass(rotation: compass1Heading, mapViewProxy: nil, action: nil)
***REMOVED******REMOVED***XCTAssertTrue(compass1.shouldHide(forHeading: compass1Heading))
***REMOVED******REMOVED***
***REMOVED******REMOVED***let compass2Heading = 45.0
***REMOVED******REMOVED***let compass2 = Compass(rotation: compass2Heading, mapViewProxy: nil, action: nil)
***REMOVED******REMOVED***XCTAssertFalse(compass2.shouldHide(forHeading: compass2Heading))
***REMOVED******REMOVED***
***REMOVED******REMOVED***let compass3Heading = Double.nan
***REMOVED******REMOVED***let compass3 = Compass(rotation: compass3Heading, mapViewProxy: nil, action: nil)
***REMOVED******REMOVED***XCTAssertTrue(compass3.shouldHide(forHeading: compass3Heading))
***REMOVED***
***REMOVED***
#endif
